<?php

/** @noinspection PhpMultipleClassDeclarationsInspection */

declare(strict_types=1);

namespace CliffordVickrey\FecActBlue;

use Stringable;

use function round;
use function similar_text;

final class Comparison implements Stringable
{
    public Contributor $contributor;
    public float $percent;

    /**
     * @param Contributor $contributor
     * @param float $percent
     */
    public function __construct(Contributor $contributor, float $percent)
    {
        $this->contributor = $contributor;
        $this->percent = $percent;
    }

    /**
     * @param Contributor $a
     * @param Contributor $b
     * @param ComparisonOptions|null $matchingOptions
     * @return self
     */
    public static function fromDyad(
        Contributor $a,
        Contributor $b,
        ?ComparisonOptions $matchingOptions = null
    ): self {
        if ($a->id === $b->id) {
            return new self($b, 1.0);
        }

        if (null === $matchingOptions) {
            $matchingOptions = new ComparisonOptions();
        }

        similar_text($a->name, $b->name, $namePct);

        $percent = ($namePct / 100) * $matchingOptions->nameFactor;

        $localePercent = 0.0;

        if ($a->state === $b->state && $a->city === $b->city) {
            $localePercent += 0.35;
        }

        if (
            $a->zip === $b->zip
            && !('' !== $a->zipPlusFour && '' !== $b->zipPlusFour && $a->zipPlusFour !== $b->zipPlusFour)
        ) {
            $localePercent += 0.45;
        }

        similar_text($a->address, $b->address, $addressPercent);

        $localePercent += (($addressPercent / 100) * 0.20);

        $percent += ($localePercent * $matchingOptions->localeFactor);

        $occupationPercent = 0.0;

        if ('' !== $a->occupation && '' !== $b->occupation) {
            similar_text($a->occupation, $b->occupation, $occupationPercent);
        }

        $percent += (($occupationPercent / 100) * $matchingOptions->occupationFactor);

        $employerPercent = 0.0;

        if ('' !== $a->employer && '' !== $b->employer) {
            similar_text($a->employer, $b->employer, $employerPercent);
        }

        $percent += (($employerPercent / 100) * $matchingOptions->employerFactor);

        return new self($b, $percent);
    }

    /**
     * @return string
     */
    public function __toString(): string
    {
        return number_format(round($this->percent * 100, 2), 2) . '% match: ' . $this->contributor;
    }
}
