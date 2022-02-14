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
$logResource = fopen(__DIR__ . '/../data/log/request-log.log', 'a');
$logStream = new Stream($logResource);
$maxDate = '2019-12-31';
$maxTries = 20;
$minDate = '2019-01-01';
$pageStream = null;
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
    'max_date' => $maxDate,
    'min_date' => $minDate,
    'per_page' => 100,
    'sort' => 'contribution_receipt_date'
];

// endregion

try {
    do {
        // region send request

        $query = $baseQuery;

        if (is_array($lastIndexes)) {
            $query = array_merge($query, $lastIndexes);
        }

        $logParams = [date(DateTimeInterface::RFC3339), 999, 0, $url, http_build_query($query), PHP_EOL];

        $oldTime = microtime(true);

        $lastEx = null;

        for ($i = 0; $i < $maxTries; $i++) {
            echo sprintf('Sending request (contribution_receipt_date = "%s") ... ', $minDate);

            try {
                $response = $client->get($url, [
                    RequestOptions::CONNECT_TIMEOUT => 10,
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
                $logParams[2] = str_pad(sprintf('%gs', round(microtime(true) - $oldTime, 2)), 7, ' ', STR_PAD_LEFT);
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
                echo 'Request failed! Retrying in 500 milliseconds ...' . PHP_EOL;
                usleep(500000); // wait half a second before trying again
            }
        }

        if (null !== $lastEx) {
            echo "Could not get response 200 after $maxTries tries. I give up!" . PHP_EOL;
            throw $lastEx;
        }

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

        // we're at the end of the line!
        if (empty($lastIndexes) || !is_array($lastIndexes)) {
            $valid = false;
        }

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
