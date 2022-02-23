<?php

/** @noinspection PhpMultipleClassDeclarationsInspection */

declare(strict_types=1);

namespace CliffordVickrey\FecActBlue;

use JetBrains\PhpStorm\ArrayShape;
use JetBrains\PhpStorm\Pure;
use Stringable;

use function array_filter;
use function array_map;
use function array_pad;
use function array_values;
use function implode;
use function is_numeric;
use function is_scalar;
use function str_pad;
use function strlen;
use function strtoupper;
use function substr;

use const STR_PAD_LEFT;

final class Contributor implements Stringable
{
    public string $id = '';
    public string $name = '';
    public string $address = '';
    public string $city = '';
    public string $state = '';
    public string $zip = '';
    public string $zipPlusFour = '';
    public string $occupation = '';

    /**
     * @param array<string, mixed> $row
     * @return self
     */
    public static function fromRow(array $row): self
    {
        $self = new self();

        /** @var string[] $data */
        $data = array_pad(
            array_map(fn($value) => is_scalar($value) ? strtoupper(trim((string)$value)) : '', $row),
            7,
            ''
        );

        $self->id = $data[0];
        $self->name = $data[1];
        $self->address = $data[2];
        $self->city = $data[3];
        $self->state = $data[4];
        $zip = $data[5];
        $zipPlus4 = '';

        if (is_numeric($zip) && strlen($zip) > 5) {
            $zipPlus4 = str_pad(substr($zip, 5), 4, '0', STR_PAD_LEFT);
            $zip = substr($zip, 0, 5);
        }

        if (is_numeric($zip)) {
            $zip = str_pad($zip, 5, '0', STR_PAD_LEFT);
        }

        $self->zip = $zip;
        $self->zipPlusFour = $zipPlus4;
        $self->occupation = $data[6];

        return $self;
    }

    /**
     * @param array<string, string> $an_array
     * @return self
     */
    #[Pure]
    public static function __set_state(array $an_array): self
    {
        $self = new self();

        $self->id = $an_array['id'];
        $self->name = $an_array['name'];
        $self->address = $an_array['address'];
        $self->city = $an_array['city'];
        $self->state = $an_array['state'];
        $self->zip = $an_array['zip'];
        $self->zipPlusFour = $an_array['zipPlusFour'];
        $self->occupation = $an_array['occupation'];

        return $self;
    }

    /**
     * @return string
     */
    public function __toString(): string
    {
        $parts = array_values(array_filter([
            "#$this->id",
            '-',
            $this->name,
            '-',
            $this->address . ('' === $this->address && '' === $this->city ? '' : ','),
            $this->city,
            $this->state,
            $this->zip . ('' === $this->zipPlusFour ? '' : "-$this->zipPlusFour"),
            '' === $this->occupation ? '' : "($this->occupation)"
        ]));

        return implode(' ', $parts);
    }

    /**
     * @return array<string, string>
     */
    #[ArrayShape([
        'id' => "string",
        'name' => "string",
        'address' => "string",
        'city' => "string",
        'state' => "string",
        'zip' => "string",
        'zipPlusFour' => "string",
        'occupation' => "string"
    ])]
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'address' => $this->address,
            'city' => $this->city,
            'state' => $this->state,
            'zip' => $this->zip,
            'zipPlusFour' => $this->zip,
            'occupation' => $this->occupation
        ];
    }
}
