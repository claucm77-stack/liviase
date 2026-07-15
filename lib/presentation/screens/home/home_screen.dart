import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/app_scaffold.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    return AppScaffold(
      title: 'Dashboard',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Bienvenido ${authState.user?.email ?? ''}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          const Text('Base del dashboard según diseño de Figma.'),
          const Spacer(),
          ElevatedButton(
            onPressed: () async {
              await ref.read(authViewModelProvider.notifier).signOut();
              if (context.mounted) context.go('/');
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
