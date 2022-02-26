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
                yield Contributor::fromRow($row);
            }

            if (!feof($csvResource)) {
                throw new RuntimeException('Could not read from CSV');
            }
        } finally {
            fclose($csvResource);
        }
    }
}
