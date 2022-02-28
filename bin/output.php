#!/usr/bin/env php
<?php

declare(strict_types=1);

use CliffordVickrey\FecActBlue\Utilities;

ini_set('max_execution_time', '0');

chdir(__DIR__);

require_once __DIR__ . '/../vendor/autoload.php';

$skinny = $skinny ?? false;

if (!$skinny) {
    $columnsFile = __DIR__ . '/../data/columns.json';

    if (!is_file($columnsFile)) {
        require __DIR__ . '/generate-columns.php';
    }

    $columnsJson = (string)file_get_contents($columnsFile);

    /** @var string[] $columns */
    $columns = json_decode($columnsJson, true) ?: [];
} else {
    $columns = [
        'candidate_id',
        'contribution_receipt_date',
        'contribution_receipt_amount',
        'contributor_city',
        'contributor_employer',
        'contributor_name',
        'contributor_occupation',
        'contributor_state',
        'contributor_street_1',
        'contributor_zip',
        'memo_text'
    ];
}


if (0 === count($columns)) {
    throw new RuntimeException('Could not parse column information');
}

$template = array_combine($columns, array_fill(0, count($columns), ''));

$files = glob(__DIR__ . '/../data/raw-data/*.txt') ?: [];

sort($files);

$days = 0;
$description = '';
$maxDate = false;
$minDate = false;
$observations = 0;
$outputFile = '';
$outputResource = null;
$presidentialObservations = 0;
$slug = null;

// region params

$params = $params ?? ($argv ?? []);

if (is_string($params[1] ?? null) && '' !== trim($params[1])) {
    $minDate = trim($params[1]);
}

if (false !== $minDate && !Utilities::isDateValid($minDate)) {
    echo "'$minDate' is not a valid value for min_date. Expected date formatted as 'Y-m-d'" . PHP_EOL;
    exit(1);
}

if (is_string($params[2] ?? null) && '' !== trim($params[2])) {
    $maxDate = trim($params[2]);
}

if (false !== $maxDate && !Utilities::isDateValid($maxDate)) {
    echo "'$maxDate' is not a valid value for max_date. Expected date formatted as 'Y-m-d'" . PHP_EOL;
    exit(1);
}

$minDateTime = $minDate ? DateTimeImmutable::createFromFormat('Y-m-d', $minDate) : false;
$maxDateTime = $maxDate ? DateTimeImmutable::createFromFormat('Y-m-d', $maxDate) : false;

if ($maxDateTime) {
    $maxDateTime = $maxDateTime->setTime(0, 0);
}

if ($minDateTime) {
    $minDateTime = $minDateTime->setTime(0, 0);
}

// end region

foreach ($files as $file) {
    $basename = basename($file, '.txt');

    $parts = array_pad(explode('-', $basename), 3, '');

    list ($year, $month, $day) = $parts;

    if (!is_numeric($year) || !is_numeric($month) || !is_numeric($day)) {
        continue;
    }

    /** @var DateTimeImmutable $dateTime */
    $dateTime = DateTimeImmutable::createFromFormat('Y-m-d', "$year-$month-$day");
    $dateTime = $dateTime->setTime(0, 0);

    if (($minDateTime && $dateTime < $minDateTime) || ($maxDateTime && $dateTime > $maxDateTime)) {
        continue;
    }

    if ("$year-$month" !== $slug) {
        $slug = "$year-$month";
        $outputFile = sprintf(__DIR__ . '/../data/output/act-blue-%s.csv', $slug);

        if (null !== $outputResource) {
            $percentPresident = sprintf('%g', round($presidentialObservations / ($observations ?: 1), 4) * 100) . '%';
            echo sprintf(
                '%s: %d days, %d observations (%s presidential)%s',
                $description,
                $days,
                $observations,
                $percentPresident,
                PHP_EOL
            );
            fclose($outputResource);
            $outputResource = null;
        }

        $days = 0;
        $description = $dateTime->format('M Y');
        $observations = 0;
        $presidentialObservations = 0;
    }

    $days++;

    /** @var resource $inputResource */
    $inputResource = fopen($file, 'r');

    try {
        if (null === $outputResource) {
            /** @var resource $outputResource */
            $outputResource = fopen($outputFile, 'w');
            if (false == fputcsv($outputResource, $columns)) {
                throw new RuntimeException("There was an error outputting column headers to $outputFile");
            }
        }

        while (false !== ($line = fgets($inputResource))) {
            $rows = json_decode($line, true);

            if (!is_array($rows)) {
                $rows = [];
            }

            foreach ($rows as $row) {
                $data = Utilities::extractDataFromRow($row);

                $reshaped = $template;

                foreach ($data as $key => $value) {
                    if (isset($reshaped[$key])) {
                        $reshaped[$key] = $value;
                        continue;
                    }

                    if (!$skinny) {
                        echo "Warning: unexpected column, '$key'. Try re-generating column data" . PHP_EOL;
                    }
                }

                if (false === fputcsv($outputResource, array_values($reshaped))) {
                    throw new RuntimeException("There was an error outputting data to $outputFile");
                }

                $observations++;

                $candidateId = $data['candidate_id'] ?? null;

                if (is_string($candidateId) && str_starts_with($candidateId, 'P')) {
                    $presidentialObservations++;
                }
            }
        }

        if (!feof($inputResource)) {
            $msg = sprintf('There was an error reading from %s', $file);
            throw new RuntimeException($msg);
        }
    } catch (Throwable $ex) {
        if (null !== $outputResource) {
            fclose($outputResource);
        }

        /** @noinspection PhpUnhandledExceptionInspection */
        throw $ex;
    } finally {
        fclose($inputResource);
    }
}

if (null !== $outputResource) {
    $percentPresident = sprintf('%g', round($presidentialObservations / ($observations ?: 1), 4) * 100) . '%';
    echo sprintf(
        '%s: %d days, %d observations (%s presidential)%s',
        $description,
        $days,
        $observations,
        $percentPresident,
        PHP_EOL
    );
    fclose($outputResource);
}
