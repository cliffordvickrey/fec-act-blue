#!/usr/bin/env php
<?php

declare(strict_types=1);

use CliffordVickrey\FecActBlue\Comparison;
use CliffordVickrey\FecActBlue\ComparisonOptions;
use CliffordVickrey\FecActBlue\Contributor;
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

$i = 0;
/** @var array<string, array{0: Contributor|string, 1: int}> $memo */
$memo = [];

try {
    foreach ($generator as $a) {
        $matches = [];

        $hash = $a->toHash();

        if (isset($memo[$hash])) {
            $cache = $memo[$hash];
            list ($contributor, $personId) = $cache;

            if ($contributor instanceof Contributor) {
                $b = $contributor;
            } else {
                $b = clone $a;
                $b->id = $contributor;
            }

            $comparison = Comparison::fromDyad($b, $a, $options);

            $matches[] = $comparison;
        } else {
            foreach ($iterator as $b) {
                $comparison = Comparison::fromDyad($a, $b, $options);

                if ($comparison->percent >= $options->threshold) {
                    $matches[] = $comparison;
                    $iterator->deleteCurrent();
                }
            }

            if (0 === count($matches)) {
                continue;
            }

            $i++;
            $personId = $i;

            foreach ($matches as $match) {
                $hash = $match->contributor->toHash();

                if (isset($memo[$hash])) {
                    continue;
                }

                if ($match->percent >= 1.0) { // exact match: store ID
                    $memo[$hash] = [$a->id, $personId];
                    continue;
                }

                echo '--------------------' . PHP_EOL;
                echo '- Imperfect match: -' . PHP_EOL;
                echo '--------------------' . PHP_EOL;
                echo 'A     = ' . $a . PHP_EOL;
                echo 'B     = ' . $match->contributor . PHP_EOL;
                echo 'Match = ' . number_format(round($match->percent * 100, 2), 2) . '%' . PHP_EOL;

                // partial match: store object
                $memo[$hash] = [clone $a, $personId];
            }

            $matches = array_slice($matches, 0, 1);
        }

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
