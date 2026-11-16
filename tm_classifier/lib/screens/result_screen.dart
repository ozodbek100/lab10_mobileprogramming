import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/confidence_row.dart';
import '../widgets/source_icon.dart';

/// Opens the Result screen for [entry].
void openResult(BuildContext context, HistoryEntry entry) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => ResultScreen(entry: entry)),
  );
}

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.entry});
  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final maxImageHeight = MediaQuery.of(context).size.height * 0.5;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Chip(
              avatar: Icon(sourceIcon(entry.source), size: 18),
              label: Text(entry.source),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxImageHeight),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.image),
                  child: Image.memory(entry.bytes, fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (var i = 0; i < entry.predictions.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: ConfidenceRow(
                  prediction: entry.predictions[i],
                  top: i == 0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}