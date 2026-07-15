import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_roles.dart';
import '../../../core/di/providers.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/app_scaffold.dart';

class TechSupportScreen extends ConsumerStatefulWidget {
  const TechSupportScreen({super.key});

  @override
  ConsumerState<TechSupportScreen> createState() => _TechSupportScreenState();
}

class _TechSupportScreenState extends ConsumerState<TechSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  String _category = 'Incidentes';
  String _priority = 'Media';
  bool _isSubmitting = false;

  static const _categories = [
    'Incidentes',
    'Acceso y contraseña',
    'Contenidos',
    'Micronegocios',
    'Foros y docentes',
    'Integraciones',
  ];

  static const _priorities = ['Baja', 'Media', 'Alta'];

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authViewModelProvider).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Debes iniciar sesión para enviar soporte.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final userName = user.name.trim().isEmpty ? 'Sin nombre' : user.name.trim();
    final detail = [
      'Solicitante: $userName',
      'Correo: ${user.email}',
      'UID: ${user.uid}',
      'Rol: ${AppRoles.label(user.role)}',
      'Categoría: $_category',
      'Prioridad: $_priority',
      'Asunto: ${_subjectCtrl.text.trim()}',
      'Mensaje: ${_messageCtrl.text.trim()}',
    ].join('\n');

    try {
      await ref.read(logRepositoryProvider).addLog(
            usuarioId: user.uid,
            accion: 'Solicitud de soporte técnico',
            modulo: 'soporte-ti',
            origen: 'mobile',
            detalle: detail,
          );

      if (!mounted) return;
      _subjectCtrl.clear();
      _messageCtrl.clear();
      setState(() {
        _category = 'Incidentes';
        _priority = 'Media';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud enviada. El equipo TI podrá verla en Logs.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo enviar la solicitud: $error')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _prefill(String category, String subject) {
    setState(() {
      _category = category;
      _subjectCtrl.text = subject;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authViewModelProvider).user;

    return AppScaffold(
      title: 'Servicio técnico',
      showBack: true,
      child: ListView(
        children: [
          const SectionHeader(
            title: 'Solicitud de soporte',
            subtitle:
                'Describe el problema para que quede registrado con tu usuario.',
            icon: Icons.support_agent_outlined,
          ),
          const SizedBox(height: 12),
          if (user != null) _RequesterCard(user: user),
          const SizedBox(height: 12),
          _QuickSupportOptions(onSelect: _prefill),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de solicitud',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: _categories
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(
                        () => _category = value ?? _categories.first,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _priority,
                      decoration: const InputDecoration(
                        labelText: 'Prioridad',
                        prefixIcon: Icon(Icons.priority_high_outlined),
                      ),
                      items: _priorities
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(
                        () => _priority = value ?? _priorities[1],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _subjectCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Asunto',
                        prefixIcon: Icon(Icons.subject_outlined),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Escribe el asunto.'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _messageCtrl,
                      minLines: 4,
                      maxLines: 7,
                      decoration: const InputDecoration(
                        labelText: 'Describe lo que ocurre',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.notes_outlined),
                      ),
                      validator: (value) =>
                          value == null || value.trim().length < 10
                              ? 'Describe el caso con más detalle.'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _isSubmitting ? null : _submit,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_outlined),
                      label: const Text('Enviar solicitud'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequesterCard extends StatelessWidget {
  const _RequesterCard({required this.user});

  final dynamic user;

  @override
  Widget build(BuildContext context) {
    final displayName =
        user.name.trim().isEmpty ? user.email.split('@').first : user.name;
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person_outline)),
        title: Text(displayName),
        subtitle: Text('${user.email}\n${AppRoles.label(user.role)}'),
        isThreeLine: true,
      ),
    );
  }
}

class _QuickSupportOptions extends StatelessWidget {
  const _QuickSupportOptions({required this.onSelect});

  final void Function(String category, String subject) onSelect;

  @override
  Widget build(BuildContext context) {
    final options = [
      ('Acceso y contraseña', 'No puedo ingresar a mi cuenta'),
      ('Contenidos', 'No veo un contenido o evento'),
      ('Micronegocios', 'Tengo problemas con mi micronegocio'),
      ('Foros y docentes', 'Necesito ayuda con docentes o foros'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options
          .map(
            (option) => ActionChip(
              avatar: const Icon(Icons.help_outline, size: 18),
              label: Text(option.$1),
              onPressed: () => onSelect(option.$1, option.$2),
            ),
          )
          .toList(),
    );
  }
}
