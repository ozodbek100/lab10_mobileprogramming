import 'package:flutter/material.dart';

import '../services/classifier.dart';
import '../theme/app_theme.dart';

class ConfidenceRow extends StatelessWidget {
  const ConfidenceRow({super.key, required this.prediction, required this.top});

  final Prediction prediction;
  final bool top;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final style = top ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium;
    final percent = (prediction.confidence * 100).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: top ? scheme.primaryContainer : null,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              prediction.label,
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.button),
              child: LinearProgressIndicator(
                value: prediction.confidence.clamp(0.0, 1.0),
                minHeight: 8,
                color: top ? scheme.primary : scheme.outline,
                backgroundColor: scheme.surfaceContainerHighest,
              ),
            ),
          ),
          SizedBox(
            width: 68,
            child: Text(
              '$percent %',
              textAlign: TextAlign.right,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}