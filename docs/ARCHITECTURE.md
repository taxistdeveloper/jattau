# Архитектура Jattau

## Обзор системы

```
┌─────────────────┐     HTTPS/REST      ┌─────────────────┐
│  Flutter App    │ ◄──────────────────► │  PHP MVC API    │
│  (iOS/Android)  │     JWT + multipart   │  (Backend)      │
└────────┬────────┘                       └────────┬────────┘
         │                                         │
         │ on-device STT (optional)                  │ PDO
         ▼                                         ▼
┌─────────────────┐                       ┌─────────────────┐
│  Local cache    │                       │  PostgreSQL     │
│  (Hive/Shared)  │                       │  (UUID schema)  │
└─────────────────┘                       └────────┬────────┘
                                                   │
         ┌─────────────────────────────────────────┤
         ▼                     ▼                     ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  OpenAI Whisper │  │  GPT-4 Analysis │  │  File Storage   │
│  (Arabic STT)   │  │  (Feedback)     │  │  (Audio)        │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

## Clean Architecture — Flutter

```
lib/
├── core/           # Константы, ошибки, утилиты, extensions
├── config/         # Env, app config
├── routes/         # GoRouter
├── services/       # Dio client, audio, speech, storage
├── models/         # Shared DTOs
├── repository/     # Base repository
├── features/       # Feature modules (data/domain/presentation)
├── shared/         # Shared providers, mixins
├── widgets/        # Reusable UI components
└── theme/          # Material 3 theme
```

### Feature module structure

```
features/reading/
├── data/
│   ├── datasources/    # Remote + local
│   ├── models/         # JSON models
│   └── repositories/   # Repository impl
├── domain/
│   ├── entities/       # Business entities
│   ├── repositories/   # Abstract repos
│   └── usecases/       # Single responsibility
└── presentation/
    ├── providers/      # Riverpod
    ├── screens/        # UI screens
    └── widgets/        # Feature widgets
```

### Features

| Feature | Описание |
|---------|----------|
| `auth` | Регистрация, вход, JWT refresh |
| `home` | Dashboard, рекомендации ИИ |
| `surahs` | Список сур, детали |
| `ayahs` | Список аятов, выбор |
| `reading` | Экран чтения, запись голоса |
| `recitation` | Проверка, ошибки, повтор |
| `memorization` | SRS, интервальное повторение |
| `statistics` | Прогресс, графики |
| `achievements` | Уровни, XP, награды |
| `profile` | Профиль пользователя |
| `settings` | Настройки приложения |
| `voice_assistant` | Голосовые команды |
| `notifications` | Push-уведомления |

## MVC Architecture — PHP Backend

```
backend/
├── app/
│   ├── Controllers/    # HTTP handlers
│   ├── Models/         # Eloquent-like active records
│   ├── Services/       # Business logic
│   ├── Repositories/   # Data access
│   ├── Middleware/     # Auth, CORS, rate limit
│   ├── Requests/       # Request DTOs
│   ├── Validators/     # Input validation
│   └── Helpers/        # JWT, Response, Logger
├── config/             # app, database, jwt, ai
├── database/
│   ├── migrations/     # SQL migrations
│   └── seeds/          # Quran data seeds
├── public/
│   ├── index.php       # Front controller
│   └── api/openapi.yaml
├── routes/
│   └── api.php         # Route definitions
└── storage/
    ├── logs/
    └── audio/          # Uploaded recordings
```

### Request lifecycle

```
HTTP Request
    → public/index.php (bootstrap)
    → Router (routes/api.php)
    → Middleware stack (CORS → RateLimit → Auth)
    → Controller
    → Validator
    → Service (business logic)
    → Repository (PDO)
    → Response JSON
```

## AI Pipeline

```
1. User records audio (Flutter)
2. Upload to POST /api/v1/recitations
3. Backend:
   a. Store audio file
   b. Call Whisper API → Arabic transcription
   c. Compare with quran_text (ayah)
   d. TajweedRulesEngine → rule violations
   e. GPT-4 → human-readable feedback
   f. Save recitation_results + pronunciation_errors
4. Return analysis to client
5. If accuracy < threshold → block next ayah
```

### AI Services

| Service | Назначение |
|---------|------------|
| `SpeechRecognitionService` | Whisper API, Arabic STT |
| `PronunciationAnalysisService` | Word-level diff, scoring |
| `TajweedRulesEngine` | Rule-based tajweed checks |
| `AiFeedbackService` | GPT-4 explanations |
| `AiMentorService` | Personalized recommendations |
| `SpacedRepetitionService` | SRS scheduling |

## Безопасность

- JWT access (15 min) + refresh (7 days) tokens
- RBAC: `user`, `premium`, `admin`
- Rate limiting: 100 req/min per IP
- Input validation на всех endpoints
- Prepared statements (PDO)
- CORS whitelist
- Audio file type/size validation

## Кеширование

- Surahs/ayahs: Redis/file cache (TTL 24h)
- User stats: invalidate on recitation complete
- Quran text: static, seeded once

## Масштабирование

- Stateless API → horizontal scaling
- Audio storage → S3-compatible object storage
- AI calls → queue (future: Redis queue worker)
- Read replicas for PostgreSQL (future)
