<?php

declare(strict_types=1);

namespace CliffordVickrey\FecActBlue;

final class ComparisonOptions
{
    /**
     * Minimum % name similarity for contributors to be a match
     * @var float
     */
    public float $minimumNameSimilarity = 88.0;
    /**
     * Factor by which to multiply name similarity
     * @var float
     */
    public float $nameFactor = 0.55;
    /**
     * Factor by which to multiply locale similarity
     * @var float
     */
    public float $localeFactor = 0.40;
    /**
     * Factor by which to multiply occupation similarity
     * @var float
     */
    public float $occupationFactor = 0.05;
    /**
     * Minimum score to be considered a match
     * @var float
     */
    public float $threshold = .70;
}