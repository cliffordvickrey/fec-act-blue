<?php

declare(strict_types=1);

namespace CliffordVickrey\FecActBlue;

use Generator;
use InvalidArgumentException;
use RuntimeException;

use function fclose;
use function feof;
use function fgetcsv;
use function fopen;
use function is_string;
use function sprintf;

final class CsvReader
{
    private string $filename;

    /**
     * @param string $filename
     */
    public function __construct(string $filename)
    {
        $this->filename = $filename;
    }

    /**
     * @return Generator<Contributor>
     */
    public function read(): Generator
    {
        $csvResource = fopen($this->filename, 'r');

        if (false === $csvResource) {
            throw new InvalidArgumentException(sprintf('File "%s" not readable', $this->filename));
        }

        try {
            while (false !== ($row = fgetcsv($csvResource))) {
                if (($row[0] ?? null) === 'hash') {
                    continue;
                }

                yield Contributor::fromRow($row);
            }

            if (!feof($csvResource)) {
                throw new RuntimeException('Could not read from CSV');
            }
        } finally {
            fclose($csvResource);
        }
    }

    /**
     * @return Generator<array{0: string, 1: string}>
     */
    public function readGroupData(): Generator
    {
        $csvResource = fopen($this->filename, 'r');

        if (false === $csvResource) {
            throw new InvalidArgumentException(sprintf('File "%s" not readable', $this->filename));
        }

        try {
            while (false !== ($row = fgetcsv($csvResource))) {
                $rowParsed = [0 => '', 1 => ''];

                $hash = $row[0] ?? null;

                if ('hash' === $hash) {
                    continue;
                }

                if (is_string($hash)) {
                    $rowParsed[0] = $hash;
                }

                $group = $row[1] ?? null;

                if (is_string($group)) {
                    $rowParsed[1] = $group;
                }

                yield $rowParsed;
            }

            if (!feof($csvResource)) {
                throw new RuntimeException('Could not read from CSV');
            }
        } finally {
            fclose($csvResource);
        }
    }
}
