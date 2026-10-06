<?php

declare(strict_types=1);

namespace SmartChildHub\Core;

use SmartChildHub\Config\Config;

/**
 * Lightweight input validation with field-level error messages.
 *
 * Validation runs on raw request data; values are then filtered/hydrated in
 * each model's `fromArray`. All database access uses prepared statements, so
 * this layer guards shape/type/range rather than SQL injection.
 */
final class Validator
{
    /** @var array<string, string> */
    private array $errors = [];

    /** @var array<string, mixed> */
    private array $data;

    public function __construct(array $data)
    {
        $this->data = $data;
    }

    public function has(string $key): self
    {
        if (!array_key_exists($key, $this->data) || $this->data[$key] === null || $this->data[$key] === '') {
            $this->errors[$key] = 'The ' . str_replace('_', ' ', $key) . ' field is required.';
        }
        return $this;
    }

    public function string(string $key, int $min = 1, int $max = 255): self
    {
        $v = $this->data[$key] ?? null;
        if ($v === null) {
            return $this;
        }
        if (!is_string($v)) {
            $this->errors[$key] = 'The ' . str_replace('_', ' ', $key) . ' field must be a string.';
            return $this;
        }
        $len = mb_strlen(trim($v));
        if ($len < $min) {
            $this->errors[$key] = "The " . str_replace('_', ' ', $key) . " field must be at least $min characters.";
        } elseif ($len > $max) {
            $this->errors[$key] = "The " . str_replace('_', ' ', $key) . " field must not exceed $max characters.";
        }
        return $this;
    }

    public function email(string $key): self
    {
        $v = $this->data[$key] ?? null;
        if ($v === null) {
            return $this;
        }
        if (!is_string($v) || !filter_var($v, FILTER_VALIDATE_EMAIL)) {
            $this->errors[$key] = 'The email address is invalid.';
        }
        return $this;
    }

    public function int(string $key, int $min = 0, int $max = 999999999): self
    {
        $v = $this->data[$key] ?? null;
        if ($v === null) {
            return $this;
        }
        if (!is_numeric($v) || (int) $v != $v) {
            $this->errors[$key] = 'The ' . str_replace('_', ' ', $key) . ' field must be an integer.';
        } elseif ((int) $v < $min || (int) $v > $max) {
            $this->errors[$key] = "The " . str_replace('_', ' ', $key) . " field must be between $min and $max.";
        }
        return $this;
    }

    public function number(string $key, int $min = 0, int $max = 999999): self
    {
        $v = $this->data[$key] ?? null;
        if ($v === null) {
            return $this;
        }
        if (!is_numeric($v) || (float) $v < $min || (float) $v > $max) {
            $this->errors[$key] = "The " . str_replace('_', ' ', $key) . " field must be a number between $min and $max.";
        }
        return $this;
    }

    public function date(string $key, string $format = 'Y-m-d'): self
    {
        $v = $this->data[$key] ?? null;
        if ($v === null) {
            return $this;
        }
        if (!is_string($v)) {
            $this->errors[$key] = 'The ' . str_replace('_', ' ', $key) . ' field must be a valid date.';
            return $this;
        }
        $d = \DateTimeImmutable::createFromFormat($format, $v);
        if ($d === false) {
            $this->errors[$key] = 'The ' . str_replace('_', ' ', $key) . " field must match the format {$format}.";
        }
        return $this;
    }

    public function in(string $key, array $allowed): self
    {
        $v = $this->data[$key] ?? null;
        if ($v === null) {
            return $this;
        }
        if (!in_array((string) $v, $allowed, true)) {
            $this->errors[$key] = 'The ' . str_replace('_', ' ', $key) . ' field must be one of: ' . implode(', ', $allowed) . '.';
        }
        return $this;
    }

    public function pin(string $key): self
    {
        $v = $this->data[$key] ?? null;
        if ($v === null || $v === '') {
            return $this;
        }
        if (!is_string($v) || !preg_match(Config::CHILD_PIN_REGEX, $v)) {
            $this->errors[$key] = 'The PIN must be exactly 4 digits.';
        }
        return $this;
    }

    public function bool(string $key): self
    {
        $v = $this->data[$key] ?? null;
        if ($v === null) {
            return $this;
        }
        if (!is_bool($v) && !in_array((string) $v, ['0', '1', 'true', 'false'], true)) {
            $this->errors[$key] = 'The ' . str_replace('_', ' ', $key) . ' field must be a boolean.';
        }
        return $this;
    }

    public function password(string $key = 'password'): self
    {
        $v = $this->data[$key] ?? null;
        if ($v === null) {
            return $this;
        }
        if (!is_string($v) || strlen($v) < Config::PASSWORD_MIN_LENGTH) {
            $this->errors[$key] = 'The password must be at least ' . Config::PASSWORD_MIN_LENGTH . ' characters.';
        } elseif (strlen($v) > 72) {
            $this->errors[$key] = 'The password must not exceed 72 characters.';
        }
        return $this;
    }

    public function confirmed(string $key, string $confirmation = 'password_confirmation'): self
    {
        $v = $this->data[$key] ?? null;
        $c = $this->data[$confirmation] ?? null;
        if ($v !== null && $v !== $c) {
            $this->errors[$confirmation] = 'The password confirmation does not match.';
        }
        return $this;
    }

    /**
     * Returns true when the request is valid, otherwise throws with all errors.
     */
    public function validate(): void
    {
        if ($this->errors !== []) {
            throw new AppException('Validation failed.', 422, null, $this->errors);
        }
    }

    /**
     * @return array<string, string>
     */
    public function errors(): array
    {
        return $this->errors;
    }
}
