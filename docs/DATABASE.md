# Схема базы данных PostgreSQL

Все первичные ключи — `UUID` (gen_random_uuid()).

## ER-диаграмма (упрощённая)

```
users ──┬── recitations ── recitation_results ── pronunciation_errors
        │                      │
        ├── lesson_progress    └── ai_feedback
        ├── statistics
        ├── streaks
        ├── achievements (user_achievements)
        ├── notifications
        └── settings

surahs ── ayahs ── quran_text
              │
              └── tajweed_rules (per ayah/word)

lessons ── lesson_progress
```

## Таблицы

### users
| Колонка | Тип | Описание |
|---------|-----|----------|
| id | UUID PK | |
| email | VARCHAR(255) UNIQUE | |
| password_hash | VARCHAR(255) | bcrypt |
| full_name | VARCHAR(255) | |
| role | VARCHAR(50) | user, premium, admin |
| avatar_url | TEXT | |
| level | INTEGER DEFAULT 1 | |
| experience_points | INTEGER DEFAULT 0 | |
| daily_goal_minutes | INTEGER DEFAULT 15 | |
| preferred_language | VARCHAR(10) DEFAULT 'ar' | |
| is_active | BOOLEAN DEFAULT true | |
| email_verified_at | TIMESTAMPTZ | |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

### surahs
| Колонка | Тип | Описание |
|---------|-----|----------|
| id | UUID PK | |
| number | INTEGER UNIQUE | 1-114 |
| name_arabic | VARCHAR(100) | |
| name_transliteration | VARCHAR(100) | |
| name_translation | VARCHAR(255) | |
| revelation_type | VARCHAR(20) | meccan, medinan |
| ayah_count | INTEGER | |
| bismillah_pre | BOOLEAN | |
| order_index | INTEGER | |

### ayahs
| Колонка | Тип | Описание |
|---------|-----|----------|
| id | UUID PK | |
| surah_id | UUID FK → surahs | |
| number | INTEGER | Номер в суре |
| global_number | INTEGER UNIQUE | 1-6236 |
| juz_number | INTEGER | |
| hizb_number | INTEGER | |
| page_number | INTEGER | |
| audio_url | TEXT | URL эталонного аудио |

### quran_text
| Колонка | Тип | Описание |
|---------|-----|----------|
| id | UUID PK | |
| ayah_id | UUID FK → ayahs UNIQUE | |
| text_uthmani | TEXT | Усмани письмо |
| text_simple | TEXT | Упрощённый |
| text_transliteration | TEXT | |
| text_translation_ru | TEXT | |
| word_count | INTEGER | |
| words_json | JSONB | Массив слов с позициями |

### tajweed_rules
| Колонка | Тип | Описание |
|---------|-----|----------|
| id | UUID PK | |
| ayah_id | UUID FK | |
| word_index | INTEGER | |
| rule_type | VARCHAR(50) | ghunnah, qalqalah, madd, etc. |
| rule_description | TEXT | |
| start_char | INTEGER | |
| end_char | INTEGER | |

### recitations
| Колонка | Тип | Описание |
|---------|-----|----------|
| id | UUID PK | |
| user_id | UUID FK | |
| ayah_id | UUID FK | |
| audio_path | TEXT | Путь к файлу |
| audio_duration_seconds | DECIMAL | |
| status | VARCHAR(20) | pending, processing, completed, failed |
| attempt_number | INTEGER DEFAULT 1 | |
| created_at | TIMESTAMPTZ | |

### recitation_results
| Колонка | Тип | Описание |
|---------|-----|----------|
| id | UUID PK | |
| recitation_id | UUID FK UNIQUE | |
| accuracy_percent | DECIMAL(5,2) | 0-100 |
| is_passed | BOOLEAN | >= 85% |
| transcribed_text | TEXT | STT результат |
| expected_text | TEXT | |
| words_correct | INTEGER | |
| words_total | INTEGER | |
| words_skipped | JSONB | |
| words_extra | JSONB | |
| words_mispronounced | JSONB | |
| words_reordered | JSONB | |
| tajweed_errors | JSONB | |
| processing_time_ms | INTEGER | |
| created_at | TIMESTAMPTZ | |

### pronunciation_errors
| Колонка | Тип | Описание |
|---------|-----|----------|
| id | UUID PK | |
| recitation_result_id | UUID FK | |
| user_id | UUID FK | |
| ayah_id | UUID FK | |
| error_type | VARCHAR(50) | skipped, mispronounced, extra, reordered, tajweed |
| word_expected | VARCHAR(100) | |
| word_actual | VARCHAR(100) | |
| word_position | INTEGER | |
| letter_problem | VARCHAR(10) | Проблемная буква |
| severity | VARCHAR(20) | low, medium, high |
| created_at | TIMESTAMPTZ | |

### lessons
| Колонка | Тип | Описание |
|---------|-----|----------|
| id | UUID PK | |
| title | VARCHAR(255) | |
| description | TEXT | |
| surah_id | UUID FK | |
| start_ayah | INTEGER | |
| end_ayah | INTEGER | |
| difficulty | VARCHAR(20) | beginner, intermediate, advanced |
| order_index | INTEGER | |
| xp_reward | INTEGER | |

### lesson_progress
| Колонка | Тип | Описание |
|---------|-----|----------|
| id | UUID PK | |
| user_id | UUID FK | |
| lesson_id | UUID FK | |
| current_ayah | INTEGER | |
| status | VARCHAR(20) | not_started, in_progress, completed |
| accuracy_avg | DECIMAL | |
| completed_at | TIMESTAMPTZ | |
| UNIQUE(user_id, lesson_id) | | |

### achievements
| Колонка | Тип | Описание |
|---------|-----|----------|
| id | UUID PK | |
| code | VARCHAR(50) UNIQUE | first_ayah, streak_7, etc. |
| title | VARCHAR(255) | |
| description | TEXT | |
| icon | VARCHAR(50) | |
| xp_reward | INTEGER | |
| category | VARCHAR(50) | reading, memorization, streak |

### user_achievements
| Колонка | Тип | Описание |
|---------|-----|----------|
| id | UUID PK | |
| user_id | UUID FK | |
| achievement_id | UUID FK | |
| earned_at | TIMESTAMPTZ | |
| UNIQUE(user_id, achievement_id) | | |

### statistics
| Колонка | Тип | Описание |
|---------|-----|----------|
| id | UUID PK | |
| user_id | UUID FK UNIQUE | |
| surahs_studied | INTEGER DEFAULT 0 | |
| ayahs_studied | INTEGER DEFAULT 0 | |
| ayahs_memorized | INTEGER DEFAULT 0 | |
| total_recitations | INTEGER DEFAULT 0 | |
| total_errors | INTEGER DEFAULT 0 | |
| avg_accuracy | DECIMAL DEFAULT 0 | |
| total_study_minutes | INTEGER DEFAULT 0 | |
| problem_letters | JSONB | {"ض": 12, "ظ": 8} |
| updated_at | TIMESTAMPTZ | |

### streaks
| Колонка | Тип | Описание |
|---------|-----|----------|
| id | UUID PK | |
| user_id | UUID FK UNIQUE | |
| current_streak | INTEGER DEFAULT 0 | |
| longest_streak | INTEGER DEFAULT 0 | |
| last_activity_date | DATE | |
| streak_freeze_count | INTEGER DEFAULT 0 | |

### ai_feedback
| Колонка | Тип | Описание |
|---------|-----|----------|
| id | UUID PK | |
| user_id | UUID FK | |
| recitation_result_id | UUID FK | |
| feedback_type | VARCHAR(50) | error_explanation, recommendation, mentor |
| content | TEXT | |
| language | VARCHAR(10) | |
| created_at | TIMESTAMPTZ | |

### memorization_cards (SRS)
| Колонка | Тип | Описание |
|---------|-----|----------|
| id | UUID PK | |
| user_id | UUID FK | |
| ayah_id | UUID FK | |
| ease_factor | DECIMAL DEFAULT 2.5 | SM-2 |
| interval_days | INTEGER DEFAULT 0 | |
| repetitions | INTEGER DEFAULT 0 | |
| next_review_at | TIMESTAMPTZ | |
| memorization_percent | DECIMAL DEFAULT 0 | |
| UNIQUE(user_id, ayah_id) | | |

### notifications
| Колонка | Тип | Описание |
|---------|-----|----------|
| id | UUID PK | |
| user_id | UUID FK | |
| title | VARCHAR(255) | |
| body | TEXT | |
| type | VARCHAR(50) | reminder, achievement, mentor |
| is_read | BOOLEAN DEFAULT false | |
| data | JSONB | |
| created_at | TIMESTAMPTZ | |

### settings
| Колонка | Тип | Описание |
|---------|-----|----------|
| id | UUID PK | |
| user_id | UUID FK UNIQUE | |
| theme | VARCHAR(20) DEFAULT 'system' | |
| font_size | INTEGER DEFAULT 24 | |
| arabic_font | VARCHAR(50) | |
| show_transliteration | BOOLEAN DEFAULT true | |
| show_translation | BOOLEAN DEFAULT true | |
| audio_reciter | VARCHAR(50) | |
| accuracy_threshold | DECIMAL DEFAULT 85 | |
| voice_commands_enabled | BOOLEAN DEFAULT true | |
| notifications_enabled | BOOLEAN DEFAULT true | |
| updated_at | TIMESTAMPTZ | |

### refresh_tokens
| Колонка | Тип | Описание |
|---------|-----|----------|
| id | UUID PK | |
| user_id | UUID FK | |
| token_hash | VARCHAR(255) | |
| expires_at | TIMESTAMPTZ | |
| revoked_at | TIMESTAMPTZ | |

## Индексы

- `ayahs(surah_id, number)`
- `recitations(user_id, ayah_id)`
- `pronunciation_errors(user_id, letter_problem)`
- `memorization_cards(user_id, next_review_at)`
- `notifications(user_id, is_read)`
