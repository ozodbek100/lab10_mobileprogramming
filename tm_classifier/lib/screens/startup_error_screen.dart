import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Icon(Icons.error_outline,
                  size: 48, color: theme.colorScheme.error),
              const SizedBox(height: AppSpacing.md),
              Text('The model could not be loaded',
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(message,
                      style: theme.textTheme.bodyMedium),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}