#!/usr/bin/env php
<?php

declare(strict_types=1);

use CliffordVickrey\FecActBlue\Utilities;

ini_set('max_execution_time', '0');

chdir(__DIR__);

require_once __DIR__ . '/../vendor/autoload.php';

$columnsFile = __DIR__ . '/../data/columns.json';

if (!is_file($columnsFile)) {
    require __DIR__ . '/generate-columns.php';
}

$columnsJson = (string)file_get_contents($columnsFile);

/** @var string[] $columns */
$columns = json_decode($columnsJson, true) ?: [];

if (0 === count($columns)) {
    throw new RuntimeException('Could not parse column information');
}

$template = array_combine($columns, array_fill(0, count($columns), ''));

$files = glob(__DIR__ . '/../data/raw-data/*.txt') ?: [];

sort($files);

$outputFile = '';
$outputResource = null;
$slug = null;

foreach ($files as $file) {
    $basename = basename($file, '.txt');

    $parts = array_pad(explode('-', $basename), 2, '');

    list ($year, $month) = $parts;

    if (!is_numeric($year) || !is_numeric($month)) {
        continue;
    }

    if ("$year-$month" !== $slug) {
        $slug = "$year-$month";
        $outputFile = sprintf(__DIR__ . '/../data/output/act-blue-%s.csv', $slug);

        if (null !== $outputResource) {
            fclose($outputResource);
            $outputResource = null;
        }
    }

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

                    throw new UnexpectedValueException("Unexpected column, '$key'");
                }

                if (false === fputcsv($outputResource, array_values($reshaped))) {
                    throw new RuntimeException("There was an error outputting data $outputFile");
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
    fclose($outputResource);
}
