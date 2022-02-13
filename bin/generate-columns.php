#!/usr/bin/env php
<?php

declare(strict_types=1);

use CliffordVickrey\FecActBlue\Utilities;

ini_set('max_execution_time', '0');

chdir(__DIR__);

require_once __DIR__ . '/../vendor/autoload.php';

$files = glob(__DIR__ . '/../data/raw-data/*.txt') ?: [];

sort($files);

$columns = [];

foreach ($files as $file) {
    /** @var resource $resource */
    $resource = fopen($file, 'r');

    try {
        while (false !== ($line = fgets($resource))) {
            $rows = json_decode($line, true);

            if (!is_array($rows)) {
                $rows = [];
            }

            foreach ($rows as $row) {
                $columns = array_values(array_unique(array_merge($columns, Utilities::extractColumnsFromRow($row))));
            }
        }

        if (!feof($resource)) {
            $msg = sprintf('There was an error reading from %s', $file);
            throw new RuntimeException($msg);
        }
    } finally {
        fclose($resource);
    }
}

natsort($columns);
file_put_contents(__DIR__ . '/../data/columns.json', json_encode(array_values($columns), JSON_PRETTY_PRINT));
