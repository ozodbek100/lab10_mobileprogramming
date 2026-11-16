import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'labels.dart';

/// One label with its probability (0.0 to 1.0).
class Prediction {
  const Prediction(this.label, this.confidence);
  final String label;
  final double confidence;
}

/// Thrown when the model or labels cannot be loaded. The message says
/// what is missing and where it was expected, so it can be shown on screen.
class ModelLoadException implements Exception {
  ModelLoadException(this.message);
  final String message;

  @override
  String toString() => message;
}

class Classifier {
  Classifier._(this._interpreter, this.labels);

  final Interpreter _interpreter;
  final List<String> labels;

  static const inputSize = 224;
  static const modelPath = 'assets/model/model_unquant.tflite';
  static const labelsPath = 'assets/model/labels.txt';

  /// Loads the model and labels. Slow, so call it ONCE at start-up.
  static Future<Classifier> load() async {
    Interpreter interpreter;
    try {
      interpreter = await Interpreter.fromAsset(modelPath);
    } catch (e) {
      throw ModelLoadException(
        'Could not load the model.\n'
        'Expected file: $modelPath\n'
        'Check that the file exists and that assets/model/ is listed '
        'in pubspec.yaml.\n\nDetails: $e',
      );
    }

    String raw;
    try {
      raw = await rootBundle.loadString(labelsPath);
    } catch (e) {
      interpreter.close();
      throw ModelLoadException(
        'Could not load the labels.\n'
        'Expected file: $labelsPath\n\nDetails: $e',
      );
    }

    final labels = parseLabels(raw);

    // The model's output must have exactly one number per label.
    final outputClasses = interpreter.getOutputTensor(0).shape.last;
    if (outputClasses != labels.length) {
      interpreter.close();
      throw ModelLoadException(
        'The model has $outputClasses classes but labels.txt has '
        '${labels.length} lines. Re-export both files together.',
      );
    }

    return Classifier._(interpreter, labels);
  }

  /// Bytes in, sorted predictions out (highest confidence first).
  List<Prediction> classify(Uint8List bytes) {
    // 1. Decode the picture (jpg, png, ...). Not an image -> readable error.
    img.Image? decoded;
    try {
      decoded = img.decodeImage(bytes);
    } catch (_) {
      decoded = null;
    }
    if (decoded == null) {
      throw const FormatException('Not a readable image');
    }

    // 2. Same crop as in training: square from the centre, 224x224.
    //    bakeOrientation applies the EXIF rotation phone cameras store.
    final square = img.copyResizeCropSquare(
      img.bakeOrientation(decoded),
      size: inputSize,
    );

    // 3. Input tensor, shape [1, 224, 224, 3], every value in -1..1.
    final input = [
      List.generate(
        inputSize,
        (y) => List.generate(inputSize, (x) {
          final p = square.getPixel(x, y);
          return [p.r / 127.5 - 1, p.g / 127.5 - 1, p.b / 127.5 - 1];
        }),
      ),
    ];

    // 4. Output tensor, shape [1, number of classes].
    final output = [List<double>.filled(labels.length, 0)];
    _interpreter.run(input, output);

    // 5. Pair index i with label i FIRST, then sort.
    return [
      for (var i = 0; i < labels.length; i++)
        Prediction(labels[i], output.first[i]),
    ]..sort((a, b) => b.confidence.compareTo(a.confidence));
  }

  void close() => _interpreter.close();
}