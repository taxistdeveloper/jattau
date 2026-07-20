<?php

$email = 'demo@jattau.app';
$password = 'password123';

$check = $db->prepare('SELECT id FROM users WHERE email = :email');
$check->execute(['email' => $email]);

if ($check->fetch()) {
    echo "  Demo user already exists ({$email}).\n";
    return;
}

$userId = seedUuid();
$stmt = $db->prepare('
    INSERT INTO users (id, email, password_hash, full_name, role)
    VALUES (:id, :email, :password_hash, :full_name, :role)
');
$stmt->execute([
    'id' => $userId,
    'email' => $email,
    'password_hash' => password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]),
    'full_name' => 'Demo User',
    'role' => 'user',
]);

$db->prepare('INSERT IGNORE INTO statistics (id, user_id) VALUES (:id, :user_id)')->execute(['id' => seedUuid(), 'user_id' => $userId]);
$db->prepare('INSERT IGNORE INTO streaks (id, user_id) VALUES (:id, :user_id)')->execute(['id' => seedUuid(), 'user_id' => $userId]);
$db->prepare('INSERT IGNORE INTO settings (id, user_id) VALUES (:id, :user_id)')->execute(['id' => seedUuid(), 'user_id' => $userId]);

echo "  Demo user created: {$email} / {$password}\n";
