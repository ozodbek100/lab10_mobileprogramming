import 'package:flutter/material.dart';

import 'screens/shell.dart';
import 'screens/startup_error_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/app_state.dart';
import 'services/classifier.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Root());
}

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  // Loaded exactly once. No screen calls Classifier.load() itself.
  late final Future<Classifier> _future = Classifier.load();
  AppState? _app;
  bool _started = false;

  @override
  void dispose() {
    _app?.dispose();
    _future.then((c) => c.close(), onError: (_) {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Object Recognizer',
      theme: buildTheme(),
      home: FutureBuilder<Classifier>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return StartupErrorScreen(message: '${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return const WelcomeScreen(labels: [], loading: true);
          }
          final app = _app ??= AppState(snapshot.data!);
          if (!_started) {
            return WelcomeScreen(
              labels: app.classifier.labels,
              loading: false,
              onStart: () => setState(() => _started = true),
            );
          }
          return Shell(app: app);
        },
      ),
    );
  }
}