// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get navHome => 'Басты бет';

  @override
  String get navSurahs => 'Сүрелер';

  @override
  String get navProgress => 'Прогресс';

  @override
  String get navProfile => 'Профиль';

  @override
  String get greeting => 'Ассаляму алейкум 👋';

  @override
  String get continueLearning => 'Оқуды жалғастырыңыз';

  @override
  String levelXp(int level, int current, int max) {
    return 'Деңгей $level • $current/$max XP';
  }

  @override
  String streakDays(int count, String dayWord) {
    return 'Streak: $count $dayWord';
  }

  @override
  String get aiMentor => 'ЖИ-кеңесші';

  @override
  String get quickActions => 'Жылдам әрекеттер';

  @override
  String get actionRead => 'Оқу';

  @override
  String get actionMemorize => 'Жаттау';

  @override
  String get actionGuides => 'Ұлыгылар';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get defaultUser => 'Пайдаланушы';

  @override
  String levelBadge(int level) {
    return 'Деңгей $level 🏅';
  }

  @override
  String get settings => 'Баптаулар';

  @override
  String get errorHistory => 'Қателер тарихы';

  @override
  String get achievements => 'Жетістіктер';

  @override
  String get guides => 'Ұлыгылар';

  @override
  String get logout => 'Шығу';

  @override
  String get welcome => 'Қош келдіңіз';

  @override
  String get inJattau => 'Jattau-ға';

  @override
  String get password => 'Құпия сөз';

  @override
  String get pinCode => 'PIN-код';

  @override
  String get pinCodeMin4 => 'PIN-код (4 цифр)';

  @override
  String get pinCreate => 'PIN-код ойлап табыңыз';

  @override
  String get pinConfirm => 'PIN-кодты қайталаңыз';

  @override
  String get pinCreateHint => 'Қосымшаға осымен кіресіз';

  @override
  String get pinEnter => 'PIN-кодты енгізіңіз';

  @override
  String get pinMismatch => 'PIN-кодтар сәйкес емес';

  @override
  String get pinWrong => 'Қате PIN-код';

  @override
  String get pinUsePassword => 'Құпия сөзбен кіру';

  @override
  String get loginMethodPin => 'PIN';

  @override
  String get loginMethodPassword => 'Құпия сөз';

  @override
  String get loginWithPassword => 'Құпия сөзбен кіру';

  @override
  String get testCredentials => 'Тест: demo@jattau.app / password123';

  @override
  String get login => 'Кіру';

  @override
  String get noAccountRegister => 'Аккаунт жоқ па? Тіркелу';

  @override
  String get registration => 'Тіркелу';

  @override
  String get name => 'Аты';

  @override
  String get passwordMin8 => 'Құпия сөз (мин. 8)';

  @override
  String get register => 'Тіркелу';

  @override
  String get settingsTitle => 'Баптаулар';

  @override
  String get languageSection => 'Тіл';

  @override
  String get languageRussian => 'Орысша';

  @override
  String get languageKazakh => 'Қазақша';

  @override
  String get displaySection => 'Көрініс';

  @override
  String get transliteration => 'Транслитерация';

  @override
  String get translation => 'Аударма';

  @override
  String get fontSize => 'Қаріп өлшемі';

  @override
  String get readingSection => 'Оқу';

  @override
  String get accuracyThreshold => 'Дәлдік шегі';

  @override
  String get voiceCommands => 'Дауыстық командалар';

  @override
  String get themeSection => 'Тақырып';

  @override
  String get themeLight => 'Ашық';

  @override
  String get themeDark => 'Қараңғы';

  @override
  String get themeAuto => 'Авто';

  @override
  String get surahsTitle => 'Сүрелер';

  @override
  String get ayahsTitle => 'Аяттар';

  @override
  String ayahCount(int count) {
    return '$count аят';
  }

  @override
  String get readingTitle => 'Оқу';

  @override
  String speechUnavailable(String error) {
    return 'Тану қолжетімсіз: $error';
  }

  @override
  String get speechNotOnDevice => 'Құрылғыда сөйлеуді тану қолжетімсіз';

  @override
  String get arabicLocaleMissing =>
      'Араб тілін тану табылмады. iPhone-да: Баптаулар → Негізгі → Тіл және аймақ → العربية қосыңыз';

  @override
  String correctCount(int correct, int total) {
    return 'Дұрыс: $correct / $total';
  }

  @override
  String get youSaid => 'Сіз айттыңыз';

  @override
  String get listening => 'Тыңдап жатырмын... оқуды бастаңыз';

  @override
  String get liveChecking => 'Тексеру жүріп жатыр... тоқтату үшін басыңыз';

  @override
  String get readWithHighlight => 'Бояумен оқу';

  @override
  String stopSeconds(int seconds) {
    return 'Тоқтату ($secondsс)';
  }

  @override
  String get checkOnServer => 'Серверде тексеру';

  @override
  String get reference => 'Эталон';

  @override
  String get referencePlaying => 'Ойнатылуда...';

  @override
  String get referenceAudioFailed => 'Эталондық аудионы ойнату мүмкін болмады';

  @override
  String get resultTitle => 'Нәтиже';

  @override
  String get processing => 'Өңделуде...';

  @override
  String errorsCount(int count) {
    return 'Қателер ($count)';
  }

  @override
  String expected(String word) {
    return 'Күтілді: $word';
  }

  @override
  String actual(String word) {
    return 'Болды: $word';
  }

  @override
  String skipped(String word) {
    return 'Өткізілді: $word';
  }

  @override
  String get retry => 'Қайталау';

  @override
  String get excellentXp => 'Керемет! +15 XP';

  @override
  String get nextAyah => 'Келесі аят';

  @override
  String errorPrefix(String message) {
    return 'Қате: $message';
  }

  @override
  String get errorHistoryTitle => 'Қателер тарихы';

  @override
  String get noErrorsYet => 'Әзірге қателер жоқ';

  @override
  String ayahNumber(String surah, int number) {
    return '$surah • $number-аят';
  }

  @override
  String get statisticsTitle => 'Прогресс';

  @override
  String get surahsStat => 'Сүрелер';

  @override
  String get ayahsStat => 'Аяттар';

  @override
  String get accuracyStat => 'Дәлдік';

  @override
  String get streakLabel => 'Streak';

  @override
  String daysCount(int count) {
    return '$count күн';
  }

  @override
  String get weeklyAccuracy => 'Апталық дәлдік';

  @override
  String get achievementsTitle => 'Жетістіктер';

  @override
  String levelXpShort(int level, int xp) {
    return 'Деңгей $level • $xp XP';
  }

  @override
  String get achievementFirstAyah => 'Бірінші аят';

  @override
  String get achievementStreak7 => '7 күн streak';

  @override
  String get achievement10Ayahs => '10 аят';

  @override
  String get achievementSurah1 => '1-сүре';

  @override
  String get achievement5Memorized => '5 жаттау';

  @override
  String get achievement90Accuracy => '90% дәлдік';

  @override
  String get memorizationTitle => 'Жаттау';

  @override
  String get newCards => 'Жаңа';

  @override
  String get reviewCards => 'Қайталау';

  @override
  String get memorized => 'Жатталды';

  @override
  String get again => 'Қайта';

  @override
  String get hard => 'Қиын';

  @override
  String get good => 'Жақсы';

  @override
  String get easy => 'Оңай';

  @override
  String get showTranslation => 'Аударманы көрсету';

  @override
  String get allDoneToday => 'Бүгінгі қайталау аяқталды!';

  @override
  String get comeBackLater => 'Жаңа қайталаулар үшін кейінірек оралыңыз.';

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
      'Серверге қосылу мүмкін болмады. Backend іске қосылғанын тексеріңіз.';

  @override
  String get invalidCredentials => 'Email немесе құпия сөз дұрыс емес';

  @override
  String get emailRegistered => 'Бұл email тіркелген';

  @override
  String get validationFailed => 'Енгізілген деректерді тексеріңіз';

  @override
  String get accountDeactivated => 'Аккаунт деактивтелген';

  @override
  String get sessionExpired => 'Сессия аяқталды. Қайта кіріңіз';

  @override
  String get speechRecognitionFailed =>
      'Сөйлеуді тану қолжетімсіз. backend/.env файлында OPENAI_API_KEY тексеріңіз';

  @override
  String get daySingular => 'күн';

  @override
  String get dayFew => 'күн';

  @override
  String get dayMany => 'күн';

  @override
  String get dayUnit => 'күн';
}
