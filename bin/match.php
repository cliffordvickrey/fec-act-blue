#!/usr/bin/env php
<?php

declare(strict_types=1);

use CliffordVickrey\FecActBlue\Comparison;
use CliffordVickrey\FecActBlue\ComparisonOptions;
use CliffordVickrey\FecActBlue\ContributorIterator;

ini_set('max_execution_time', '0');
ini_set('memory_limit', '-1');

chdir(__DIR__);

require_once __DIR__ . '/../vendor/autoload.php';

$options = new ComparisonOptions();

$iterator = new ContributorIterator();
$generator = $iterator->getCsvGenerator();

/** @var resource $resource */
$resource = fopen(__DIR__ . '/../data/match/person-ids.csv', 'w');
fputcsv($resource, ['id', 'person_id', 'similarity', 'info']);

$personId = 0;

try {
    foreach ($generator as $a) {
        $matches = [];

        echo '-----------------------------------' . PHP_EOL;
        echo $a . PHP_EOL;
        echo '-----------------------------------' . PHP_EOL;

        foreach ($iterator as $b) {
            $comparison = Comparison::fromDyad($a, $b, $options);

            if ($comparison->percent >= $options->threshold) {
                echo $comparison . PHP_EOL;
                $matches[] = $comparison;
                $iterator->deleteCurrent();
            }
        }

        if (0 === count($matches)) {
            continue;
        }

        $personId++;

        foreach ($matches as $match) {
            $info = preg_replace(
                '/^#' . preg_quote($match->contributor->id, '/') . '\s-\s/',
                '',
                (string)$match->contributor
            );

            if (false === fputcsv($resource, [$match->contributor->id, $personId, $match->percent, $info])) {
                throw new RuntimeException('Could not write to CSV');
            }
        }
    }
} finally {
    fclose($resource);
}
