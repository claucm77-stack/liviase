import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../domain/entities/business_entity.dart';

class EntitiesManagementScreen extends ConsumerWidget {
  const EntitiesManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(businessEntityRepositoryProvider);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Entidades',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            FilledButton.icon(
              onPressed: () => _openEditor(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Crear entidad'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: StreamBuilder<List<BusinessEntity>>(
            stream: repository.watchEntities(),
            builder: (context, snapshot) {
              final entities = snapshot.data ?? const <BusinessEntity>[];

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (entities.isEmpty) {
                return const Center(
                  child: Text('Aún no hay entidades creadas.'),
                );
              }

              return ListView.separated(
                itemCount: entities.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final entity = entities[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        entity.imageUrl,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 52,
                          height: 52,
                          color: const Color(0xFF4C8D93),
                          child: const Icon(
                            Icons.apartment_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    title: Text(entity.name),
                    subtitle: Text(
                      '${entity.resources.length} enlaces/PDF adicionales',
                    ),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          tooltip: 'Editar',
                          onPressed: () =>
                              _openEditor(context, ref, existingEntity: entity),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: 'Eliminar',
                          onPressed: () => _confirmDelete(context, ref, entity),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    BusinessEntity? existingEntity,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _EntityEditorDialog(
        initialEntity: existingEntity,
        onSave: (entity) async {
          await ref.read(businessEntityRepositoryProvider).saveEntity(entity);
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    BusinessEntity entity,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar entidad'),
        content: Text('Se eliminará ${entity.name}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(businessEntityRepositoryProvider).deleteEntity(entity.id);
    }
  }
}

class _EntityEditorDialog extends StatefulWidget {
  const _EntityEditorDialog({
    required this.onSave,
    this.initialEntity,
  });

  final BusinessEntity? initialEntity;
  final Future<void> Function(BusinessEntity entity) onSave;

  @override
  State<_EntityEditorDialog> createState() => _EntityEditorDialogState();
}

class _EntityEditorDialogState extends State<_EntityEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _imageCtrl;
  late final TextEditingController _mainUrlCtrl;
  late final List<_ResourceDraft> _resources;
  var _isSaving = false;

  @override
  void initState() {
    super.initState();
    final entity = widget.initialEntity;
    _nameCtrl = TextEditingController(text: entity?.name ?? '');
    _imageCtrl = TextEditingController(text: entity?.imageUrl ?? '');
    _mainUrlCtrl = TextEditingController(text: entity?.mainUrl ?? '');
    _resources = [
      ...(entity?.resources ?? const <EntityResource>[])
          .map(_ResourceDraft.new),
    ];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _imageCtrl.dispose();
    _mainUrlCtrl.dispose();
    for (final resource in _resources) {
      resource.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.initialEntity == null ? 'Crear entidad' : 'Editar entidad'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la entidad',
                    border: OutlineInputBorder(),
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _imageCtrl,
                  decoration: const InputDecoration(
                    labelText: 'URL de foto',
                    border: OutlineInputBorder(),
                  ),
                  validator: _requiredUrl,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _mainUrlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Enlace principal',
                    border: OutlineInputBorder(),
                  ),
                  validator: _requiredUrl,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Enlaces y PDF',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _resources.add(_ResourceDraft.empty());
                        });
                      },
                      icon: const Icon(Icons.add_link),
                      label: const Text('Añadir'),
                    ),
                  ],
                ),
                ..._resources.asMap().entries.map(
                      (entry) => _ResourceEditor(
                        key: ValueKey(entry.value),
                        draft: entry.value,
                        onRemove: () {
                          setState(() {
                            _resources.removeAt(entry.key).dispose();
                          });
                        },
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'Campo obligatorio' : null;
  }

  String? _requiredUrl(String? value) {
    final text = value?.trim() ?? '';
    final uri = Uri.tryParse(text);
    if (text.isEmpty) return 'Campo obligatorio';
    if (uri == null || uri.scheme.isEmpty || uri.host.isEmpty) {
      return 'Ingresa una URL válida';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final existing = widget.initialEntity;
    final entity = BusinessEntity(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      imageUrl: _imageCtrl.text.trim(),
      mainUrl: _mainUrlCtrl.text.trim(),
      createdAt: existing?.createdAt ?? DateTime.now(),
      resources: _resources
          .map((draft) => draft.toResource())
          .where(
              (resource) => resource.name.isNotEmpty && resource.url.isNotEmpty)
          .toList(),
    );

    await widget.onSave(entity);
    if (mounted) Navigator.pop(context);
  }
}

class _ResourceDraft {
  _ResourceDraft(EntityResource resource)
      : nameCtrl = TextEditingController(text: resource.name),
        urlCtrl = TextEditingController(text: resource.url),
        type = resource.type;

  _ResourceDraft.empty()
      : nameCtrl = TextEditingController(),
        urlCtrl = TextEditingController(),
        type = EntityResourceType.link;

  final TextEditingController nameCtrl;
  final TextEditingController urlCtrl;
  EntityResourceType type;

  EntityResource toResource() {
    return EntityResource(
      name: nameCtrl.text.trim(),
      url: urlCtrl.text.trim(),
      type: type,
    );
  }

  void dispose() {
    nameCtrl.dispose();
    urlCtrl.dispose();
  }
}

class _ResourceEditor extends StatefulWidget {
  const _ResourceEditor({
    super.key,
    required this.draft,
    required this.onRemove,
  });

  final _ResourceDraft draft;
  final VoidCallback onRemove;

  @override
  State<_ResourceEditor> createState() => _ResourceEditorState();
}

class _ResourceEditorState extends State<_ResourceEditor> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: widget.draft.nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Quitar',
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.draft.urlCtrl,
              decoration: const InputDecoration(
                labelText: 'URL del enlace o PDF',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<EntityResourceType>(
              segments: const [
                ButtonSegment(
                  value: EntityResourceType.link,
                  icon: Icon(Icons.link),
                  label: Text('Enlace'),
                ),
                ButtonSegment(
                  value: EntityResourceType.pdf,
                  icon: Icon(Icons.picture_as_pdf_outlined),
                  label: Text('PDF'),
                ),
              ],
              selected: {widget.draft.type},
              onSelectionChanged: (value) {
                setState(() => widget.draft.type = value.first);
              },
            ),
          ],
        ),
      ),
    );
  }
}
