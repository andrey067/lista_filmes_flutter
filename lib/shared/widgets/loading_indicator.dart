import 'package:flutter/material.dart';

/// Carregamento com hierarquia tipográfica e contraste do tema.
/// Usado na HomeScreen (filme list) e FilmeDetailScreen (carregamento inicial).
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
          height: 1.4,
        );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: scheme.primary,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 20),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: style,
              ),
            ],
          ],
        ),
      ),
    );
  }
}