<?php

/** @noinspection PhpPluralMixedCanBeReplacedWithArrayInspection */

declare(strict_types=1);

namespace CliffordVickrey\FecActBlue;

use function array_merge;
use function is_array;
use function is_scalar;

class Utilities
{
    /**
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
}
