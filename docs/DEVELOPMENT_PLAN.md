# План разработки по этапам

## Этап 1: Инфраструктура (5 дней)

### День 1-2: Backend scaffold
- [x] Composer init, autoload PSR-4
- [x] Front controller (public/index.php)
- [x] Router, Request, Response classes
- [x] PDO connection wrapper
- [x] Logger (Monolog-like)
- [x] Error handler

### День 3: Database
- [x] Все миграции (17 таблиц)
- [x] Seed: 114 сур
- [ ] Seed: 6236 аятов (Al-Quran Cloud API)
- [x] Migration runner script

### День 4-5: Auth
- [x] JWT helper (firebase/php-jwt)
- [x] Register, Login, Refresh endpoints
- [x] Auth middleware
- [x] Role-based access

## Этап 2: Core API (7 дней)

### День 6-7: Quran data
- [ ] SurahController (list, detail)
- [ ] AyahController (by surah, detail)
- [ ] QuranTextController
- [ ] Caching layer

### День 8-10: Recitation
- [ ] File upload handler
- [ ] RecitationController (create, status)
- [ ] SpeechRecognitionService (Whisper)
- [ ] PronunciationAnalysisService
- [ ] RecitationResult storage

### День 11-12: AI
- [ ] TajweedRulesEngine (5 базовых правил)
- [ ] AiFeedbackService (GPT-4)
- [ ] Error explanation generation

## Этап 3: Flutter App (10 дней)

### День 13-14: Setup
- [x] Project init, dependencies
- [x] Theme (Material 3, Islamic palette)
- [x] GoRouter setup
- [x] Dio client + interceptors

### День 15-16: Auth screens
- [ ] Splash, Login, Register
- [ ] Auth providers (Riverpod)
- [ ] Token storage

### День 17-18: Quran browsing
- [ ] Home screen
- [ ] Surahs list
- [ ] Ayahs list
- [ ] Arabic text rendering

### День 19-20: Reading flow
- [ ] Reading screen
- [ ] Audio recording (record package)
- [ ] Upload + polling
- [ ] Results screen

### День 21-22: Progress
- [ ] Statistics screen
- [ ] Achievements screen
- [ ] Profile + Settings

## Этап 4: Advanced Features (8 дней)

### День 23-24: Memorization
- [ ] SRS service (backend)
- [ ] Memorization screen (Flutter)
- [ ] Review session flow

### День 25-26: Gamification
- [ ] XP/Level system
- [ ] Achievement triggers
- [ ] Streak tracking
- [ ] Daily goals

### День 27-28: Voice + Mentor
- [ ] Voice commands (speech_to_text)
- [ ] AI mentor recommendations
- [ ] Notifications

## Этап 5: Polish & Launch (5 дней)

### День 29-30: Testing
- [ ] API integration tests
- [ ] Flutter widget tests
- [ ] Manual QA checklist

### День 31-32: Documentation
- [x] OpenAPI spec
- [x] Architecture docs
- [ ] Deployment guide

### День 33: Launch prep
- [ ] App icons, splash
- [ ] Store listings
- [ ] Privacy policy

---

## Команда (рекомендуемая)

| Роль | Кол-во | Задачи |
|------|--------|--------|
| Flutter Developer | 2 | UI, features, state |
| PHP Backend | 1 | API, services, DB |
| AI Engineer | 1 | STT, analysis, mentor |
| UI/UX Designer | 1 | Screens, flows, assets |
| QA | 1 | Testing, automation |
| DevOps | 0.5 | Deploy, CI/CD |

**Итого:** ~35 рабочих дней (7 недель) для MVP + Phase 2.

## Приоритеты

```
P0 (блокер):  Auth, Surahs/Ayahs API, Reading + STT, Results
P1 (важно):   Tajweed, AI feedback, Statistics, Achievements
P2 (желательно): SRS, Voice assistant, Mentor, Notifications
P3 (будущее): Premium, Social, Web dashboard, B2B API
```

## Риски

| Риск | Митигация |
|------|-----------|
| Качество Arabic STT | Тестировать Whisper large-v3, fallback на Google STT |
| Latency AI calls | Async processing + polling, progress indicator |
| Размер Quran seed | Batch import, CDN для аудио |
| Tajweed accuracy | Начать с rule-based, улучшать итеративно |
| App Store review | Нет религиозного контента нарушающего guidelines |
