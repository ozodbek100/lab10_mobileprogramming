import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../services/classifier.dart';
import '../theme/app_theme.dart';
import '../theme/design_credit.dart';

class ModelScreen extends StatelessWidget {
  const ModelScreen({super.key, required this.app});
  final AppState app;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Read from the already loaded classifier, not from the file again.
    final labels = app.classifier.labels;
    final modelFile = Classifier.modelPath.split('/').last;

    return Scaffold(
      appBar: AppBar(title: const Text('Model')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Number of classes'),
                    trailing: Text('${labels.length}',
                        style: theme.textTheme.titleMedium),
                  ),
                  ListTile(
                    title: const Text('Input size'),
                    trailing: Text(
                      '${Classifier.inputSize} × ${Classifier.inputSize}',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  ListTile(
                    title: const Text('Model file'),
                    subtitle: Text(modelFile),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Labels', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [for (final l in labels) Chip(label: Text(l))],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Design credit', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            SelectableText(designCredit, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}