import 'package:jattau/l10n/app_localizations.dart';

/// Склонение слова «день» для русского; для казахского — «күн».
String dayWord(int n, AppLocalizations l10n) {
  if (l10n.localeName.startsWith('kk')) return l10n.dayUnit;
  final mod100 = n % 100;
  if (mod100 >= 11 && mod100 <= 14) return l10n.dayMany;
  switch (n % 10) {
    case 1:
      return l10n.daySingular;
    case 2:
    case 3:
    case 4:
      return l10n.dayFew;
    default:
      return l10n.dayMany;
  }
}
