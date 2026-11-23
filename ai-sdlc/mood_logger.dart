/// Lab 2 Individual Assignment (A2) -- CLI Mood Logger (TEMPLATE)
///
/// Build a command-line mood tracking application.
/// Implement all the TODO sections below.
///
/// Run with: dart run mood_logger_template.dart
///
/// Requirements:
///   - MoodEntry class to represent a single mood log
///   - MoodLogger class to manage a collection of entries
///   - Interactive CLI with a menu loop
///
/// Do NOT use AI tools. Write all code yourself.

import 'dart:io';

// ============================================================================
// MoodEntry Class
// ============================================================================

/// Represents a single mood log entry.
///
/// Fields:
///   - DateTime createdAt  -- when the entry was created
///   - int score           -- mood score from 1 (very bad) to 10 (excellent)
///   - String? note        -- an optional short description of the mood;
///                            null when the user wrote nothing
///
/// The Flutter Mood Tracker you build from Lab 3 onwards uses the same three
/// fields, so this class carries over almost unchanged.
class MoodEntry {
  final DateTime createdAt;
  final int score;
  final String? note;

  MoodEntry(this.score, [this.note]) : createdAt = DateTime.now();

  /// Returns a formatted string representation of this entry.
  /// Format: "[YYYY-MM-DD HH:MM] Score: <score>/10 - <note>"
  /// When there is no note, show "(no note)" in its place.
  @override
  String toString() {
    final date =
        '${createdAt.year}-${_twoDigits(createdAt.month)}-${_twoDigits(createdAt.day)}';
    final time = '${_twoDigits(createdAt.hour)}:${_twoDigits(createdAt.minute)}';
    return '[$date $time] Score: $score/10 - ${note ?? '(no note)'}';
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

// ============================================================================
// MoodLogger Class
// ============================================================================

/// Manages a collection of MoodEntry objects.
class MoodLogger {
  static const int minScore = 1;
  static const int maxScore = 10;

  final List<MoodEntry> _entries = [];

  /// Adds a new mood entry with the given score and optional note.
  ///
  /// Returns false and prints an error when the score is outside 1-10.
  /// A note that is empty or only spaces is stored as null.
  bool addEntry(int score, String? note) {
    if (score < minScore || score > maxScore) {
      print('Error: score must be between $minScore and $maxScore.');
      return false;
    }
    final trimmedNote = note?.trim();
    final cleanNote =
        (trimmedNote == null || trimmedNote.isEmpty) ? null : trimmedNote;
    _entries.add(MoodEntry(score, cleanNote));
    return true;
  }

  /// Returns a copy of all entries.
  List<MoodEntry> getAllEntries() => List.of(_entries);

  /// Returns null if there are no entries: there is no average to report,
  /// and 0.0 would look like a real (very bad) score.
  double? getAverageScore() {
    if (_entries.isEmpty) return null;
    final total = _entries.fold<int>(0, (sum, entry) => sum + entry.score);
    return total / _entries.length;
  }

  /// Returns all entries with a score greater than or equal to [threshold].
  List<MoodEntry> getEntriesAbove(int threshold) =>
      _entries.where((entry) => entry.score >= threshold).toList();

  int get entryCount => _entries.length;
}

// ============================================================================
// Main -- Interactive CLI
// ============================================================================

void main() {
  final logger = MoodLogger();

  print('=== Mood Logger ===');
  print('Track your daily mood on a scale of 1-10.\n');

  var running = true;
  while (running) {
    printMenu();
    final input = prompt('\nChoose an option: ');
    if (input == null) break;

    switch (int.tryParse(input.trim())) {
      case 1:
        addMoodEntry(logger);
      case 2:
        printEntries(logger.getAllEntries());
      case 3:
        printAverage(logger);
      case 4:
        filterByMinimumScore(logger);
      case 5:
        running = false;
        print('Goodbye!');
      default:
        print('Invalid option. Please choose 1-5.');
    }
    print('');
  }
}

void printMenu() {
  print('1. Add mood entry');
  print('2. View all entries');
  print('3. View average mood');
  print('4. Filter by minimum score');
  print('5. Quit');
}

void addMoodEntry(MoodLogger logger) {
  final score = promptInt('Enter mood score (1-10): ');
  if (score == null) {
    print('Error: please enter a whole number between 1 and 10.');
    return;
  }
  final note = prompt('Enter a note (or press Enter for none): ');
  if (logger.addEntry(score, note)) {
    print('Entry added!');
  }
}

void printEntries(List<MoodEntry> entries) {
  if (entries.isEmpty) {
    print('No entries yet.');
    return;
  }
  entries.forEach(print);
}

void printAverage(MoodLogger logger) {
  final average = logger.getAverageScore();
  if (average == null) {
    print('No entries yet. Add some entries first!');
    return;
  }
  print('Average mood score: ${average.toStringAsFixed(1)} '
      '(based on ${logger.entryCount} entries)');
}

void filterByMinimumScore(MoodLogger logger) {
  final threshold = promptInt('Enter minimum score: ');
  if (threshold == null) {
    print('Error: please enter a whole number.');
    return;
  }
  final matches = logger.getEntriesAbove(threshold);
  if (matches.isEmpty) {
    print('No entries with a score of $threshold or higher.');
    return;
  }
  matches.forEach(print);
}

/// Returns null when stdin is closed.
String? prompt(String message) {
  stdout.write(message);
  return stdin.readLineSync();
}

int? promptInt(String message) => int.tryParse(prompt(message)?.trim() ?? '');
