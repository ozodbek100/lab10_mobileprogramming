import 'package:flutter/foundation.dart';

import 'classifier.dart';

/// One finished classification, kept for the History screen.
class HistoryEntry {
  HistoryEntry({
    required this.bytes,
    required this.predictions,
    required this.source,
    required this.time,
  });

  final Uint8List bytes;
  final List<Prediction> predictions; // already sorted, best first
  final String source; // 'Camera' | 'Gallery' | 'Download'
  final DateTime time;

  Prediction get top => predictions.first;
}

class AppState extends ChangeNotifier {
  AppState(this.classifier);

  /// The single shared classifier (constructor injection).
  final Classifier classifier;

  /// Newest first.
  final List<HistoryEntry> history = [];

  /// How long the last classify() took, for the notes.
  int lastClassifyMs = 0;

  HistoryEntry? get latest => history.isEmpty ? null : history.first;

  /// bytes -> classify -> history. Every source uses this one method.
  HistoryEntry classify(Uint8List bytes, String source) {
    final sw = Stopwatch()..start();
    final predictions = classifier.classify(bytes);
    sw.stop();
    lastClassifyMs = sw.elapsedMilliseconds;
    debugPrint('classify($source) took $lastClassifyMs ms');

    final entry = HistoryEntry(
      bytes: bytes,
      predictions: predictions,
      source: source,
      time: DateTime.now(),
    );
    history.insert(0, entry);
    notifyListeners();
    return entry;
  }
}