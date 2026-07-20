<?php

$email = 'demo@jattau.app';
$password = 'password123';
$pin = '1234';

$check = $db->prepare('SELECT id, pin_hash FROM users WHERE email = :email');
$check->execute(['email' => $email]);
$existing = $check->fetch();

if ($existing) {
    if (empty($existing['pin_hash'])) {
        $db->prepare('UPDATE users SET pin_hash = :pin_hash WHERE id = :id')->execute([
            'pin_hash' => password_hash($pin, PASSWORD_BCRYPT, ['cost' => 12]),
            'id' => $existing['id'],
        ]);
        echo "  Demo user PIN set: {$pin}\n";
    } else {
        echo "  Demo user already exists ({$email}).\n";
    }
    return;
}

$userId = seedUuid();
$stmt = $db->prepare('
    INSERT INTO users (id, email, password_hash, pin_hash, full_name, role)
    VALUES (:id, :email, :password_hash, :pin_hash, :full_name, :role)
');
$stmt->execute([
    'id' => $userId,
    'email' => $email,
    'password_hash' => password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]),
    'pin_hash' => password_hash($pin, PASSWORD_BCRYPT, ['cost' => 12]),
    'full_name' => 'Demo User',
    'role' => 'user',
]);

$db->prepare('INSERT IGNORE INTO statistics (id, user_id) VALUES (:id, :user_id)')->execute(['id' => seedUuid(), 'user_id' => $userId]);
$db->prepare('INSERT IGNORE INTO streaks (id, user_id) VALUES (:id, :user_id)')->execute(['id' => seedUuid(), 'user_id' => $userId]);
$db->prepare('INSERT IGNORE INTO settings (id, user_id) VALUES (:id, :user_id)')->execute(['id' => seedUuid(), 'user_id' => $userId]);

echo "  Demo user created: {$email} / {$password} / PIN {$pin}\n";
