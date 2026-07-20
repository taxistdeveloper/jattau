import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('kk'),
    Locale('ru')
  ];

  /// No description provided for @navHome.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get navHome;

  /// No description provided for @navSurahs.
  ///
  /// In ru, this message translates to:
  /// **'Суры'**
  String get navSurahs;

  /// No description provided for @navProgress.
  ///
  /// In ru, this message translates to:
  /// **'Прогресс'**
  String get navProgress;

  /// No description provided for @navProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get navProfile;

  /// No description provided for @greeting.
  ///
  /// In ru, this message translates to:
  /// **'Ассаляму алейкум 👋'**
  String get greeting;

  /// No description provided for @continueLearning.
  ///
  /// In ru, this message translates to:
  /// **'Продолжайте изучение'**
  String get continueLearning;

  /// No description provided for @levelXp.
  ///
  /// In ru, this message translates to:
  /// **'Уровень {level} • {current}/{max} XP'**
  String levelXp(int level, int current, int max);

  /// No description provided for @streakDays.
  ///
  /// In ru, this message translates to:
  /// **'Streak: {count} {dayWord}'**
  String streakDays(int count, String dayWord);

  /// No description provided for @aiMentor.
  ///
  /// In ru, this message translates to:
  /// **'ИИ-наставник'**
  String get aiMentor;

  /// No description provided for @quickActions.
  ///
  /// In ru, this message translates to:
  /// **'Быстрые действия'**
  String get quickActions;

  /// No description provided for @actionRead.
  ///
  /// In ru, this message translates to:
  /// **'Читать'**
  String get actionRead;

  /// No description provided for @actionMemorize.
  ///
  /// In ru, this message translates to:
  /// **'Запоминание'**
  String get actionMemorize;

  /// No description provided for @actionGuides.
  ///
  /// In ru, this message translates to:
  /// **'Ұлыгылар'**
  String get actionGuides;

  /// No description provided for @profileTitle.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profileTitle;

  /// No description provided for @defaultUser.
  ///
  /// In ru, this message translates to:
  /// **'Пользователь'**
  String get defaultUser;

  /// No description provided for @levelBadge.
  ///
  /// In ru, this message translates to:
  /// **'Уровень {level} 🏅'**
  String levelBadge(int level);

  /// No description provided for @settings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settings;

  /// No description provided for @errorHistory.
  ///
  /// In ru, this message translates to:
  /// **'История ошибок'**
  String get errorHistory;

  /// No description provided for @achievements.
  ///
  /// In ru, this message translates to:
  /// **'Достижения'**
  String get achievements;

  /// No description provided for @guides.
  ///
  /// In ru, this message translates to:
  /// **'Ұлыгылар'**
  String get guides;

  /// No description provided for @logout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get logout;

  /// No description provided for @welcome.
  ///
  /// In ru, this message translates to:
  /// **'Добро пожаловать'**
  String get welcome;

  /// No description provided for @inJattau.
  ///
  /// In ru, this message translates to:
  /// **'в Jattau'**
  String get inJattau;

  /// No description provided for @password.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get password;

  /// No description provided for @pinCode.
  ///
  /// In ru, this message translates to:
  /// **'PIN-код'**
  String get pinCode;

  /// No description provided for @pinCodeMin4.
  ///
  /// In ru, this message translates to:
  /// **'PIN-код (4 цифры)'**
  String get pinCodeMin4;

  /// No description provided for @pinCreate.
  ///
  /// In ru, this message translates to:
  /// **'Придумайте PIN-код'**
  String get pinCreate;

  /// No description provided for @pinConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Повторите PIN-код'**
  String get pinConfirm;

  /// No description provided for @pinCreateHint.
  ///
  /// In ru, this message translates to:
  /// **'Им вы будете входить в приложение'**
  String get pinCreateHint;

  /// No description provided for @pinEnter.
  ///
  /// In ru, this message translates to:
  /// **'Введите PIN-код'**
  String get pinEnter;

  /// No description provided for @pinMismatch.
  ///
  /// In ru, this message translates to:
  /// **'PIN-коды не совпадают'**
  String get pinMismatch;

  /// No description provided for @pinWrong.
  ///
  /// In ru, this message translates to:
  /// **'Неверный PIN-код'**
  String get pinWrong;

  /// No description provided for @pinUsePassword.
  ///
  /// In ru, this message translates to:
  /// **'Войти с паролем'**
  String get pinUsePassword;

  /// No description provided for @loginMethodPin.
  ///
  /// In ru, this message translates to:
  /// **'PIN'**
  String get loginMethodPin;

  /// No description provided for @loginMethodPassword.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get loginMethodPassword;

  /// No description provided for @loginWithPassword.
  ///
  /// In ru, this message translates to:
  /// **'Вход по паролю'**
  String get loginWithPassword;

  /// No description provided for @testCredentials.
  ///
  /// In ru, this message translates to:
  /// **'Тест: demo@jattau.app / password123'**
  String get testCredentials;

  /// No description provided for @login.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get login;

  /// No description provided for @noAccountRegister.
  ///
  /// In ru, this message translates to:
  /// **'Нет аккаунта? Зарегистрироваться'**
  String get noAccountRegister;

  /// No description provided for @registration.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация'**
  String get registration;

  /// No description provided for @name.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get name;

  /// No description provided for @passwordMin8.
  ///
  /// In ru, this message translates to:
  /// **'Пароль (мин. 8)'**
  String get passwordMin8;

  /// No description provided for @register.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрироваться'**
  String get register;

  /// No description provided for @settingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsTitle;

  /// No description provided for @languageSection.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get languageSection;

  /// No description provided for @languageRussian.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @languageKazakh.
  ///
  /// In ru, this message translates to:
  /// **'Қазақша'**
  String get languageKazakh;

  /// No description provided for @displaySection.
  ///
  /// In ru, this message translates to:
  /// **'Отображение'**
  String get displaySection;

  /// No description provided for @transliteration.
  ///
  /// In ru, this message translates to:
  /// **'Транслитерация'**
  String get transliteration;

  /// No description provided for @translation.
  ///
  /// In ru, this message translates to:
  /// **'Перевод'**
  String get translation;

  /// No description provided for @fontSize.
  ///
  /// In ru, this message translates to:
  /// **'Размер шрифта'**
  String get fontSize;

  /// No description provided for @readingSection.
  ///
  /// In ru, this message translates to:
  /// **'Чтение'**
  String get readingSection;

  /// No description provided for @accuracyThreshold.
  ///
  /// In ru, this message translates to:
  /// **'Порог точности'**
  String get accuracyThreshold;

  /// No description provided for @voiceCommands.
  ///
  /// In ru, this message translates to:
  /// **'Голосовые команды'**
  String get voiceCommands;

  /// No description provided for @themeSection.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get themeSection;

  /// No description provided for @themeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get themeDark;

  /// No description provided for @themeAuto.
  ///
  /// In ru, this message translates to:
  /// **'Авто'**
  String get themeAuto;

  /// No description provided for @surahsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Суры'**
  String get surahsTitle;

  /// No description provided for @ayahsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Аяты'**
  String get ayahsTitle;

  /// No description provided for @ayahCount.
  ///
  /// In ru, this message translates to:
  /// **'{count} аят'**
  String ayahCount(int count);

  /// No description provided for @readingTitle.
  ///
  /// In ru, this message translates to:
  /// **'Чтение'**
  String get readingTitle;

  /// No description provided for @speechUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Распознавание недоступно: {error}'**
  String speechUnavailable(String error);

  /// No description provided for @speechNotOnDevice.
  ///
  /// In ru, this message translates to:
  /// **'Распознавание речи недоступно на устройстве'**
  String get speechNotOnDevice;

  /// No description provided for @arabicLocaleMissing.
  ///
  /// In ru, this message translates to:
  /// **'Арабский язык распознавания не найден. На iPhone: Настройки → Основные → Язык и регион → добавьте العربية'**
  String get arabicLocaleMissing;

  /// No description provided for @correctCount.
  ///
  /// In ru, this message translates to:
  /// **'Правильно: {correct} из {total}'**
  String correctCount(int correct, int total);

  /// No description provided for @youSaid.
  ///
  /// In ru, this message translates to:
  /// **'Вы сказали'**
  String get youSaid;

  /// No description provided for @listening.
  ///
  /// In ru, this message translates to:
  /// **'Слушаю... начните читать'**
  String get listening;

  /// No description provided for @liveChecking.
  ///
  /// In ru, this message translates to:
  /// **'Идёт проверка... нажмите, чтобы остановить'**
  String get liveChecking;

  /// No description provided for @readWithHighlight.
  ///
  /// In ru, this message translates to:
  /// **'Читать с подсветкой'**
  String get readWithHighlight;

  /// No description provided for @stopSeconds.
  ///
  /// In ru, this message translates to:
  /// **'Стоп ({seconds}s)'**
  String stopSeconds(int seconds);

  /// No description provided for @checkOnServer.
  ///
  /// In ru, this message translates to:
  /// **'Проверить на сервере'**
  String get checkOnServer;

  /// No description provided for @reference.
  ///
  /// In ru, this message translates to:
  /// **'Эталон'**
  String get reference;

  /// No description provided for @referencePlaying.
  ///
  /// In ru, this message translates to:
  /// **'Воспроизведение...'**
  String get referencePlaying;

  /// No description provided for @referenceAudioFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось воспроизвести эталонное аудио'**
  String get referenceAudioFailed;

  /// No description provided for @resultTitle.
  ///
  /// In ru, this message translates to:
  /// **'Результат'**
  String get resultTitle;

  /// No description provided for @processing.
  ///
  /// In ru, this message translates to:
  /// **'Обработка...'**
  String get processing;

  /// No description provided for @errorsCount.
  ///
  /// In ru, this message translates to:
  /// **'Ошибки ({count})'**
  String errorsCount(int count);

  /// No description provided for @expected.
  ///
  /// In ru, this message translates to:
  /// **'Ожид: {word}'**
  String expected(String word);

  /// No description provided for @actual.
  ///
  /// In ru, this message translates to:
  /// **'Было: {word}'**
  String actual(String word);

  /// No description provided for @skipped.
  ///
  /// In ru, this message translates to:
  /// **'Пропущено: {word}'**
  String skipped(String word);

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @excellentXp.
  ///
  /// In ru, this message translates to:
  /// **'Отлично! +15 XP'**
  String get excellentXp;

  /// No description provided for @nextAyah.
  ///
  /// In ru, this message translates to:
  /// **'Следующий аят'**
  String get nextAyah;

  /// No description provided for @errorPrefix.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка: {message}'**
  String errorPrefix(String message);

  /// No description provided for @errorHistoryTitle.
  ///
  /// In ru, this message translates to:
  /// **'История ошибок'**
  String get errorHistoryTitle;

  /// No description provided for @noErrorsYet.
  ///
  /// In ru, this message translates to:
  /// **'Ошибок пока нет'**
  String get noErrorsYet;

  /// No description provided for @ayahNumber.
  ///
  /// In ru, this message translates to:
  /// **'{surah} • Аят {number}'**
  String ayahNumber(String surah, int number);

  /// No description provided for @statisticsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Прогресс'**
  String get statisticsTitle;

  /// No description provided for @surahsStat.
  ///
  /// In ru, this message translates to:
  /// **'Сур'**
  String get surahsStat;

  /// No description provided for @ayahsStat.
  ///
  /// In ru, this message translates to:
  /// **'Аятов'**
  String get ayahsStat;

  /// No description provided for @accuracyStat.
  ///
  /// In ru, this message translates to:
  /// **'Точность'**
  String get accuracyStat;

  /// No description provided for @streakLabel.
  ///
  /// In ru, this message translates to:
  /// **'Streak'**
  String get streakLabel;

  /// No description provided for @daysCount.
  ///
  /// In ru, this message translates to:
  /// **'{count} дней'**
  String daysCount(int count);

  /// No description provided for @weeklyAccuracy.
  ///
  /// In ru, this message translates to:
  /// **'Точность за неделю'**
  String get weeklyAccuracy;

  /// No description provided for @achievementsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Достижения'**
  String get achievementsTitle;

  /// No description provided for @levelXpShort.
  ///
  /// In ru, this message translates to:
  /// **'Уровень {level} • {xp} XP'**
  String levelXpShort(int level, int xp);

  /// No description provided for @achievementFirstAyah.
  ///
  /// In ru, this message translates to:
  /// **'Первый аят'**
  String get achievementFirstAyah;

  /// No description provided for @achievementStreak7.
  ///
  /// In ru, this message translates to:
  /// **'7 дней streak'**
  String get achievementStreak7;

  /// No description provided for @achievement10Ayahs.
  ///
  /// In ru, this message translates to:
  /// **'10 аятов'**
  String get achievement10Ayahs;

  /// No description provided for @achievementSurah1.
  ///
  /// In ru, this message translates to:
  /// **'Сура 1'**
  String get achievementSurah1;

  /// No description provided for @achievement5Memorized.
  ///
  /// In ru, this message translates to:
  /// **'5 наизусть'**
  String get achievement5Memorized;

  /// No description provided for @achievement90Accuracy.
  ///
  /// In ru, this message translates to:
  /// **'90% точность'**
  String get achievement90Accuracy;

  /// No description provided for @memorizationTitle.
  ///
  /// In ru, this message translates to:
  /// **'Запоминание'**
  String get memorizationTitle;

  /// No description provided for @newCards.
  ///
  /// In ru, this message translates to:
  /// **'Новые'**
  String get newCards;

  /// No description provided for @reviewCards.
  ///
  /// In ru, this message translates to:
  /// **'Повтор'**
  String get reviewCards;

  /// No description provided for @memorized.
  ///
  /// In ru, this message translates to:
  /// **'Запомнено'**
  String get memorized;

  /// No description provided for @again.
  ///
  /// In ru, this message translates to:
  /// **'Снова'**
  String get again;

  /// No description provided for @hard.
  ///
  /// In ru, this message translates to:
  /// **'Сложно'**
  String get hard;

  /// No description provided for @good.
  ///
  /// In ru, this message translates to:
  /// **'Хорошо'**
  String get good;

  /// No description provided for @easy.
  ///
  /// In ru, this message translates to:
  /// **'Легко'**
  String get easy;

  /// No description provided for @showTranslation.
  ///
  /// In ru, this message translates to:
  /// **'Показать перевод'**
  String get showTranslation;

  /// No description provided for @allDoneToday.
  ///
  /// In ru, this message translates to:
  /// **'На сегодня всё повторено!'**
  String get allDoneToday;

  /// No description provided for @comeBackLater.
  ///
  /// In ru, this message translates to:
  /// **'Возвращайтесь позже для новых повторений.'**
  String get comeBackLater;

  /// No description provided for @guidesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ұлыгылар'**
  String get guidesTitle;

  /// No description provided for @guideNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Ұлығы табылмады'**
  String get guideNotFound;

  /// No description provided for @copy.
  ///
  /// In ru, this message translates to:
  /// **'Көшіру'**
  String get copy;

  /// No description provided for @textCopied.
  ///
  /// In ru, this message translates to:
  /// **'Мәтін көшірілді'**
  String get textCopied;

  /// No description provided for @connectionError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось подключиться к серверу. Проверьте, что backend запущен.'**
  String get connectionError;

  /// No description provided for @invalidCredentials.
  ///
  /// In ru, this message translates to:
  /// **'Неверный email или пароль'**
  String get invalidCredentials;

  /// No description provided for @emailRegistered.
  ///
  /// In ru, this message translates to:
  /// **'Этот email уже зарегистрирован'**
  String get emailRegistered;

  /// No description provided for @validationFailed.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте правильность введённых данных'**
  String get validationFailed;

  /// No description provided for @accountDeactivated.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт деактивирован'**
  String get accountDeactivated;

  /// No description provided for @sessionExpired.
  ///
  /// In ru, this message translates to:
  /// **'Сессия истекла. Войдите снова'**
  String get sessionExpired;

  /// No description provided for @speechRecognitionFailed.
  ///
  /// In ru, this message translates to:
  /// **'Распознавание речи недоступно. Проверьте OPENAI_API_KEY в backend/.env'**
  String get speechRecognitionFailed;

  /// No description provided for @daySingular.
  ///
  /// In ru, this message translates to:
  /// **'день'**
  String get daySingular;

  /// No description provided for @dayFew.
  ///
  /// In ru, this message translates to:
  /// **'дня'**
  String get dayFew;

  /// No description provided for @dayMany.
  ///
  /// In ru, this message translates to:
  /// **'дней'**
  String get dayMany;

  /// No description provided for @dayUnit.
  ///
  /// In ru, this message translates to:
  /// **'күн'**
  String get dayUnit;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
