import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../viewmodels/dashboard_viewmodel.dart';

class LogsScreen extends ConsumerWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardViewModelProvider);
    final vm = ref.read(dashboardViewModelProvider.notifier);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String?>(
                initialValue: state.logsModuloFilter,
                decoration: const InputDecoration(
                  labelText: 'Módulo',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Todos')),
                  DropdownMenuItem(
                    value: 'dashboard',
                    child: Text('Dashboard'),
                  ),
                  DropdownMenuItem(value: 'usuarios', child: Text('Usuarios')),
                  DropdownMenuItem(
                    value: 'contenidos',
                    child: Text('Contenidos'),
                  ),
                  DropdownMenuItem(
                    value: 'micronegocios',
                    child: Text('Micronegocios'),
                  ),
                  DropdownMenuItem(
                    value: 'soporte-ti',
                    child: Text('Soporte TI'),
                  ),
                ],
                onChanged: vm.setLogsModuloFilter,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Usuario o detalle',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: vm.setGlobalSearchQuery,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _filteredLogs(state).isEmpty
              ? const Center(child: Text('Sin logs registrados'))
              : ListView.separated(
                  itemCount: _filteredLogs(state).length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final log = _filteredLogs(state)[index];
                    return ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(log.accion),
                      subtitle: Text(
                        'Módulo: ${log.modulo} • Usuario: ${log.usuarioId}'
                        '${log.detalle.isEmpty ? '' : '\n${log.detalle}'}',
                      ),
                      trailing: Text(
                        '${log.fecha.day.toString().padLeft(2, '0')}/${log.fecha.month.toString().padLeft(2, '0')} ${log.fecha.hour.toString().padLeft(2, '0')}:${log.fecha.minute.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<dynamic> _filteredLogs(DashboardState state) {
    final q = state.globalSearchQuery.trim().toLowerCase();
    if (q.isEmpty) return state.logs;
    return state.logs.where((log) {
      return log.usuarioId.toLowerCase().contains(q) ||
          log.modulo.toLowerCase().contains(q) ||
          log.accion.toLowerCase().contains(q) ||
          log.detalle.toLowerCase().contains(q);
    }).toList();
  }
}
