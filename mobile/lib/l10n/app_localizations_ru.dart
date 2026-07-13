// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get navHome => 'Главная';

  @override
  String get navSurahs => 'Суры';

  @override
  String get navProgress => 'Прогресс';

  @override
  String get navProfile => 'Профиль';

  @override
  String get greeting => 'Ассаляму алейкум 👋';

  @override
  String get continueLearning => 'Продолжайте изучение';

  @override
  String levelXp(int level, int current, int max) {
    return 'Уровень $level • $current/$max XP';
  }

  @override
  String streakDays(int count, String dayWord) {
    return 'Streak: $count $dayWord';
  }

  @override
  String get aiMentor => 'ИИ-наставник';

  @override
  String get quickActions => 'Быстрые действия';

  @override
  String get actionRead => 'Читать';

  @override
  String get actionMemorize => 'Запоминание';

  @override
  String get actionGuides => 'Ұлыгылар';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get defaultUser => 'Пользователь';

  @override
  String levelBadge(int level) {
    return 'Уровень $level 🏅';
  }

  @override
  String get settings => 'Настройки';

  @override
  String get errorHistory => 'История ошибок';

  @override
  String get achievements => 'Достижения';

  @override
  String get guides => 'Ұлыгылар';

  @override
  String get logout => 'Выйти';

  @override
  String get welcome => 'Добро пожаловать';

  @override
  String get inJattau => 'в Jattau';

  @override
  String get password => 'Пароль';

  @override
  String get testCredentials => 'Тест: demo@jattau.app / password123';

  @override
  String get login => 'Войти';

  @override
  String get noAccountRegister => 'Нет аккаунта? Зарегистрироваться';

  @override
  String get registration => 'Регистрация';

  @override
  String get name => 'Имя';

  @override
  String get passwordMin8 => 'Пароль (мин. 8)';

  @override
  String get register => 'Зарегистрироваться';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get languageSection => 'Язык';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageKazakh => 'Қазақша';

  @override
  String get displaySection => 'Отображение';

  @override
  String get transliteration => 'Транслитерация';

  @override
  String get translation => 'Перевод';

  @override
  String get fontSize => 'Размер шрифта';

  @override
  String get readingSection => 'Чтение';

  @override
  String get accuracyThreshold => 'Порог точности';

  @override
  String get voiceCommands => 'Голосовые команды';

  @override
  String get themeSection => 'Тема';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeAuto => 'Авто';

  @override
  String get surahsTitle => 'Суры';

  @override
  String get ayahsTitle => 'Аяты';

  @override
  String ayahCount(int count) {
    return '$count аят';
  }

  @override
  String get readingTitle => 'Чтение';

  @override
  String speechUnavailable(String error) {
    return 'Распознавание недоступно: $error';
  }

  @override
  String get speechNotOnDevice => 'Распознавание речи недоступно на устройстве';

  @override
  String get arabicLocaleMissing =>
      'Арабский язык распознавания не найден. На iPhone: Настройки → Основные → Язык и регион → добавьте العربية';

  @override
  String correctCount(int correct, int total) {
    return 'Правильно: $correct из $total';
  }

  @override
  String get youSaid => 'Вы сказали';

  @override
  String get listening => 'Слушаю... начните читать';

  @override
  String get liveChecking => 'Идёт проверка... нажмите, чтобы остановить';

  @override
  String get readWithHighlight => 'Читать с подсветкой';

  @override
  String stopSeconds(int seconds) {
    return 'Стоп (${seconds}s)';
  }

  @override
  String get checkOnServer => 'Проверить на сервере';

  @override
  String get reference => 'Эталон';

  @override
  String get referencePlaying => 'Воспроизведение...';

  @override
  String get referenceAudioFailed => 'Не удалось воспроизвести эталонное аудио';

  @override
  String get resultTitle => 'Результат';

  @override
  String get processing => 'Обработка...';

  @override
  String errorsCount(int count) {
    return 'Ошибки ($count)';
  }

  @override
  String expected(String word) {
    return 'Ожид: $word';
  }

  @override
  String actual(String word) {
    return 'Было: $word';
  }

  @override
  String skipped(String word) {
    return 'Пропущено: $word';
  }

  @override
  String get retry => 'Повторить';

  @override
  String get excellentXp => 'Отлично! +15 XP';

  @override
  String get nextAyah => 'Следующий аят';

  @override
  String errorPrefix(String message) {
    return 'Ошибка: $message';
  }

  @override
  String get errorHistoryTitle => 'История ошибок';

  @override
  String get noErrorsYet => 'Ошибок пока нет';

  @override
  String ayahNumber(String surah, int number) {
    return '$surah • Аят $number';
  }

  @override
  String get statisticsTitle => 'Прогресс';

  @override
  String get surahsStat => 'Сур';

  @override
  String get ayahsStat => 'Аятов';

  @override
  String get accuracyStat => 'Точность';

  @override
  String get streakLabel => 'Streak';

  @override
  String daysCount(int count) {
    return '$count дней';
  }

  @override
  String get weeklyAccuracy => 'Точность за неделю';

  @override
  String get achievementsTitle => 'Достижения';

  @override
  String levelXpShort(int level, int xp) {
    return 'Уровень $level • $xp XP';
  }

  @override
  String get achievementFirstAyah => 'Первый аят';

  @override
  String get achievementStreak7 => '7 дней streak';

  @override
  String get achievement10Ayahs => '10 аятов';

  @override
  String get achievementSurah1 => 'Сура 1';

  @override
  String get achievement5Memorized => '5 наизусть';

  @override
  String get achievement90Accuracy => '90% точность';

  @override
  String get memorizationTitle => 'Запоминание';

  @override
  String get newCards => 'Новые';

  @override
  String get reviewCards => 'Повтор';

  @override
  String get memorized => 'Запомнено';

  @override
  String get again => 'Снова';

  @override
  String get hard => 'Сложно';

  @override
  String get good => 'Хорошо';

  @override
  String get easy => 'Легко';

  @override
  String get showTranslation => 'Показать перевод';

  @override
  String get allDoneToday => 'На сегодня всё повторено!';

  @override
  String get comeBackLater => 'Возвращайтесь позже для новых повторений.';

  @override
  String get guidesTitle => 'Ұлыгылар';

  @override
  String get guideNotFound => 'Ұлығы табылмады';

  @override
  String get copy => 'Көшіру';

  @override
  String get textCopied => 'Мәтін көшірілді';

  @override
  String get connectionError =>
      'Не удалось подключиться к серверу. Проверьте, что backend запущен.';

  @override
  String get invalidCredentials => 'Неверный email или пароль';

  @override
  String get emailRegistered => 'Этот email уже зарегистрирован';

  @override
  String get validationFailed => 'Проверьте правильность введённых данных';

  @override
  String get accountDeactivated => 'Аккаунт деактивирован';

  @override
  String get sessionExpired => 'Сессия истекла. Войдите снова';

  @override
  String get speechRecognitionFailed =>
      'Распознавание речи недоступно. Проверьте OPENAI_API_KEY в backend/.env';

  @override
  String get daySingular => 'день';

  @override
  String get dayFew => 'дня';

  @override
  String get dayMany => 'дней';

  @override
  String get dayUnit => 'күн';
}
