<?php

declare(strict_types=1);

namespace App\Validators;

class Validator
{
    private array $errors = [];

    public function validate(array $data, array $rules): bool
    {
        $this->errors = [];

        foreach ($rules as $field => $ruleSet) {
            $value = $data[$field] ?? null;
            $ruleList = is_string($ruleSet) ? explode('|', $ruleSet) : $ruleSet;

            foreach ($ruleList as $rule) {
                $this->applyRule($field, $value, $rule, $data);
            }
        }

        return empty($this->errors);
    }

    public function errors(): array
    {
        return $this->errors;
    }

    private function applyRule(string $field, mixed $value, string $rule, array $data): void
    {
        if (str_contains($rule, ':')) {
            [$rule, $param] = explode(':', $rule, 2);
        } else {
            $param = null;
        }

        match ($rule) {
            'required' => $this->required($field, $value),
            'email' => $this->email($field, $value),
            'min' => $this->min($field, $value, (int) $param),
            'max' => $this->max($field, $value, (int) $param),
            'digits' => $this->digits($field, $value, (int) $param),
            'uuid' => $this->uuid($field, $value),
            'integer' => $this->integer($field, $value),
            'confirmed' => $this->confirmed($field, $value, $data),
            default => null,
        };
    }

    private function required(string $field, mixed $value): void
    {
        if ($value === null || $value === '') {
            $this->errors[$field][] = "{$field} is required";
        }
    }

    private function email(string $field, mixed $value): void
    {
        if ($value && !filter_var($value, FILTER_VALIDATE_EMAIL)) {
            $this->errors[$field][] = "{$field} must be a valid email";
        }
    }

    private function min(string $field, mixed $value, int $min): void
    {
        if ($value && strlen((string) $value) < $min) {
            $this->errors[$field][] = "{$field} must be at least {$min} characters";
        }
    }

    private function max(string $field, mixed $value, int $max): void
    {
        if ($value && strlen((string) $value) > $max) {
            $this->errors[$field][] = "{$field} must not exceed {$max} characters";
        }
    }

    private function digits(string $field, mixed $value, int $length): void
    {
        if ($value === null || $value === '') {
            return;
        }
        if (!preg_match('/^\d{' . $length . '}$/', (string) $value)) {
            $this->errors[$field][] = "{$field} must be exactly {$length} digits";
        }
    }

    private function uuid(string $field, mixed $value): void
    {
        if ($value && !preg_match('/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i', (string) $value)) {
            $this->errors[$field][] = "{$field} must be a valid UUID";
        }
    }

    private function integer(string $field, mixed $value): void
    {
        if ($value !== null && !is_numeric($value)) {
            $this->errors[$field][] = "{$field} must be an integer";
        }
    }

    private function confirmed(string $field, mixed $value, array $data): void
    {
        if ($value !== ($data["{$field}_confirmation"] ?? null)) {
            $this->errors[$field][] = "{$field} confirmation does not match";
        }
    }
}
