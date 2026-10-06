<?php

declare(strict_types=1);

namespace SmartChildHub\Models;

use SmartChildHub\Config\Config;

/**
 * Child profile model mapper. Matches Flutter ChildModel.
 *
 * PINs are stored as bcrypt hashes in `pin_hash`. Profiles created before that
 * column existed keep their value in `pin`, which is only accepted as a
 * read-only legacy fallback by `verifyPin()`.
 */
final class ChildModel
{
    /**
     * Canonical grade labels the kids zone accepts (Grade 1 - Grade 9).
     *
     * @return list<string>
     */
    public static function grades(): array
    {
        $grades = [];
        for ($grade = Config::CHILD_GRADE_MIN; $grade <= Config::CHILD_GRADE_MAX; $grade++) {
            $grades[] = 'Grade ' . $grade;
        }
        return $grades;
    }

    /**
     * Normalize a parent-entered grade to its canonical label.
     *
     * Accepts the canonical "Grade 4" plus the shorthands that are already
     * present in the data ("4", "grade 4", "G4", " grade 4 "). Anything that
     * is not a grade between Grade 1 and Grade 9 returns null, which callers
     * surface as a validation error.
     */
    public static function normalizeGrade(string $raw): ?string
    {
        $cleaned = mb_strtolower(trim($raw));
        $cleaned = preg_replace('/^(grade|g)\s*/', '', $cleaned) ?? $cleaned;
        $cleaned = trim($cleaned);

        if (preg_match('/^(\d{1,2})$/', $cleaned, $matches) !== 1) {
            return null;
        }

        $grade = (int) $matches[1];
        if ($grade < Config::CHILD_GRADE_MIN || $grade > Config::CHILD_GRADE_MAX) {
            return null;
        }

        return 'Grade ' . $grade;
    }

    /**
     * True when the age is inside the supported 4 - 14 range.
     */
    public static function isValidAge(mixed $age): bool
    {
        if (!is_numeric($age) || (int) $age != $age) {
            return false;
        }
        $age = (int) $age;
        return $age >= Config::CHILD_AGE_MIN && $age <= Config::CHILD_AGE_MAX;
    }

    /**
     * Whether the profile has a PIN, from either the hash or a legacy value.
     */
    public static function hasPin(array $child): bool
    {
        return trim((string) ($child['pin_hash'] ?? '')) !== ''
            || trim((string) ($child['pin'] ?? '')) !== '';
    }

    /**
     * Verify a submitted 4-digit PIN against the stored credential.
     */
    public static function verifyPin(array $child, string $pin): bool
    {
        $hash = trim((string) ($child['pin_hash'] ?? ''));
        if ($hash !== '') {
            return password_verify($pin, $hash);
        }

        $legacy = trim((string) ($child['pin'] ?? ''));
        return $legacy !== '' && hash_equals($legacy, $pin);
    }

    /**
     * Column values that replace a PIN: the plain column is emptied so a
     * readable value never lingers once a hash exists.
     *
     * @return array{pin: string, pin_hash: string}
     */
    public static function pinColumns(string $pin): array
    {
        return [
            'pin'      => '',
            'pin_hash' => password_hash($pin, PASSWORD_DEFAULT),
        ];
    }

    public static function fromRow(array $r): array
    {
        return [
            'id'         => $r['id'],
            'name'       => $r['name'],
            'age'        => (int) $r['age'],
            'grade'      => $r['grade'],
            'aboutChild' => $r['about_child'] ?? ($r['school'] ?? ''),
            'avatarKey'  => $r['avatar_key'],
            'photoUrl'   => $r['photo_url'] ?? '',
            'hasPin'     => self::hasPin($r),
            'coins'      => (int) $r['coins'],
            'streakDays' => (int) $r['streak_days'],
        ];
    }

    /**
     * Normalize validated input into DB column values.
     *
     * `photo_url` is deliberately absent: the photo can only be changed through
     * the upload/remove endpoints, which validate the bytes they store. Letting
     * it flow through a normal update would let a caller write an arbitrary URL
     * and bypass that validation entirely.
     */
    public static function toColumns(array $d): array
    {
        return [
            'name'        => trim((string) ($d['name'] ?? '')),
            'age'         => (int) ($d['age'] ?? 0),
            'grade'       => trim((string) ($d['grade'] ?? '')),
            'about_child' => trim((string) ($d['aboutChild'] ?? '')),
            'avatar_key'  => trim((string) ($d['avatarKey'] ?? 'sunshine')),
            'coins'       => (int) ($d['coins'] ?? 0),
            'streak_days' => (int) ($d['streakDays'] ?? 0),
        ];
    }
}