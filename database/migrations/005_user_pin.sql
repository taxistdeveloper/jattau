-- PIN code for login (stored as bcrypt hash)

ALTER TABLE users ADD COLUMN pin_hash VARCHAR(255) NULL AFTER password_hash;
