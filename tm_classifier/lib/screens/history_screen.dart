import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/source_icon.dart';
import 'result_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.app});
  final AppState app;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: app,
          builder: (context, _) {
            if (app.history.isEmpty) return const _EmptyState();

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: app.history.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final e = app.history[i];
                final percent = (e.top.confidence * 100).toStringAsFixed(1);
                return Card(
                  child: ListTile(
                    onTap: () => openResult(context, e),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.image),
                      child: Image.memory(
                        e.bytes,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        cacheWidth: 112,
                      ),
                    ),
                    title: Text(e.top.label,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('$percent %'),
                    trailing: Icon(sourceIcon(e.source)),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 56, color: theme.colorScheme.outline),
            const SizedBox(height: AppSpacing.md),
            Text('No classifications yet',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Classify a picture on the Home tab and it will show up here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}