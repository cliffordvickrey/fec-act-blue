#!/usr/bin/env php
<?php

declare(strict_types=1);

ini_set('max_execution_time', '0');

chdir(__DIR__);

require_once __DIR__ . '/../vendor/autoload.php';

echo 'What would you like to do?' . PHP_EOL;
echo '[1] Read FEC data from the OpenFEC API' . PHP_EOL;
echo '[2] Generate CSV files already fetched from the OpenFEC API' . PHP_EOL;
echo '[3] Regenerate all possible CSV columns using data already fetched from the OpenFEC API' . PHP_EOL;

$valid = false;
do {
    echo ': ';
    $input = fgets(STDIN);

    if (false === $input) {
        throw new RuntimeException('Could not fetch user input');
    }

    $input = trim($input);

    if (in_array($input, ['1', '2', '3'])) {
        $valid = true;
    } else {
        echo 'Invalid response' . PHP_EOL;
    }
} while (!$valid);

switch ($input) {
    case '1':
        $params = [];

        $valid = false;

        do {
            echo 'Minimum contribution date (YYYY-MM-DD): ';
            $input = fgets(STDIN);

            if (false === $input) {
                throw new RuntimeException('Could not fetch user input');
            }

            $input = trim($input);

            $minDate = DateTimeImmutable::createFromFormat('Y-m-d', $input);

            if (false !== $minDate) {
                $valid = true;
            } else {
                echo 'Invalid date' . PHP_EOL;
            }
        } while (!$valid);

        $params[] = $minDate->format('Y-m-d');

        $valid = false;

        do {
            echo 'Maximum contribution date (YYYY-MM-DD): ';
            $input = fgets(STDIN);

            if (false === $input) {
                throw new RuntimeException('Could not fetch user input');
            }

            $input = trim($input);

            $maxDate = DateTimeImmutable::createFromFormat('Y-m-d', $input);

            if (false !== $maxDate && $maxDate >= $minDate) {
                $valid = true;
            } elseif (false !== $maxDate) {
                echo 'Maximum date must be equal to or greater than the minimum date' . PHP_EOL;
            } else {
                echo 'Invalid date' . PHP_EOL;
            }
        } while (!$valid);

        /** @var DateTimeImmutable $maxDate */
        $params[] = $maxDate->format('Y-m-d');

        /**
         * @param list<mixed> $params
         * @param list<mixed> $cliParams
         * @return never
         */
        $readClosure = function (array $params, array $cliParams): never {
            array_unshift($params, $cliParams[0] ?? '');
            require __DIR__ . '/read.php';
            exit(0);
        };

        call_user_func($readClosure, $params, $argv ?? []);

        break;
    case '2':
        call_user_func(function (): never {
            echo 'Generating output CSVs (this may take a while!)' . PHP_EOL;
            require __DIR__ . '/output.php';
            echo 'Done!' . PHP_EOL;
            exit(0);
        });
        break;
    default:
        call_user_func(function (): never {
            echo 'Generating column definition (this may take a while!)' . PHP_EOL;
            require __DIR__ . '/generate-columns.php';
            echo 'Done!' . PHP_EOL;
            exit(0);
        });
}
