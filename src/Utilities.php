<?php

/** @noinspection PhpPluralMixedCanBeReplacedWithArrayInspection */

declare(strict_types=1);

namespace CliffordVickrey\FecActBlue;

use DateTimeImmutable;

use function array_merge;
use function is_array;
use function is_scalar;
use function is_string;
use function ksort;
use function strlen;
use function substr;

final class Utilities
{
    /**
     * Flattens a JSON payload
     * @param array<string, mixed> $row
     * @param string $root
     * @return array<string, scalar>
     * @noinspection PhpDocSignatureInspection
     */
    public static function extractDataFromRow(array $row, string $root = ''): array
    {
        $data = [];

        foreach ($row as $key => $value) {
            if (is_array($value)) {
                $data = array_merge($data, self::extractDataFromRow($value, $root . $key . '__'));
                continue;
            }

            if (!is_scalar($value)) {
                $value = '';
            }

            $data[$root . $key] = $value;
        }

        return $data;
    }

    /**
     * Get a flattened column list from payload JSON
     * @param array<mixed> $row
     * @param string $root
     * @return string[]
     */
    public static function extractColumnsFromRow(array $row, string $root = ''): array
    {
        $columns = [];

        foreach ($row as $key => $value) {
            if (is_array($value)) {
                $columns = array_merge($columns, self::extractColumnsFromRow($value, $root . $key . '__'));
            } else {
                $columns[] = $root . $key;
            }
        }

        return $columns;
    }

    /**
     * @param string $value
     * @return bool
     */
    public static function isDateValid(string $value): bool
    {
        return false !== DateTimeImmutable::createFromFormat('Y-m-d', $value);
    }

    /**
     * Groups results by contribution receipt date
     * @param array<string, list<array<string, mixed>>> $carry
     * @param mixed $row
     * @return array<string, list<array<string, mixed>>>
     */
    public static function groupResultsByContributionReceiptDate(array $carry, mixed $row): array
    {
        if (!is_array($row)) {
            return $carry;
        }

        $contributionReceiptDate = self::parseDate($row['contribution_receipt_date'] ?? null);

        if (null === $contributionReceiptDate) {
            return $carry;
        }

        if (!isset($carry[$contributionReceiptDate])) {
            $carry[$contributionReceiptDate] = [$row];
            ksort($carry);
        } else {
            $carry[$contributionReceiptDate][] = $row;
        }

        return $carry;
    }

    /**
     * Normalizes the contribution recipient date in FEC data
     * @param mixed $value
     * @return string|null
     */
    public static function parseDate(mixed $value): ?string
    {
        if (!is_string($value)) {
            return null;
        }

        if (strlen($value) < 10) {
            return null;
        }

        return substr($value, 0, 10);
    }
}
