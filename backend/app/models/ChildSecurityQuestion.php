<?php

declare(strict_types=1);

namespace SmartChildHub\Models;

use PDO;
use SmartChildHub\Core\AppException;
use SmartChildHub\Core\Auth;

/**
 * Child security questions used for child-specific 4-digit PIN recovery.
 *
 * A parent sets the questions from the add/edit child form. Only the question
 * key is stored in plain text so the child can be shown a question; the answer
 * is normalized and stored as a bcrypt hash and is never returned by any
 * endpoint.
 */
final class ChildSecurityQuestion
{
    /**
     * Neutral, child-friendly questions. Keys are stable API identifiers.
     *
     * Deliberately avoids anything sensitive (address, phone, documents).
     *
     * @var array<string, string>
     */
    public const BANK = [
        'favorite_book'    => 'What is your favorite book?',
        'best_friend'      => 'Who is your best friend?',
        'favorite_animal'  => 'What is your favorite animal?',
        'favorite_food'    => 'What is your favorite food?',
        'favorite_color'   => 'What is your favorite color?',
        'favorite_cartoon' => 'Who is your favorite cartoon character?',
        'birth_city'       => 'Which city were you born in?',
        'teacher_name'     => "What is your teacher's first name?",
        'pet_name'         => 'What is the name of your pet?',
    ];

    /** How many questions a single child may have. */
    public const MAX_PER_CHILD = 2;

    public const MIN_ANSWER_LENGTH = 2;
    public const MAX_ANSWER_LENGTH = 80;

    /**
     * @return array<string, string>
     */
    public static function bank(): array
    {
        return self::BANK;
    }

    public static function questionText(string $key): string
    {
        return self::BANK[$key] ?? 'Security question';
    }

    /**
     * Fold case and collapse whitespace so " Blue " matches "blue".
     */
    public static function normalizeAnswer(string $answer): string
    {
        $normalized = mb_strtolower(trim($answer));
        return preg_replace('/\s+/u', ' ', $normalized) ?? $normalized;
    }

    public static function hashAnswer(string $answer): string
    {
        return password_hash(self::normalizeAnswer($answer), PASSWORD_DEFAULT);
    }

    public static function verifyAnswer(string $answer, string $hash): bool
    {
        return $hash !== '' && password_verify(self::normalizeAnswer($answer), $hash);
    }

    /**
     * Validate the `securityQuestions` payload and return hashed rows ready to
     * store. Accepts a missing/empty list (recovery is optional) but rejects
     * unknown questions, duplicate questions and unusable answers.
     *
     * [existingHashesByKey] lets an edit keep the stored answer: a question that
     * is already configured for the child may be submitted without a new answer,
     * because the parent never sees the old one.
     *
     * @param array<string, string> $existingHashesByKey
     * @return list<array{questionKey: string, answerHash: string}>
     */
    public static function prepare(mixed $input, array $existingHashesByKey = []): array
    {
        if ($input === null || $input === '') {
            return [];
        }

        if (!is_array($input)) {
            throw new AppException(
                'Validation failed.',
                422,
                null,
                ['securityQuestions' => 'Security questions must be a list.']
            );
        }

        // PHP 8.0 compatible list check.
        $isList = array_keys($input) === range(0, count($input) - 1);
        if (!$isList) {
            throw new AppException(
                'Validation failed.',
                422,
                null,
                ['securityQuestions' => 'Security questions must be a list.']
            );
        }

        if (count($input) > self::MAX_PER_CHILD) {
            throw new AppException(
                'Validation failed.',
                422,
                null,
                ['securityQuestions' => 'You can set up to ' . self::MAX_PER_CHILD . ' security questions.']
            );
        }

        $errors = [];
        $prepared = [];
        $seen = [];

        foreach ($input as $index => $entry) {
            $field = 'securityQuestions.' . $index;

            if (!is_array($entry)) {
                $errors[$field] = 'Each security question must be an object.';
                continue;
            }

            $key = trim((string) ($entry['questionKey'] ?? ''));
            $answer = trim((string) ($entry['answer'] ?? ''));

            if ($key === '') {
                $errors[$field] = 'Choose a security question.';
                continue;
            }
            if (!isset(self::BANK[$key])) {
                $errors[$field . '.questionKey'] = 'Choose one of the available security questions.';
                continue;
            }
            if (isset($seen[$key])) {
                $errors[$field . '.questionKey'] = 'Choose a different security question.';
                continue;
            }

            // No new answer: keep the one already stored for this question.
            if ($answer === '') {
                if (!isset($existingHashesByKey[$key])) {
                    $errors[$field] = 'Enter an answer for each security question.';
                    continue;
                }
                $seen[$key] = true;
                $prepared[] = [
                    'questionKey' => $key,
                    'answerHash'  => $existingHashesByKey[$key],
                ];
                continue;
            }

            $length = mb_strlen($answer);
            if ($length < self::MIN_ANSWER_LENGTH) {
                $errors[$field . '.answer'] = 'Answer must be at least ' . self::MIN_ANSWER_LENGTH . ' characters.';
                continue;
            }
            if ($length > self::MAX_ANSWER_LENGTH) {
                $errors[$field . '.answer'] = 'Answer must not exceed ' . self::MAX_ANSWER_LENGTH . ' characters.';
                continue;
            }

            $seen[$key] = true;
            $prepared[] = [
                'questionKey' => $key,
                'answerHash'  => self::hashAnswer($answer),
            ];
        }

        if ($errors !== []) {
            throw new AppException('Validation failed.', 422, null, $errors);
        }

        return $prepared;
    }

    /**
     * Question keys configured for a child (no answers, safe to show a parent).
     *
     * @return list<string>
     */
    public static function keysForChild(PDO $db, string $childId): array
    {
        return array_keys(self::hashesForChild($db, $childId));
    }

    /**
     * Stored answer hashes keyed by question key, used so an edit can keep an
     * answer the parent never sees.
     *
     * @return array<string, string>
     */
    public static function hashesForChild(PDO $db, string $childId): array
    {
        $stmt = $db->prepare(
            'SELECT question_key, answer_hash FROM child_security_questions
             WHERE child_id = ? ORDER BY sort_order ASC, created_at ASC'
        );
        $stmt->execute([$childId]);

        $hashes = [];
        foreach ($stmt->fetchAll() as $row) {
            $hashes[(string) $row['question_key']] = (string) $row['answer_hash'];
        }
        return $hashes;
    }

    /**
     * Full rows (question key + answer hash) used only for verification.
     *
     * @return list<array{question_key: string, answer_hash: string}>
     */
    public static function rowsForChild(PDO $db, string $childId): array
    {
        $stmt = $db->prepare(
            'SELECT question_key, answer_hash FROM child_security_questions
             WHERE child_id = ? ORDER BY sort_order ASC, created_at ASC'
        );
        $stmt->execute([$childId]);

        return $stmt->fetchAll();
    }

    /**
     * Replace a child's security questions with the given hashed entries.
     *
     * @param list<array{questionKey: string, answerHash: string}> $entries
     */
    public static function replaceForChild(PDO $db, string $childId, array $entries): void
    {
        $db->prepare('DELETE FROM child_security_questions WHERE child_id = ?')->execute([$childId]);

        if ($entries === []) {
            return;
        }

        $stmt = $db->prepare(
            'INSERT INTO child_security_questions (id, child_id, question_key, answer_hash, sort_order)
             VALUES (?, ?, ?, ?, ?)'
        );

        $sortOrder = 0;
        foreach ($entries as $entry) {
            $stmt->execute([Auth::uuid(), $childId, $entry['questionKey'], $entry['answerHash'], $sortOrder++]);
        }
    }

    public static function deleteForChild(PDO $db, string $childId): void
    {
        $db->prepare('DELETE FROM child_security_questions WHERE child_id = ?')->execute([$childId]);
    }
}