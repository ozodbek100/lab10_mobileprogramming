import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../services/image_sources.dart';
import '../theme/app_theme.dart';
import '../widgets/download_dialog.dart';
import '../widgets/source_icon.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.app});
  final AppState app;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _sources = ImageSources();
  bool _busy = false;

  /// THE shared path: bytes -> classify -> History -> Result.
  /// Camera, gallery and download all go through this one method.
  Future<void> _run(
    Future<Uint8List?> Function() getBytes,
    String source,
  ) async {
    if (_busy) return;
    try {
      final bytes = await getBytes();
      if (bytes == null) return; // the user cancelled: change nothing
      if (!mounted) return;

      // classify() runs on the UI thread and freezes the screen while the
      // model works. Show the busy layer first and give Flutter a moment to
      // paint it.
      setState(() => _busy = true);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final entry = widget.app.classify(bytes, source);
      if (!mounted) return;
      openResult(context, entry);
    } on FormatException catch (e) {
      _showError('Could not classify this file: ${e.message}');
    } catch (e) {
      _showError('$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _download() async {
    final bytes = await showDialog<Uint8List>(
      context: context,
      builder: (_) => DownloadDialog(sources: _sources),
    );
    if (bytes == null || !mounted) return; // cancelled
    // The dialog only downloaded. Classifying uses the same shared path.
    await _run(() async => bytes, 'Download');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: SafeArea(
        child: Stack(
          children: [
            ListenableBuilder(
              listenable: widget.app,
              builder: (context, _) {
                final latest = widget.app.latest;
                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    _ActionCard(
                      icon: Icons.photo_camera,
                      title: 'Take a photo',
                      subtitle: 'Use the phone camera',
                      onTap: () => _run(_sources.fromCamera, 'Camera'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _ActionCard(
                      icon: Icons.photo_library,
                      title: 'Choose from gallery',
                      subtitle: 'Pick a picture you already have',
                      onTap: () => _run(_sources.fromGallery, 'Gallery'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _ActionCard(
                      icon: Icons.cloud_download,
                      title: 'Download an image',
                      subtitle: 'Classify a picture from a web address',
                      onTap: _download,
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
            if (_busy)
              Positioned.fill(
                child: ColoredBox(
                  color: scheme.scrim.withValues(alpha: 0.4),
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: AppSpacing.md),
                            Text('Classifying…',
                                style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
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