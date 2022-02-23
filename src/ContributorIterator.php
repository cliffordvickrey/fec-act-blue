<?php

declare(strict_types=1);

namespace CliffordVickrey\FecActBlue;

use Generator;
use InvalidArgumentException;
use Iterator;
use RuntimeException;
use UnexpectedValueException;

use function count;
use function current;
use function fclose;
use function feof;
use function fgetcsv;
use function file_put_contents;
use function fopen;
use function is_int;
use function is_string;
use function key;
use function next;
use function reset;
use function sprintf;
use function str_replace;
use function unlink;
use function var_export;

use const DIRECTORY_SEPARATOR;

/**
 * @implements Iterator<string, Contributor>
 */
final class ContributorIterator implements Iterator
{
    private string $filename;
    private string $targetDir;
    /** @var int<0, max> */
    private int $pageCount;
    /** @var array<string, string> */
    private array $pageFilenames = [];
    /** @var array<string, Contributor> */
    private array $chunk;
    /** @var int<0, max> */
    private int $page = 0;
    /** @var string[] */
    private array $idsToDelete = [];

    /**
     * @param string|null $filename
     * @param positive-int $chunkSize
     * @param string|null $targetDir
     */
    public function __construct(?string $filename = null, int $chunkSize = 2000000, ?string $targetDir = null)
    {
        $this->filename = $filename ?? __DIR__ . '/../do/act-blue-contributors.csv';
        $this->targetDir = $targetDir ?? __DIR__ . '/../data/match';

        $this->chunk = [];

        $generator = $this->getCsvGenerator();

        foreach ($generator as $contributor) {
            if (count($this->chunk) > $chunkSize) {
                $this->page++;
                $this->saveChunk();
                $this->chunk = [];
            }

            $this->chunk[$contributor->id] = $contributor;
        }

        if ($this->page > 0 && count($this->chunk) > 0) {
            $this->page++;
            $this->saveChunk();
        }

        $this->pageCount = $this->page;

        $this->rewind();
    }

    /**
     * @return Generator<Contributor>
     */
    public function getCsvGenerator(): Generator
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

    /**
     * @return void
     */
    private function saveChunk(): void
    {
        $key = "p$this->page";

        if (0 === count($this->chunk)) {
            @unlink($this->pageFilenames[$key]);
            unset($this->pageFilenames[$key]);
            return;
        }

        $filename = sprintf('%s%sp%04d', $this->targetDir, DIRECTORY_SEPARATOR, $this->page);

        $php = <<< PHP
<?php

return [];
PHP;
        $contents = str_replace('[]', var_export($this->chunk, true), $php);

        if (false === file_put_contents($filename, $contents)) {
            throw new RuntimeException(sprintf('Could not write to %s', $filename));
        }

        $this->pageFilenames[$key] = $filename;
    }

    /**
     * @return void
     */
    public function rewind(): void
    {
        $this->page = 0;

        if (0 === $this->pageCount) {
            reset($this->chunk);
            return;
        }

        $this->incrementPage();
    }

    /**
     * @return void
     */
    private function incrementPage(): void
    {
        $this->chunk = [];

        if ($this->page >= $this->pageCount) {
            $this->page = $this->pageCount + 1;
            return;
        }

        $j = $this->page + 1;

        for ($i = $j; $i <= $this->pageCount; $i++) {
            if (isset($this->pageFilenames["p$i"])) {
                $this->page = $i;
                $this->loadPage();
                return;
            }
        }

        $this->page = $this->pageCount + 1;
    }

    /**
     * @return void
     */
    private function loadPage(): void
    {
        $this->chunk = require $this->pageFilenames["p$this->page"];
    }

    /**
     * @return void
     */
    public function deleteCurrent(): void
    {
        $this->idsToDelete[] = $this->current()->id;
    }

    /**
     * @return Contributor
     */
    public function current(): Contributor
    {
        $current = current($this->chunk);

        if ($current instanceof Contributor) {
            return $current;
        }

        throw new UnexpectedValueException(sprintf('Expected instance of %s', Contributor::class));
    }

    /**
     * @return void
     */
    public function next(): void
    {
        next($this->chunk);

        if (current($this->chunk) || $this->page < 1) {
            return;
        }

        if (0 !== count($this->idsToDelete)) {
            foreach ($this->idsToDelete as $id) {
                unset($this->chunk[$id]);
            }

            $this->idsToDelete = [];

            $this->saveChunk();
        }

        $this->incrementPage();
    }

    /**
     * @return string
     */
    public function key(): string
    {
        $key = key($this->chunk);

        if (is_int($key)) { // @phpstan-ignore-line
            $key = (string)$key;
        }

        if (!is_string($key)) {
            throw new UnexpectedValueException('Expected key to be string');
        }

        return $key;
    }

    /**
     * @return bool
     */
    public function valid(): bool
    {
        $valid = ($this->pageCount > 0 && $this->page <= $this->pageCount) || !!current($this->chunk);

        if (!$valid && 0 === $this->pageCount) {
            foreach ($this->idsToDelete as $id) {
                unset($this->chunk[$id]);
            }

            $this->idsToDelete = [];
        }

        return $valid;
    }
}
