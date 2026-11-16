import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/source_icon.dart';
import 'result_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.app});
  final AppState app;

  /// PART 4 PLACEHOLDER: classifies the bundled sample image.
  /// Part 5 replaces this with real camera / gallery / download bytes.
  Future<void> _placeholder(BuildContext context, String source) async {
    try {
      final data = await rootBundle.load('assets/model/sample.jpg');
      final bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      final entry = app.classify(bytes, source);
      if (!context.mounted) return;
      openResult(context, entry);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: app,
          builder: (context, _) {
            final latest = app.latest;
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                _ActionCard(
                  icon: Icons.photo_camera,
                  title: 'Take a photo',
                  subtitle: 'Use the phone camera',
                  onTap: () => _placeholder(context, 'Camera'),
                ),
                const SizedBox(height: AppSpacing.md),
                _ActionCard(
                  icon: Icons.photo_library,
                  title: 'Choose from gallery',
                  subtitle: 'Pick a picture you already have',
                  onTap: () => _placeholder(context, 'Gallery'),
                ),
                const SizedBox(height: AppSpacing.md),
                _ActionCard(
                  icon: Icons.cloud_download,
                  title: 'Download an image',
                  subtitle: 'Classify a picture from a web address',
                  onTap: () => _placeholder(context, 'Download'),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Latest result', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                if (latest == null)
                  Text('Nothing classified yet.',
                      style: theme.textTheme.bodyMedium)
                else
                  _LatestCard(entry: latest),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: Icon(icon),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    Text(subtitle, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _LatestCard extends StatelessWidget {
  const _LatestCard({required this.entry});
  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (entry.top.confidence * 100).toStringAsFixed(1);

    return Card(
      child: InkWell(
        onTap: () => openResult(context, entry),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.image),
                child: Image.memory(
                  entry.bytes,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  cacheWidth: 128,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.top.label,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text('$percent %', style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              Icon(sourceIcon(entry.source)),
            ],
          ),
        ),
      ),
    );
  }
}