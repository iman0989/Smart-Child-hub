-- =============================================================================
-- Smart Child Daily Activity Tracking System
-- Database schema (MySQL 5.7+ / MariaDB 10.4+)
-- Charset: utf8mb4  |  Storage: InnoDB
-- =============================================================================

CREATE DATABASE IF NOT EXISTS `smart_child_hub`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `smart_child_hub`;

-- -----------------------------------------------------------------------------
-- 1. Parents (account owner)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `parents` (
  `id`            CHAR(36)      NOT NULL,
  `full_name`     VARCHAR(120)  NOT NULL,
  `email`         VARCHAR(190)  NOT NULL,
  `phone`         VARCHAR(32)   NOT NULL DEFAULT '',
  `password_hash` VARCHAR(255)  NOT NULL,
  `avatar_key`    VARCHAR(32)   NOT NULL DEFAULT 'grape',
  `created_at`    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_parents_email` (`email`),
  INDEX `idx_parents_email` (`email`)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 2. Children (profiles under a parent)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `children` (
  `id`          CHAR(36)     NOT NULL,
  `parent_id`   CHAR(36)     NOT NULL,
  `name`        VARCHAR(120) NOT NULL,
  -- Supported range is 4-14 years (enforced by the API).
  `age`         TINYINT UNSIGNED NOT NULL DEFAULT 4,
  -- Canonical values are "Grade 1" .. "Grade 9" (enforced by the API).
  `grade`       VARCHAR(60)  NOT NULL DEFAULT '',
  `about_child` VARCHAR(255) NOT NULL DEFAULT '',
  `avatar_key`  VARCHAR(32)  NOT NULL DEFAULT 'sunshine',
  `photo_url`   VARCHAR(255) NOT NULL DEFAULT '',
  -- `pin` only holds a value for profiles created before hashing existed.
  `pin`         VARCHAR(4)   NOT NULL DEFAULT '',
  `pin_hash`    VARCHAR(255) NULL DEFAULT NULL,
  `coins`       INT UNSIGNED NOT NULL DEFAULT 0,
  `streak_days` INT UNSIGNED NOT NULL DEFAULT 0,
  `recovery_failed_attempts` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `recovery_locked_until`    DATETIME     NULL DEFAULT NULL,
  `created_at`  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_children_parent` (`parent_id`),
  CONSTRAINT `fk_children_parent`
    FOREIGN KEY (`parent_id`) REFERENCES `parents` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 2b. Child security questions (child-specific 4-digit PIN recovery)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `child_security_questions` (
  `id`           CHAR(36)     NOT NULL,
  `child_id`     CHAR(36)     NOT NULL,
  `question_key` VARCHAR(64)  NOT NULL,
  -- bcrypt hash; the plain answer is never stored or returned.
  `answer_hash`  VARCHAR(255) NOT NULL,
  `sort_order`   TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `created_at`   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_csq_child` (`child_id`),
  CONSTRAINT `fk_csq_child`
    FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 2c. Child PIN recovery tokens (single-child, single-use, hashed)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `child_pin_recovery_tokens` (
  `id`         CHAR(36)     NOT NULL,
  `child_id`   CHAR(36)     NOT NULL,
  `token_hash` CHAR(64)     NOT NULL,
  `used`       TINYINT(1)   NOT NULL DEFAULT 0,
  `expires_at` DATETIME     NOT NULL,
  `created_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_cprt_token` (`token_hash`),
  INDEX `idx_cprt_child` (`child_id`),
  CONSTRAINT `fk_cprt_child`
    FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 3. Auth tokens (Bearer sessions)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `auth_tokens` (
  `id`           CHAR(36)     NOT NULL,
  `parent_id`    CHAR(36)     NOT NULL,
  `subject_type` ENUM('parent','child') NOT NULL DEFAULT 'parent',
  `child_id`     CHAR(36)     NULL DEFAULT NULL,
  `token_hash`   CHAR(64)     NOT NULL,
  `device_name`  VARCHAR(120) NOT NULL DEFAULT 'mobile',
  `expires_at`   DATETIME     NOT NULL,
  `last_used_at` DATETIME     NULL,
  `revoked`      TINYINT(1)   NOT NULL DEFAULT 0,
  `created_at`   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_auth_tokens_hash` (`token_hash`),
  INDEX `idx_auth_tokens_parent` (`parent_id`),
  INDEX `idx_auth_tokens_child` (`child_id`),
  CONSTRAINT `fk_auth_tokens_parent`
    FOREIGN KEY (`parent_id`) REFERENCES `parents` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_auth_tokens_child`
    FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 4. Password reset tokens
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `password_resets` (
  `id`         CHAR(36)   NOT NULL,
  `parent_id`  CHAR(36)   NOT NULL,
  `token_hash` CHAR(64)   NOT NULL,
  `expires_at` DATETIME   NOT NULL,
  `used`       TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_password_resets_hash` (`token_hash`),
  INDEX `idx_password_resets_parent` (`parent_id`),
  CONSTRAINT `fk_password_resets_parent`
    FOREIGN KEY (`parent_id`) REFERENCES `parents` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 5. Activities (daily routine tasks)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `activities` (
  `id`            CHAR(36)     NOT NULL,
  `child_id`      CHAR(36)     NOT NULL,
  `title`         VARCHAR(160) NOT NULL,
  `icon`          VARCHAR(40)  NOT NULL DEFAULT 'sparkle',
  `category`      VARCHAR(80)  NOT NULL DEFAULT 'Routine',
  `time`          VARCHAR(16)  NOT NULL DEFAULT '',
  `coins`         INT UNSIGNED NOT NULL DEFAULT 5,
  `status`        ENUM('pending','completed','inProgress','locked') NOT NULL DEFAULT 'pending',
  `activity_date` DATE         NOT NULL,
  `created_at`    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_activities_child_date` (`child_id`, `activity_date`),
  CONSTRAINT `fk_activities_child`
    FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 6. Sleep records (one row per child per night)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `sleep_records` (
  `id`             CHAR(36)     NOT NULL,
  `child_id`       CHAR(36)     NOT NULL,
  `date`           DATE         NOT NULL,
  `bedtime_hour`   TINYINT UNSIGNED NOT NULL DEFAULT 20,
  `bedtime_minute` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `wake_hour`      TINYINT UNSIGNED NOT NULL DEFAULT 6,
  `wake_minute`    TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `hours`          DECIMAL(4,1) NOT NULL DEFAULT 0,
  `quality`        ENUM('restful','good','fair','poor') NOT NULL DEFAULT 'good',
  `notes`          TEXT         NULL,
  `created_at`     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_sleep_child_date` (`child_id`, `date`),
  CONSTRAINT `fk_sleep_child`
    FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 7. Meal records
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `meals` (
  `id`       CHAR(36)     NOT NULL,
  `child_id` CHAR(36)     NOT NULL,
  `date`     DATE         NOT NULL,
  `type`     ENUM('breakfast','lunch','dinner','snack') NOT NULL,
  `name`     VARCHAR(160) NOT NULL,
  `icon`     VARCHAR(40)  NOT NULL DEFAULT '',
  `time`     VARCHAR(16)  NOT NULL DEFAULT '',
  `calories` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `protein`  SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `carbs`    SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `fat`      SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `eaten`    TINYINT(1)   NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_meals_child_date` (`child_id`, `date`),
  CONSTRAINT `fk_meals_child`
    FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 8. Water intake (one row per child per day) + glass log
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `water_intakes` (
  `id`             CHAR(36)         NOT NULL,
  `child_id`       CHAR(36)         NOT NULL,
  `date`           DATE             NOT NULL,
  `glasses`        SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `target_glasses` SMALLINT UNSIGNED NOT NULL DEFAULT 8,
  `created_at`     TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`     TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_water_child_date` (`child_id`, `date`),
  CONSTRAINT `fk_water_child`
    FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `water_glasses` (
  `id`             CHAR(36)  NOT NULL,
  `water_intake_id` CHAR(36) NOT NULL,
  `logged_at`      DATETIME  NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_water_glasses_intake` (`water_intake_id`),
  CONSTRAINT `fk_water_glasses_intake`
    FOREIGN KEY (`water_intake_id`) REFERENCES `water_intakes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 9. Mood tracking
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `moods` (
  `id`       CHAR(36) NOT NULL,
  `child_id` CHAR(36) NOT NULL,
  `date`     DATETIME NOT NULL,
  `mood`     ENUM('happy','excited','calm','tired','sad','angry') NOT NULL,
  `note`     TEXT     NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_moods_child_date` (`child_id`, `date`),
  CONSTRAINT `fk_moods_child`
    FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 10. Homework
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `homework` (
  `id`         CHAR(36)         NOT NULL,
  `child_id`   CHAR(36)         NOT NULL,
  `title`      VARCHAR(160)     NOT NULL,
  `subject`    VARCHAR(80)      NOT NULL,
  `icon`       VARCHAR(40)      NOT NULL DEFAULT 'book',
  `due_date`   DATE             NOT NULL,
  `status`     ENUM('pending','inProgress','completed') NOT NULL DEFAULT 'pending',
  `coins`      INT UNSIGNED     NOT NULL DEFAULT 5,
  `progress`   DECIMAL(4,2)     NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_homework_child_due` (`child_id`, `due_date`),
  CONSTRAINT `fk_homework_child`
    FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 11. Attendance
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `attendance` (
  `id`         CHAR(36)      NOT NULL,
  `child_id`   CHAR(36)      NOT NULL,
  `date`       DATE          NOT NULL,
  `status`     ENUM('present','absent','late') NOT NULL DEFAULT 'present',
  `class_name` VARCHAR(120)  NOT NULL DEFAULT 'School',
  `created_at` TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_attendance_child_date` (`child_id`, `date`),
  CONSTRAINT `fk_attendance_child`
    FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 12. Screen time
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `screen_time` (
  `id`              CHAR(36)         NOT NULL,
  `child_id`        CHAR(36)         NOT NULL,
  `date`            DATE             NOT NULL,
  `allowed_minutes` SMALLINT UNSIGNED NOT NULL DEFAULT 60,
  `used_minutes`    SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `category`        VARCHAR(60)      NOT NULL DEFAULT 'Total',
  `created_at`      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_screen_child_date` (`child_id`, `date`),
  CONSTRAINT `fk_screen_child`
    FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 13. Notifications
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `notifications` (
  `id`         CHAR(36)      NOT NULL,
  `parent_id`  CHAR(36)      NOT NULL,
  `child_id`   CHAR(36)      NULL,
  `type`       ENUM('activity','meal','homework','announcement') NOT NULL DEFAULT 'activity',
  `title`      VARCHAR(160)  NOT NULL,
  `message`    TEXT          NOT NULL,
  `icon`       VARCHAR(40)   NOT NULL DEFAULT 'bell',
  `is_read`    TINYINT(1)    NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_notifications_parent` (`parent_id`),
  INDEX `idx_notifications_parent_created` (`parent_id`, `created_at`),
  INDEX `idx_notifications_read` (`parent_id`, `is_read`),
  CONSTRAINT `fk_notifications_parent`
    FOREIGN KEY (`parent_id`) REFERENCES `parents` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_notifications_child`
    FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 14. Reports (persisted daily/weekly/monthly JSON snapshots)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `reports` (
  `id`          CHAR(36) NOT NULL,
  `child_id`    CHAR(36) NOT NULL,
  `type`        ENUM('daily','weekly','monthly') NOT NULL,
  `period_date` DATE     NOT NULL,
  `data`        JSON     NOT NULL,
  `created_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_reports_child_type_period` (`child_id`, `type`, `period_date`),
  CONSTRAINT `fk_reports_child`
    FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;
