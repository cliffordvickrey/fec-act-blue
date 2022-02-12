#!/usr/bin/env php
<?php

declare(strict_types=1);

use CliffordVickrey\FecActBlue\Utilities;

ini_set('max_execution_time', '0');

chdir(__DIR__);

require_once __DIR__ . '/../vendor/autoload.php';

$chunks = 0;
$sizeInChunk = 0;
$sizePerChunk = 10000;

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

$outputResource = null;

foreach ($files as $file) {
    /** @var resource $resource */
    $resource = fopen($file, 'r');

    while (false !== ($line = fgets($resource))) {
        $rows = json_decode($line, true);

        if (!is_array($rows)) {
            $rows = [];
        }

        foreach ($rows as $row) {
            $data = Utilities::extractDataFromRow($row);

            if ($sizeInChunk > $sizePerChunk) {
                if (null !== $outputResource) {
                    fclose($outputResource);
                }

                $outputResource = null;
                $sizeInChunk = 0;
            }

            if (null === $outputResource) {
                /** @var resource $outputResource */
                $outputResource = fopen(sprintf(__DIR__ . '/../data/output/chunk%04d.csv', ++$chunks), 'w');
                if (false == fputcsv($outputResource, $columns)) {
                    throw new RuntimeException('There was an error outputting to a CSV file');
                }
            }

            $reshaped = $template;

            foreach ($data as $key => $value) {
                if (isset($reshaped[$key])) {
                    $reshaped[$key] = $value;
                }
            }

            if (false === fputcsv($outputResource, array_values($reshaped))) {
                throw new RuntimeException('There was an error outputting to a CSV file');
            }

            $sizeInChunk++;
        }
    }

    if (!feof($resource)) {
        $msg = sprintf('There was an error reading from %s', $file);
        throw new RuntimeException($msg);
    }

    fclose($resource);
}

if (null !== $outputResource) {
    fclose($outputResource);
}
