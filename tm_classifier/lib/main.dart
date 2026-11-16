import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'services/classifier.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

/// T11: the classifier is created exactly ONCE, here, and passed down.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // Created once in the State, NOT inside build(), otherwise every rebuild
  // would load the model again.
  late final Future<Classifier> _classifierFuture = Classifier.load();

  @override
  void dispose() {
    // Release the native interpreter when the app shuts down.
    _classifierFuture.then((c) => c.close(), onError: (_) {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TM Classifier',
      home: FutureBuilder<Classifier>(
        future: _classifierFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return StartupErrorScreen(message: '${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return const LoadingScreen();
          }
          // Constructor injection: the screen receives the instance.
          return SmokeTestScreen(classifier: snapshot.data!);
        },
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading model…'),
          ],
        ),
      ),
    );
  }
}

/// T12: shown when the model or labels cannot be loaded.
class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              const Text('The model could not be loaded'),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(child: SelectableText(message)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// T10 + T12: temporary screen to test the classifier.
class SmokeTestScreen extends StatefulWidget {
  const SmokeTestScreen({super.key, required this.classifier});
  final Classifier classifier;

  @override
  State<SmokeTestScreen> createState() => _SmokeTestScreenState();
}

class _SmokeTestScreenState extends State<SmokeTestScreen> {
  String _output = 'Press a button to test the classifier.';

  /// T10: classify assets/model/sample.jpg and print every label.
  Future<void> _runSample() async {
    try {
      final data = await rootBundle.load('assets/model/sample.jpg');
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      final sw = Stopwatch()..start();
      final results = widget.classifier.classify(bytes);
      sw.stop();

      final sum = results.fold<double>(0, (a, p) => a + p.confidence);
      final lines = [
        for (final p in results)
          '${p.label}: ${(p.confidence * 100).toStringAsFixed(1)} %',
      ];

      for (final line in lines) {
        debugPrint(line);
      }
      debugPrint('lines = ${results.length}, sum = $sum');
      debugPrint('classify took ${sw.elapsedMilliseconds} ms');

      setState(() {
        _output = '${lines.join('\n')}\n\n'
            'sum = ${sum.toStringAsFixed(4)}\n'
            'time = ${sw.elapsedMilliseconds} ms';
      });
    } catch (e) {
      setState(() => _output = 'Error: $e');
    }
  }

  /// T12: a text file is not an image. Must show a message, never crash.
  void _runBadInput() {
    try {
      final bytes = Uint8List.fromList(utf8.encode('this is not an image'));
      widget.classifier.classify(bytes);
      setState(() => _output = 'Unexpected: no error was thrown.');
    } on FormatException catch (e) {
      setState(() => _output = 'Could not classify: ${e.message}');
    } catch (e) {
      setState(() => _output = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Part 3: classifier test')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(
                onPressed: _runSample,
                child: const Text('Classify sample.jpg'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _runBadInput,
                child: const Text('Classify a text file (must fail politely)'),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(child: SelectableText(_output)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}