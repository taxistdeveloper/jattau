-- Kazakh transliterations and translations

ALTER TABLE surahs ADD COLUMN name_translation_kk VARCHAR(255) NULL;
ALTER TABLE quran_text ADD COLUMN text_transliteration_kk TEXT NULL;
ALTER TABLE quran_text ADD COLUMN text_translation_kk TEXT NULL;
