<?php

declare(strict_types=1);

namespace CliffordVickrey\FecActBlue;

use RuntimeException;

use function fclose;
use function fopen;
use function fputcsv;
use function is_resource;
use function sprintf;

class CsvWriter
{
    /** @var resource|null */
    private $resource;

    /**
     * @param string $filename
     */
    public function __construct(string $filename)
    {
        $resource = fopen($filename, 'w');

        if (!is_resource($resource)) {
            throw new RuntimeException(sprintf('Could not open %s for writing', $filename));
        }

        $this->resource = $resource;
    }

    /**
     *
     */
    public function __destruct()
    {
        $this->close();
    }

    /**
     * @return void
     */
    public function close(): void
    {
        if (null !== $this->resource) {
            fclose($this->resource);
            $this->resource = null;
        }
    }

    /**
     * @param array<array-key, bool|float|int|string|null> $data
     * @return void
     */
    public function write(array $data): void
    {
        if (null === $this->resource) {
            throw new RuntimeException('Could not write to CSV; resource has been closed');
        }

        if (false === fputcsv($this->resource, $data)) {
            throw new RuntimeException('Could not write to CSV');
        }
    }
}
