#!/usr/bin/env php
<?php

declare(strict_types=1);

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
$logResource = fopen(__DIR__ . sprintf('/../data/log/log%d.log', time()), 'w');
$logStream = new Stream($logResource);
$maxDate = '2019-12-31';
$maxTries = 20;
$minDate = '2019-01-01';
$pageStream = null;
$url = 'https://api.open.fec.gov/v1/schedules/schedule_a/';
$valid = true;

// endregion

// region callbacks

/**
 * @param mixed $value
 * @return string|null
 */
$dateParser = function (mixed $value): ?string {
    if (!is_string($value)) {
        return null;
    }

    if (strlen($value) < 10) {
        return null;
    }

    return substr($value, 0, 10);
};

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
                $logStream->write(vsprintf('%s %d %s %s?%s%s', $logParams));
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

        // try to get the last contribution receipt date
        $contributionReceiptDates = array_values(array_filter(array_map(
            $dateParser,
            array_column($results, 'contribution_receipt_date')
        )));

        if (0 !== count($contributionReceiptDates)) {
            sort($contributionReceiptDates);
            $contributionReceiptDates = array_values($contributionReceiptDates);
            $maxContributionReceiptDate = array_pop($contributionReceiptDates);

            if ($minDate !== $maxContributionReceiptDate) {
                if (null !== $pageStream) {
                    /**
                     * @param array<string, mixed> $row
                     * @return bool
                     */
                    $dateIncludeFilter = function (array $row) use ($minDate): bool {
                        $contributionReceiptDate = $row['contribution_receipt_date'] ?? null;

                        if (!is_string($contributionReceiptDate)) {
                            return false;
                        }

                        return str_starts_with($contributionReceiptDate, $minDate);
                    };

                    /**
                     * @param array<string, mixed> $row
                     * @return bool
                     */
                    $dateExcludeFilter = function (array $row) use ($dateIncludeFilter): bool {
                        return !$dateIncludeFilter($row);
                    };

                    $line = json_encode((array_values(array_filter($results, $dateIncludeFilter))) ?: '[]') . PHP_EOL;
                    $pageStream->write($line);
                    $results = array_values(array_filter($results, $dateExcludeFilter));
                }

                $pageStream?->close();
                $pageStream = null;
            }

            $minDate = $maxContributionReceiptDate;
        }

        $pagination = $data['pagination'] ?? null;

        $lastIndexes = null;

        $lastIndexes = is_array($pagination) ? ($pagination['last_indexes'] ?? null) : null;

        if (empty($lastIndexes) || !is_array($lastIndexes)) {
            $valid = false;
        }

        // endregion

        // region write data

        if (null === $pageStream) {
            /** @var resource $pageResource */
            $pageResource = fopen(sprintf(__DIR__ . '/../data/raw-data/%s.txt', $minDate), 'w');
            $pageStream = new Stream($pageResource);
        }

        $pageStream->write((json_encode($results) ?: '[]') . PHP_EOL);

        // endregion
    } while ($valid);
} catch (Throwable $ex) {
    $hadError = true;
    $logStream->write((string)$ex);
} finally {
    $logStream->close();
    $pageStream?->close();
}

echo $hadError ? 'Error! (check logs)' : 'Success!';

exit($hadError ? 1 : 0);
