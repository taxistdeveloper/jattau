-- Kazakh titles and descriptions for achievements

ALTER TABLE achievements ADD COLUMN title_kk VARCHAR(255) NULL;
ALTER TABLE achievements ADD COLUMN description_kk TEXT NULL;
