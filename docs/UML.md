# UML-диаграммы Jattau

## 1. Use Case Diagram

```mermaid
graph TB
    User((Пользователь))
    
    User --> UC1[Регистрация / Вход]
    User --> UC2[Выбрать суру и аят]
    User --> UC3[Читать аят вслух]
    User --> UC4[Получить анализ ИИ]
    User --> UC5[Повторить чтение]
    User --> UC6[Режим запоминания]
    User --> UC7[Голосовые команды]
    User --> UC8[Просмотр статистики]
    User --> UC9[Достижения]
    User --> UC10[ИИ-наставник]
    
    UC3 --> UC4
    UC4 -->|ошибки| UC5
    UC4 -->|успех| UC2
    UC10 --> UC6
```

## 2. Class Diagram — Domain (Flutter)

```mermaid
classDiagram
    class User {
        +String id
        +String email
        +String fullName
        +int level
        +int experiencePoints
    }
    
    class Surah {
        +String id
        +int number
        +String nameArabic
        +int ayahCount
    }
    
    class Ayah {
        +String id
        +int number
        +String textUthmani
        +String audioUrl
    }
    
    class Recitation {
        +String id
        +String userId
        +String ayahId
        +String status
        +int attemptNumber
    }
    
    class RecitationResult {
        +String id
        +double accuracyPercent
        +bool isPassed
        +List~WordError~ errors
    }
    
    class WordError {
        +String type
        +String expected
        +String actual
        +int position
    }
    
    class MemorizationCard {
        +String ayahId
        +double easeFactor
        +int intervalDays
        +DateTime nextReviewAt
    }
    
    Surah "1" --> "*" Ayah
    User "1" --> "*" Recitation
    Recitation "1" --> "1" RecitationResult
    RecitationResult "1" --> "*" WordError
    User "1" --> "*" MemorizationCard
```

## 3. Sequence Diagram — Проверка чтения

```mermaid
sequenceDiagram
    actor User
    participant App as Flutter App
    participant API as PHP API
    participant STT as Whisper API
    participant AI as GPT-4
    participant DB as PostgreSQL
    
    User->>App: Выбирает аят, нажимает "Начать"
    App->>App: Записывает аудио
    User->>App: Читает аят вслух
    App->>API: POST /recitations (audio + ayah_id)
    API->>DB: Сохранить recitation
    API->>STT: Транскрибировать аудио
    STT-->>API: Arabic text
    API->>DB: Получить expected text
    API->>API: PronunciationAnalysisService
    API->>API: TajweedRulesEngine
    API->>AI: Генерировать объяснения
    AI-->>API: Feedback text
    API->>DB: Сохранить result + errors
    API-->>App: RecitationResult JSON
    
    alt accuracy >= 85%
        App->>User: ✅ Успех! Следующий аят доступен
    else accuracy < 85%
        App->>User: ❌ Ошибки + рекомендации
        App->>User: Повторить чтение
    end
```

## 4. Component Diagram — Backend

```mermaid
graph TB
    subgraph "Presentation"
        Router
        Controllers
        Middleware
    end
    
    subgraph "Application"
        AuthService
        RecitationService
        StatisticsService
        AchievementService
        MentorService
        SpacedRepetitionService
    end
    
    subgraph "Domain / AI"
        SpeechRecognitionService
        PronunciationAnalysisService
        TajweedRulesEngine
        AiFeedbackService
    end
    
    subgraph "Infrastructure"
        Repositories
        PDO[(PostgreSQL)]
        FileStorage
        Logger
    end
    
    Router --> Middleware --> Controllers
    Controllers --> AuthService
    Controllers --> RecitationService
    RecitationService --> SpeechRecognitionService
    RecitationService --> PronunciationAnalysisService
    RecitationService --> TajweedRulesEngine
    RecitationService --> AiFeedbackService
    AuthService --> Repositories
    RecitationService --> Repositories
    Repositories --> PDO
    RecitationService --> FileStorage
```

## 5. State Diagram — Recitation

```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Recording: Начать чтение
    Recording --> Uploading: Остановить запись
    Uploading --> Processing: Аудио загружено
    Processing --> Passed: accuracy >= 85%
    Processing --> Failed: accuracy < 85%
    Failed --> Recording: Повторить
    Passed --> Idle: Следующий аят
    Processing --> Error: API failure
    Error --> Recording: Retry
```

## 6. Activity Diagram — SRS (Запоминание)

```mermaid
flowchart TD
    A[Открыть режим запоминания] --> B{Есть карточки на сегодня?}
    B -->|Да| C[Показать карточку]
    B -->|Нет| D[Показать новый аят]
    C --> E[Пользователь вспоминает]
    D --> E
    E --> F[Проверка чтения]
    F --> G{Правильно?}
    G -->|Да| H[Увеличить interval]
    G -->|Нет| I[Сбросить interval]
    H --> J[Обновить next_review_at]
    I --> J
    J --> K{Ещё карточки?}
    K -->|Да| C
    K -->|Нет| L[Показать итоги сессии]
```

## 7. Deployment Diagram

```mermaid
graph TB
    subgraph "Client"
        iOS[iOS App]
        Android[Android App]
    end
    
    subgraph "Server"
        Nginx[Nginx]
        PHP[PHP-FPM]
        PG[(PostgreSQL)]
        Storage[Object Storage]
    end
    
    subgraph "External"
        OpenAI[OpenAI API]
    end
    
    iOS --> Nginx
    Android --> Nginx
    Nginx --> PHP
    PHP --> PG
    PHP --> Storage
    PHP --> OpenAI
```
