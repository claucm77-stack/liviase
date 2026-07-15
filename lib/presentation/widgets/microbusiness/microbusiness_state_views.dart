import 'package:flutter/material.dart';

class MicrobusinessLoadingView extends StatelessWidget {
  const MicrobusinessLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class MicrobusinessErrorView extends StatelessWidget {
  const MicrobusinessErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42, color: Colors.redAccent),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class MicrobusinessEmptyView extends StatelessWidget {
  const MicrobusinessEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No se encontraron micronegocios con esos filtros.'),
    );
  }
}
