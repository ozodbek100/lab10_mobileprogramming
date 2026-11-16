import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Welcome screen. Also the loading screen: while [loading] is true it shows
/// a spinner instead of the class chips and the button is disabled.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.labels,
    required this.loading,
    this.onStart,
  });

  final List<String> labels;
  final bool loading;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.xl),
                      Icon(Icons.center_focus_strong,
                          size: 56, color: scheme.primary),
                      const SizedBox(height: AppSpacing.md),
                      Text('Object Recognizer',
                          style: theme.textTheme.headlineMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Point it at one of your objects and it tells you '
                        'what it sees, fully offline.',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('It recognises', style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      if (loading)
                        Row(
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text('Loading model…',
                                style: theme.textTheme.bodyMedium),
                          ],
                        )
                      else
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            for (final l in labels) Chip(label: Text(l)),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: loading ? null : onStart,
                child: const Text('Get started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}