#!/usr/bin/env php
<?php

declare(strict_types=1);

use CliffordVickrey\FecActBlue\Comparison;
use CliffordVickrey\FecActBlue\ComparisonOptions;
use CliffordVickrey\FecActBlue\Contributor;
use CliffordVickrey\FecActBlue\CsvReader;
use CliffordVickrey\FecActBlue\CsvWriter;

ini_set('max_execution_time', '0');
ini_set('memory_limit', '-1');

chdir(__DIR__);

require_once __DIR__ . '/../vendor/autoload.php';

$options = new ComparisonOptions();
$reader = new CsvReader(__DIR__ . '/../data/match/raw.csv');
$generator = $reader->read();

$contributorsByHash = []; // contributors grouped by surname hash
$uniqueContributors = []; // truly unique contributors
$stateLookup = []; // memo for storing states by group
$surnameLookup = []; // memo for storing surnames by group
$groupHashes = []; // group to hash

// get identical contributors
foreach ($generator as $contributor) {
    $hash = $contributor->toHash();

    if (isset($uniqueContributors[$hash])) {
        continue;
    }

    $uniqueContributors[$hash] = $contributor;

    // group possible matches (state and surname)
    $group = $contributor->toGroup();
    $groupHashes[$group] = '';
    $stateLookup[$group] = $contributor->state;
    $surnameLookup[$group] = $contributor->surname;
}

$uniqueContributorCount = count($uniqueContributors);

// group similar states/surnames by unique hash

$groupFilename = __DIR__ . '/../data/match/groups.csv';

if (is_file($groupFilename)) {
    // load extant groups
    $groupReader = new CsvReader($groupFilename);

    $groupGenerator = $groupReader->readGroupData();

    $groupHashes = [];

    foreach ($groupGenerator as $groupData) {
        list ($groupHash, $groupMatch) = $groupData;
        $groupHashes[$groupMatch] = $groupHash;
    }
} else {
    // list of unique groups
    ksort($groupHashes);
    $uniqueGroups = array_keys($groupHashes);

    $groupWriter = new CsvWriter($groupFilename);

    try {
        $groupWriter->write(['hash', 'group']);

        foreach ($uniqueGroups as $group) {
            if ('' !== $groupHashes[$group]) {
                continue;
            }

            $groupHash = md5($group);

            $groupMatches = [];
            $state = $stateLookup[$group];
            $surname = $surnameLookup[$group];

            foreach ($uniqueGroups as $i => $groupToMatch) {
                if ($state !== $stateLookup[$groupToMatch]) {
                    break;
                }

                similar_text($surname, $surnameLookup[$groupToMatch], $percentMatch);
                if ($percentMatch >= $options->minimumSurnameSimilarity) {
                    $groupMatches[] = $groupToMatch;
                    unset($uniqueGroups[$i], $stateLookup[$groupToMatch], $surnameLookup[$groupToMatch]);
                }
            }

            foreach ($groupMatches as $groupMatch) {
                $groupWriter->write([$groupHash, $groupMatch]);
                $groupHashes[$groupMatch] = $groupHash;
            }
        }
    } finally {
        $groupWriter->close();
    }
}

unset($uniqueGroups, $stateLookup, $surnameLookup);
ksort($groupHashes);

// group contributors by surname hash
foreach ($uniqueContributors as $hash => $contributor) {
    $groupHash = $groupHashes[$contributor->toGroup()];

    if (!isset($contributorsByHash[$groupHash])) {
        $contributorsByHash[$groupHash] = [];
    }

    $contributorsByHash[$groupHash][] = $contributor;

    unset($uniqueContributors[$hash]);
}

echo sprintf(
    '%d unique contributors separated into %d groups' . PHP_EOL,
    $uniqueContributorCount,
    count($contributorsByHash)
);

echo 'Let the matching begin!' . PHP_EOL;

unset($uniqueContributors, $uniqueContributorCount);

$i = 0;
/** @var array<string, array{0: Contributor|string, 1: int}> $memo */
$memo = [];

$donorIdsWriter = new CsvWriter(__DIR__ . '/../data/match/donor-ids.csv');
$partialMatchesWriter = new CsvWriter(__DIR__ . '/../data/match/partial-matches.csv');

$startTime = microtime(true);

try {
    $donorIdsWriter->write(['id', 'donor_id']);
    $partialMatchesWriter->write(['info_a', 'info_b', 'similarity', 'hash_a', 'hash_b']);

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
            $group = $a->toGroup();
            $groupHash = $groupHashes[$group];
            $possibleMatches = $contributorsByHash[$groupHash];

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
                unset($groupHashes[$group], $contributorsByHash[$groupHash]);
            } else {
                $contributorsByHash[$groupHash] = $possibleMatches;
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
                $partialMatchesWriter->write($partialRow);

                // partial match: store object
                $memo[$matchHash] = [clone $a, $personId];
            }

            $matches = array_slice($matches, 0, 1);
        }

        foreach ($matches as $match) {
            $b = $match->contributor;

            $info = preg_replace('/^#' . preg_quote($b->id, '/') . '\s-\s/', '', (string)$b);

            $donorIdsWriter->write([$match->contributor->id, $personId]);
        }
    }
} finally {
    $donorIdsWriter->close();
    $partialMatchesWriter->close();
}
