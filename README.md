# Jattau — AI-Powered Quran Learning App

Коммерческое мобильное приложение для изучения Корана с искусственным интеллектом.
Уровень качества: Duolingo для чтения и запоминания Корана.

## Структура проекта

```
jattau/
├── backend/          # PHP 8.4 MVC REST API
├── mobile/           # Flutter (Android + iOS)
├── docs/             # Архитектура, UML, roadmap, UI/UX
└── README.md
```

## Быстрый старт

### Backend

```bash
cd backend
composer install
cp .env.example .env
# Настройте MySQL в .env (MAMP: root/root, порт 3306)
php database/migrate.php
php database/seed.php
```

API через MAMP: `http://localhost/jattau/api/v1`  
Swagger: `http://localhost/jattau/api/docs`

### Mobile

```bash
cd mobile
flutter pub get
flutter run
```

MAMP Apache и MySQL должны быть запущены. Отдельный `php -S` не нужен.

## Технологии

| Слой | Стек |
|------|------|
| Mobile | Flutter, Dart, Riverpod, GoRouter, Dio, Material 3 |
| Backend | PHP 8.4, MVC, PDO, MySQL, JWT |
| AI | Whisper (STT), GPT-4 (анализ), Tajweed rules engine |
| DB | MySQL 5.7+ с UUID (CHAR(36)) |

## Основные возможности

- Распознавание арабской речи и проверка чтения
- Блокировка следующего аята до правильного прочтения
- Интервальное повторение (SRS)
- Голосовой помощник
- Статистика, достижения, streak
- ИИ-наставник с персональными рекомендациями

## Документация

- [Архитектура](docs/ARCHITECTURE.md)
- [Схема БД](docs/DATABASE.md)
- [UML-диаграммы](docs/UML.md)
- [UI/UX](docs/UI_UX.md)
- [Roadmap](docs/ROADMAP.md)
- [План разработки](docs/DEVELOPMENT_PLAN.md)
- [OpenAPI](backend/public/api/openapi.yaml)

## Лицензия

Proprietary — коммерческий продукт.
