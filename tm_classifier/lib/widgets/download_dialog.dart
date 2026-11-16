import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/image_sources.dart';
import '../theme/app_theme.dart';

class DownloadDialog extends StatefulWidget {
  const DownloadDialog({super.key, required this.sources});
  final ImageSources sources;

  @override
  State<DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _download() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final Uint8List bytes = await widget.sources.fromUrl(_controller.text);
      if (!mounted) return; // the dialog was closed meanwhile
      Navigator.of(context).pop(bytes);
    } on ImageSourceException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Something went wrong: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Download an image'),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            enabled: !_loading,
            autofocus: true,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _download(),
            decoration: const InputDecoration(
              labelText: 'Image address',
              hintText: 'https://…',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_loading) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: AppSpacing.sm),
            Text('Downloading…', style: theme.textTheme.bodyMedium),
          ],
          if (_error != null)
            Text(
              _error!,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.error),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        // The theme's FilledButton is full width. Inside dialog actions that
        // breaks the layout, so this one gets a normal minimum size.
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(96, 48)),
          onPressed: _loading ? null : _download,
          child: const Text('Download'),
        ),
      ],
    );
  }
}