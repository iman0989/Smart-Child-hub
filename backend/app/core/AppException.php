<?php

declare(strict_types=1);

namespace SmartChildHub\Core;

use Throwable;

/**
 * Application exception carrying an HTTP status code.
 */
final class AppException extends \RuntimeException
{
    private int $httpStatus;
    private array $errors;

    /**
     * @param array<int|string, mixed> $errors Optional field-level validation errors.
     */
    public function __construct(string $message, int $httpStatus = 400, ?Throwable $previous = null, array $errors = [])
    {
        parent::__construct($message, 0, $previous);
        $this->httpStatus = $httpStatus;
        $this->errors = $errors;
    }

    public function httpStatus(): int
    {
        return $this->httpStatus;
    }

    public function errors(): array
    {
        return $this->errors;
    }
}
