#!/usr/bin/env php
<?php

declare(strict_types=1);

use CliffordVickrey\FecActBlue\Comparison;
use CliffordVickrey\FecActBlue\ComparisonOptions;
use CliffordVickrey\FecActBlue\Contributor;
use CliffordVickrey\FecActBlue\CsvReader;

ini_set('max_execution_time', '0');
ini_set('memory_limit', '-1');

chdir(__DIR__);

require_once __DIR__ . '/../vendor/autoload.php';

$options = new ComparisonOptions();
$reader = new CsvReader(__DIR__ . '/../data/match/raw.csv');
$generator = $reader->read();

$contributorsByHash = []; // contributors grouped by surname hash
$uniqueContributors = []; // truly unique contributors
$surnameHashes = []; // surname to hash

// get identical contributors
foreach ($generator as $contributor) {
    $hash = $contributor->toHash();

    if (isset($uniqueContributors[$hash])) {
        continue;
    }

    $uniqueContributors[$hash] = $contributor;
    $surnameHashes[$contributor->surname] = '';
}

$uniqueContributorCount = count($uniqueContributors);

// list of unique surnames
ksort($surnameHashes);
$uniqueSurnames = array_keys($surnameHashes);

// group similar surnames by unique hash

/** @var resource $resourceSurnames */
$resourceSurnames = fopen(__DIR__ . '/../data/match/match-surnames.csv', 'w');

try {
    fputcsv($resourceSurnames, ['hash', 'surname']);

    foreach ($uniqueSurnames as $surname) {
        if ('' !== $surnameHashes[$surname]) {
            continue;
        }

        $surnameHash = md5($surname);

        $surnameMatches = [];

        foreach ($uniqueSurnames as $i => $surnameToMatch) {
            similar_text($surname, $surnameToMatch, $percentMatch);
            if ($percentMatch >= $options->minimumSurnameSimilarity) {
                $surnameMatches[] = $surnameToMatch;
                unset($uniqueSurnames[$i]);
            }
        }

        foreach ($surnameMatches as $surnameMatch) {
            if (false === fputcsv($resourceSurnames, [$surnameHash, $surnameMatch])) {
                throw new RuntimeException('Could not write to surname CSV');
            }

            $surnameHashes[$surnameMatch] = $surnameHash;
        }
    }
} finally {
    fclose($resourceSurnames);
}

unset($uniqueSurnames);
ksort($surnameHashes);

// group contributors by surname hash
foreach ($uniqueContributors as $hash => $contributor) {
    $surnameHash = $surnameHashes[$contributor->surname];

    if (!isset($contributorsByHash[$surnameHash])) {
        $contributorsByHash[$surnameHash] = [];
    }

    $contributorsByHash[$surnameHash][] = $contributor;

    unset($uniqueContributors[$hash]);
}

echo sprintf(
    '%d unique contributors with %d unique surnames grouped into %d chunks' . PHP_EOL,
    $uniqueContributorCount,
    count($surnameHashes),
    count($contributorsByHash)
);

echo 'Let them matching begin!' . PHP_EOL;

unset($uniqueContributors, $uniqueContributorCount);

$i = 0;
/** @var array<string, array{0: Contributor|string, 1: int}> $memo */
$memo = [];

/** @var resource $resource */
$resource = fopen(__DIR__ . '/../data/match/donor-ids.csv', 'w');
/** @var resource $resourcePartial */
$resourcePartial = fopen(__DIR__ . '/../data/match/partial-matches.csv', 'w');

$startTime = microtime(true);

try {
    fputcsv($resource, ['id', 'donor_id', 'similarity', 'info']);
    fputcsv($resourcePartial, ['similarity', 'info_a', 'info_b', 'hash_a', 'hash_b']);

    $generator = $reader->read();

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
            $surnameHash = $surnameHashes[$a->surname];
            $possibleMatches = $contributorsByHash[$surnameHash];

            foreach ($possibleMatches as $ii => $b) {
                similar_text($a->name, $b->name, $pct);

                if ($pct < $options->minimumNameSimilarity) {
                    continue;
                }

                $comparison = Comparison::fromDyad($a, $b, $options);

                if ($comparison->percent >= $options->threshold) {
                    $matches[] = $comparison;
                    unset($possibleMatches[$ii]);
                }
            }

            if (0 === count($possibleMatches)) {
                unset($surnameHashes[$a->surname], $contributorsByHash[$surnameHash]);
            } else {
                $contributorsByHash[$surnameHash] = $possibleMatches;
            }

            if (0 === count($matches)) {
                continue;
            }

            $i++;
            $personId = $i;

            if (!($personId % 10000)) {
                echo sprintf('10,000 IDs created in %g seconds', microtime(true) - $startTime);
                echo sprintf(' (memory allocated: %d bytes)', memory_get_usage()) . PHP_EOL;
                $startTime = microtime(true);
            }

            foreach ($matches as $match) {
                $matchHash = $match->contributor->toHash();

                if (isset($memo[$matchHash])) {
                    continue;
                }

                if ($match->percent >= 1.0) { // exact match: store ID
                    $memo[$matchHash] = [$a->id, $personId];
                    continue;
                }

                $infoA = preg_replace('/^#' . preg_quote($a->id, '/') . '\s-\s/', '', (string)$a);
                $b = $match->contributor;
                $infoB = preg_replace('/^#' . preg_quote($b->id, '/') . '\s-\s/', '', (string)$b);

                $partialRow = [$infoA, $infoB, $match->percent, $hash, $matchHash];

                if (false === fputcsv($resourcePartial, $partialRow)) {
                    throw new RuntimeException('Could not write to partial match CSV');
                }

                // partial match: store object
                $memo[$matchHash] = [clone $a, $personId];
            }

            $matches = array_slice($matches, 0, 1);
        }

        foreach ($matches as $match) {
            $b = $match->contributor;

            $info = preg_replace('/^#' . preg_quote($b->id, '/') . '\s-\s/', '', (string)$b);

            if (false === fputcsv($resource, [$match->contributor->id, $personId, $match->percent, $info])) {
                throw new RuntimeException('Could not write to output CSV');
            }
        }
    }
} finally {
    fclose($resource);
    fclose($resourcePartial);
}
