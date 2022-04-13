#!/usr/bin/env php
<?php

declare(strict_types=1);

use CliffordVickrey\FecActBlue\Utilities;
use GuzzleHttp\Client;
use GuzzleHttp\Exception\ClientException;
use GuzzleHttp\Psr7\Stream;
use GuzzleHttp\RequestOptions;
use Psr\Http\Message\ResponseInterface;

ini_set('max_execution_time', '0');

chdir(__DIR__);

require_once __DIR__ . '/../vendor/autoload.php';

// region script variables

$client = new Client();
$committeeId = 'C00401224';
$credentials = require __DIR__ . '/../data/credentials.php';
$hadError = false;
$lastIndexes = null;
/** @var resource $logResource */
$logResource = fopen(__DIR__ . '/../data/log/request.log', 'a');
$logStream = new Stream($logResource);
$maxDate = '2019-12-31';
$maxTries = 20;
$minDate = '2019-01-01';
$pageStream = null;
$rate = 4.0;
$url = 'https://api.open.fec.gov/v1/schedules/schedule_a/';
$valid = true;

// endregion

// region CLI params

$params = $params ?? ($argv ?? []);

if (is_string($params[1] ?? null) && '' !== trim($params[1])) {
    $minDate = trim($params[1]);
}

if (!Utilities::isDateValid($minDate)) {
    echo "'$minDate' is not a valid value for min_date. Expected date formatted as 'Y-m-d'" . PHP_EOL;
    exit(1);
}

if (is_string($params[2] ?? null) && '' !== trim($params[2])) {
    $maxDate = trim($params[2]);
}

if (!Utilities::isDateValid($maxDate)) {
    echo "'$maxDate' is not a valid value for max_date. Expected date formatted as 'Y-m-d'" . PHP_EOL;
    exit(1);
}

// endregion

// region query params

$baseQuery = [
    'api_key' => $credentials['apiKey'],
    'committee_id' => $committeeId,
    'is_individual' => true,
    'max_date' => $minDate,
    'min_date' => $minDate,
    'per_page' => 100,
    'sort' => 'contribution_receipt_date'
];

// endregion

try {
    do {
        // region send request

        $query = $baseQuery;
        $query['min_date'] = $minDate;
        $query['max_date'] = $minDate;

        if (is_array($lastIndexes)) {
            $query = array_merge($query, $lastIndexes);
        }

        $logParams = [date(DateTimeInterface::RFC3339), 999, 0, $url, http_build_query($query), PHP_EOL];

        $fetched = false;
        $lastEx = null;

        do {
            for ($i = 0; $i < $maxTries; $i++) {
                $oldStartTime = $startTime ?? 0.0;
                $startTime = microtime(true);

                $elapsed = $startTime - $oldStartTime;

                if ($elapsed < $rate) {
                    $coolDown = $rate - $elapsed;
                    echo sprintf('Cooling down for %g seconds', $coolDown) . PHP_EOL;
                    usleep((int)($coolDown * 1000000));
                    $startTime = microtime(true);
                }

                echo sprintf('Sending request (contribution_receipt_date = "%s") ... ', $minDate);

                try {
                    $response = $client->get($url, [
                        RequestOptions::CONNECT_TIMEOUT => 10,
                        RequestOptions::TIMEOUT => 1000,
                        RequestOptions::QUERY => $query,
                        RequestOptions::VERIFY => __DIR__ . '/../data/cacert.pem'
                    ]);

                    $logParams[1] = $response->getStatusCode();

                    echo 'success!' . PHP_EOL;

                    $lastEx = null;
                } catch (ClientException $clientEx) {
                    if ($clientEx->hasResponse()) {
                        /** @var ResponseInterface $response */
                        $response = $clientEx->getResponse();
                        $logParams[1] = $response->getStatusCode();
                    }

                    $lastEx = $clientEx;
                } catch (Throwable $ex) {
                    $lastEx = $ex;
                } finally {
                    $stopTime = microtime(true);
                    $logParams[2] = str_pad(sprintf('%gs', round($stopTime - $startTime, 2)), 7, ' ', STR_PAD_LEFT);
                    $logStream->write(vsprintf('%s %d %s GET %s?%s%s', $logParams));
                }

                if (null === $lastEx) {
                    break;
                }

                echo 'error!' . PHP_EOL;

                if (429 === $logParams[1]) {
                    echo "The rate limit has been exceeded. Let's wait an hour ..." . PHP_EOL;
                    sleep(3600); // wait an hour before trying again
                } else {
                    echo "Request failed! Let's try again ..." . PHP_EOL;
                    sleep(1);
                }
            }

            if (null !== $lastEx) {
                echo "Could not get response 200 after $maxTries tries. I give up!" . PHP_EOL;
                echo "Let's wait an hour ..." . PHP_EOL;
                sleep(3600); // wait an hour before trying again
            } else {
                $fetched = true;
            }
        } while (!$fetched);

        // endregion

        // region parse response

        /** @var ResponseInterface $response */
        $body = $response->getBody()->getContents();

        /** @var array<string, mixed> $data */
        $data = json_decode($body, true) ?: [];

        $results = $data['results'] ?? null;

        if (!is_array($results)) {
            throw new RuntimeException('Response did not provide results');
        }

        // group results by contribution receipt date
        /** @var non-empty-array<string, list<array<string, mixed>>> $resultsByDate */
        $resultsByDate = array_reduce(
            $results,
            [Utilities::class, 'groupResultsByContributionReceiptDate'],
            [$minDate => []]
        );

        // try to resolve the last index params to send to the next request
        $pagination = $data['pagination'] ?? null;
        $lastIndexes = is_array($pagination) ? ($pagination['last_indexes'] ?? null) : null;

        // endregion

        // region write data

        $minDate = (string)array_key_last($resultsByDate);

        foreach ($resultsByDate as $date => $output) {
            // write the JSON document as a line
            if (count($output) > 0) {
                if (null === $pageStream) {
                    /** @var resource $pageResource */
                    $pageResource = fopen(sprintf(__DIR__ . '/../data/raw-data/%s.txt', $date), 'w');
                    $pageStream = new Stream($pageResource);
                }

                $pageStream->write((json_encode($output) ?: '[]') . PHP_EOL);
            }

            // our output stream is no longer valid. Write to a new file next time
            if (null !== $pageStream && $date !== $minDate) {
                $pageStream->close();
                $pageStream = null;
            }
        }

        // endregion

        // region check if we're (finally!) done

        $endOfResults = (empty($lastIndexes) || !is_array($lastIndexes));
        if ($minDate === $maxDate && $endOfResults) {
            $valid = false;
        } elseif ($endOfResults) {
            /** @var DateTimeImmutable $dateTime */
            $dateTime = DateTimeImmutable::createFromFormat('Y-m-d', $minDate);
            $dateTime = $dateTime->add(new DateInterval('P1D'));
            $minDate = $dateTime->format('Y-m-d');
            $pageStream?->close();
            $pageStream = null;
        }

        // endregion
    } while ($valid);
} catch (Throwable $ex) {
    $hadError = true;
    $logStream->write($ex . PHP_EOL);
} finally {
    $logStream->close();
    $pageStream?->close();
}

echo ($hadError ? 'Error! (check logs)' : 'Success!') . PHP_EOL;

exit($hadError ? 1 : 0);
