-- Jattau Database Migration 001
-- MySQL 5.7+ / MariaDB

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- Users
CREATE TABLE IF NOT EXISTS users (
    id CHAR(36) NOT NULL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'user',
    avatar_url TEXT,
    level INT NOT NULL DEFAULT 1,
    experience_points INT NOT NULL DEFAULT 0,
    daily_goal_minutes INT NOT NULL DEFAULT 15,
    preferred_language VARCHAR(10) NOT NULL DEFAULT 'ar',
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    email_verified_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Surahs
CREATE TABLE IF NOT EXISTS surahs (
    id CHAR(36) NOT NULL PRIMARY KEY,
    number INT NOT NULL,
    name_arabic VARCHAR(100) NOT NULL,
    name_transliteration VARCHAR(100) NOT NULL,
    name_translation VARCHAR(255) NOT NULL,
    revelation_type VARCHAR(20) NOT NULL,
    ayah_count INT NOT NULL,
    bismillah_pre TINYINT(1) NOT NULL DEFAULT 1,
    order_index INT NOT NULL,
    UNIQUE KEY uk_surahs_number (number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Ayahs
CREATE TABLE IF NOT EXISTS ayahs (
    id CHAR(36) NOT NULL PRIMARY KEY,
    surah_id CHAR(36) NOT NULL,
    number INT NOT NULL,
    global_number INT NOT NULL,
    juz_number INT NULL,
    hizb_number INT NULL,
    page_number INT NULL,
    audio_url TEXT,
    UNIQUE KEY uk_ayahs_global_number (global_number),
    UNIQUE KEY uk_ayahs_surah_number (surah_id, number),
    CONSTRAINT fk_ayahs_surah FOREIGN KEY (surah_id) REFERENCES surahs(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_ayahs_surah_number ON ayahs(surah_id, number);

-- Quran Text
CREATE TABLE IF NOT EXISTS quran_text (
    id CHAR(36) NOT NULL PRIMARY KEY,
    ayah_id CHAR(36) NOT NULL,
    text_uthmani TEXT NOT NULL,
    text_simple TEXT,
    text_transliteration TEXT,
    text_translation_ru TEXT,
    word_count INT NOT NULL DEFAULT 0,
    words_json JSON,
    UNIQUE KEY uk_quran_text_ayah (ayah_id),
    CONSTRAINT fk_quran_text_ayah FOREIGN KEY (ayah_id) REFERENCES ayahs(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tajweed Rules
CREATE TABLE IF NOT EXISTS tajweed_rules (
    id CHAR(36) NOT NULL PRIMARY KEY,
    ayah_id CHAR(36) NOT NULL,
    word_index INT NOT NULL,
    rule_type VARCHAR(50) NOT NULL,
    rule_description TEXT,
    start_char INT,
    end_char INT,
    CONSTRAINT fk_tajweed_ayah FOREIGN KEY (ayah_id) REFERENCES ayahs(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Recitations
CREATE TABLE IF NOT EXISTS recitations (
    id CHAR(36) NOT NULL PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    ayah_id CHAR(36) NOT NULL,
    audio_path TEXT NOT NULL,
    audio_duration_seconds DECIMAL(10,2),
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    attempt_number INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_recitations_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_recitations_ayah FOREIGN KEY (ayah_id) REFERENCES ayahs(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_recitations_user_ayah ON recitations(user_id, ayah_id);

-- Recitation Results
CREATE TABLE IF NOT EXISTS recitation_results (
    id CHAR(36) NOT NULL PRIMARY KEY,
    recitation_id CHAR(36) NOT NULL,
    accuracy_percent DECIMAL(5,2) NOT NULL DEFAULT 0,
    is_passed TINYINT(1) NOT NULL DEFAULT 0,
    transcribed_text TEXT,
    expected_text TEXT,
    words_correct INT NOT NULL DEFAULT 0,
    words_total INT NOT NULL DEFAULT 0,
    words_skipped JSON,
    words_extra JSON,
    words_mispronounced JSON,
    words_reordered JSON,
    tajweed_errors JSON,
    processing_time_ms INT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_recitation_results_recitation (recitation_id),
    CONSTRAINT fk_results_recitation FOREIGN KEY (recitation_id) REFERENCES recitations(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Pronunciation Errors
CREATE TABLE IF NOT EXISTS pronunciation_errors (
    id CHAR(36) NOT NULL PRIMARY KEY,
    recitation_result_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    ayah_id CHAR(36) NOT NULL,
    error_type VARCHAR(50) NOT NULL,
    word_expected VARCHAR(100),
    word_actual VARCHAR(100),
    word_position INT,
    letter_problem VARCHAR(10),
    severity VARCHAR(20) NOT NULL DEFAULT 'medium',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_errors_result FOREIGN KEY (recitation_result_id) REFERENCES recitation_results(id) ON DELETE CASCADE,
    CONSTRAINT fk_errors_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_errors_ayah FOREIGN KEY (ayah_id) REFERENCES ayahs(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_pronunciation_errors_user ON pronunciation_errors(user_id, letter_problem);

-- Lessons
CREATE TABLE IF NOT EXISTS lessons (
    id CHAR(36) NOT NULL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    surah_id CHAR(36) NULL,
    start_ayah INT,
    end_ayah INT,
    difficulty VARCHAR(20) NOT NULL DEFAULT 'beginner',
    order_index INT NOT NULL DEFAULT 0,
    xp_reward INT NOT NULL DEFAULT 10,
    CONSTRAINT fk_lessons_surah FOREIGN KEY (surah_id) REFERENCES surahs(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Lesson Progress
CREATE TABLE IF NOT EXISTS lesson_progress (
    id CHAR(36) NOT NULL PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    lesson_id CHAR(36) NOT NULL,
    current_ayah INT NOT NULL DEFAULT 1,
    status VARCHAR(20) NOT NULL DEFAULT 'not_started',
    accuracy_avg DECIMAL(5,2) DEFAULT 0,
    completed_at TIMESTAMP NULL DEFAULT NULL,
    UNIQUE KEY uk_lesson_progress_user_lesson (user_id, lesson_id),
    CONSTRAINT fk_lesson_progress_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_lesson_progress_lesson FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Achievements
CREATE TABLE IF NOT EXISTS achievements (
    id CHAR(36) NOT NULL PRIMARY KEY,
    code VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    xp_reward INT NOT NULL DEFAULT 0,
    category VARCHAR(50) NOT NULL DEFAULT 'reading',
    UNIQUE KEY uk_achievements_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User Achievements
CREATE TABLE IF NOT EXISTS user_achievements (
    id CHAR(36) NOT NULL PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    achievement_id CHAR(36) NOT NULL,
    earned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_achievements (user_id, achievement_id),
    CONSTRAINT fk_user_achievements_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_achievements_achievement FOREIGN KEY (achievement_id) REFERENCES achievements(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Statistics
CREATE TABLE IF NOT EXISTS statistics (
    id CHAR(36) NOT NULL PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    surahs_studied INT NOT NULL DEFAULT 0,
    ayahs_studied INT NOT NULL DEFAULT 0,
    ayahs_memorized INT NOT NULL DEFAULT 0,
    total_recitations INT NOT NULL DEFAULT 0,
    total_errors INT NOT NULL DEFAULT 0,
    avg_accuracy DECIMAL(5,2) NOT NULL DEFAULT 0,
    total_study_minutes INT NOT NULL DEFAULT 0,
    problem_letters JSON,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_statistics_user (user_id),
    CONSTRAINT fk_statistics_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Streaks
CREATE TABLE IF NOT EXISTS streaks (
    id CHAR(36) NOT NULL PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    current_streak INT NOT NULL DEFAULT 0,
    longest_streak INT NOT NULL DEFAULT 0,
    last_activity_date DATE,
    streak_freeze_count INT NOT NULL DEFAULT 0,
    UNIQUE KEY uk_streaks_user (user_id),
    CONSTRAINT fk_streaks_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- AI Feedback
CREATE TABLE IF NOT EXISTS ai_feedback (
    id CHAR(36) NOT NULL PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    recitation_result_id CHAR(36) NULL,
    feedback_type VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    language VARCHAR(10) NOT NULL DEFAULT 'ru',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ai_feedback_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_ai_feedback_result FOREIGN KEY (recitation_result_id) REFERENCES recitation_results(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Memorization Cards (SRS)
CREATE TABLE IF NOT EXISTS memorization_cards (
    id CHAR(36) NOT NULL PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    ayah_id CHAR(36) NOT NULL,
    ease_factor DECIMAL(4,2) NOT NULL DEFAULT 2.5,
    interval_days INT NOT NULL DEFAULT 0,
    repetitions INT NOT NULL DEFAULT 0,
    next_review_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    memorization_percent DECIMAL(5,2) NOT NULL DEFAULT 0,
    UNIQUE KEY uk_memorization_user_ayah (user_id, ayah_id),
    CONSTRAINT fk_memorization_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_memorization_ayah FOREIGN KEY (ayah_id) REFERENCES ayahs(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_memorization_due ON memorization_cards(user_id, next_review_at);

-- Notifications
CREATE TABLE IF NOT EXISTS notifications (
    id CHAR(36) NOT NULL PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT,
    type VARCHAR(50) NOT NULL DEFAULT 'reminder',
    is_read TINYINT(1) NOT NULL DEFAULT 0,
    data JSON,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_notifications_user ON notifications(user_id, is_read);

-- Settings
CREATE TABLE IF NOT EXISTS settings (
    id CHAR(36) NOT NULL PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    theme VARCHAR(20) NOT NULL DEFAULT 'system',
    font_size INT NOT NULL DEFAULT 24,
    arabic_font VARCHAR(50) DEFAULT 'amiri',
    show_transliteration TINYINT(1) NOT NULL DEFAULT 1,
    show_translation TINYINT(1) NOT NULL DEFAULT 1,
    audio_reciter VARCHAR(50) DEFAULT 'mishary',
    accuracy_threshold DECIMAL(5,2) NOT NULL DEFAULT 85,
    voice_commands_enabled TINYINT(1) NOT NULL DEFAULT 1,
    notifications_enabled TINYINT(1) NOT NULL DEFAULT 1,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_settings_user (user_id),
    CONSTRAINT fk_settings_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Refresh Tokens
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id CHAR(36) NOT NULL PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    revoked_at TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT fk_refresh_tokens_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_refresh_tokens_hash ON refresh_tokens(token_hash);

SET FOREIGN_KEY_CHECKS = 1;
