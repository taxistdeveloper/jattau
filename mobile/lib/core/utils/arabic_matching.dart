/// On-device Arabic recitation matching.
///
/// Mirrors the backend `PronunciationAnalysisService` normalization so live
/// (offline) feedback stays consistent with the server-side check.
library;

enum WordStatus {
  /// Not yet reached by the speaker.
  pending,

  /// Recognized correctly.
  correct,

  /// Reached but pronounced incorrectly / skipped.
  wrong,
}

/// Strips harakat, tatweel and unifies letter variants so recognizer output
/// (which usually lacks diacritics) can be compared with the Uthmani text.
String normalizeArabic(String text) {
  var result = text;
  result = result.replaceAll(RegExp('[\u064B-\u065F\u0670]'), '');
  result = result.replaceAll('\u0640', '');
  result = result.replaceAll(RegExp('[أإآٱ]'), 'ا');
  result = result.replaceAll('ة', 'ه');
  result = result.replaceAll('ى', 'ي');
  result = result.replaceAll(RegExp('[^\u0600-\u06FF\\s]'), '');
  return result.trim();
}

List<String> tokenizeArabic(String text) {
  final normalized = normalizeArabic(text);
  if (normalized.isEmpty) return const [];
  return normalized
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList(growable: false);
}

int _levenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  final prev = List<int>.generate(b.length + 1, (i) => i);
  final curr = List<int>.filled(b.length + 1, 0);

  for (var i = 0; i < a.length; i++) {
    curr[0] = i + 1;
    for (var j = 0; j < b.length; j++) {
      final cost = a.codeUnitAt(i) == b.codeUnitAt(j) ? 0 : 1;
      curr[j + 1] = [
        curr[j] + 1,
        prev[j + 1] + 1,
        prev[j] + cost,
      ].reduce((v, e) => v < e ? v : e);
    }
    for (var j = 0; j <= b.length; j++) {
      prev[j] = curr[j];
    }
  }
  return prev[b.length];
}

/// Returns similarity in [0, 1] between two words after normalization.
double wordSimilarity(String a, String b) {
  final na = normalizeArabic(a);
  final nb = normalizeArabic(b);
  if (na == nb) return 1.0;
  final maxLen = na.length > nb.length ? na.length : nb.length;
  if (maxLen == 0) return 1.0;
  return 1 - (_levenshtein(na, nb) / maxLen);
}

/// Aligns [spokenWords] against [expectedWords] in order, returning a status
/// per expected word. Words the speaker has not reached yet stay [pending],
/// so the UI can highlight progress live while listening.
List<WordStatus> analyzeLiveRecitation(
  List<String> expectedWords,
  List<String> spokenWords, {
  double threshold = 0.75,
}) {
  final statuses =
      List<WordStatus>.filled(expectedWords.length, WordStatus.pending);

  var e = 0;
  var s = 0;
  while (e < expectedWords.length && s < spokenWords.length) {
    if (wordSimilarity(expectedWords[e], spokenWords[s]) >= threshold) {
      statuses[e] = WordStatus.correct;
      e++;
      s++;
      continue;
    }

    // Speaker may have skipped the current word: if the next expected word
    // matches, mark the current one wrong and move on without consuming input.
    if (e + 1 < expectedWords.length &&
        wordSimilarity(expectedWords[e + 1], spokenWords[s]) >= threshold) {
      statuses[e] = WordStatus.wrong;
      e++;
      continue;
    }

    // Otherwise treat it as a mispronunciation attempt on the current word.
    statuses[e] = WordStatus.wrong;
    e++;
    s++;
  }

  return statuses;
}

/// Fraction of expected words recognized correctly, in [0, 1].
double liveAccuracy(List<WordStatus> statuses) {
  if (statuses.isEmpty) return 0;
  final correct = statuses.where((s) => s == WordStatus.correct).length;
  return correct / statuses.length;
}
