import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/providers.dart';
import '../../../domain/entities/business_entity.dart';

class EntitiesScreen extends ConsumerStatefulWidget {
  const EntitiesScreen({super.key});

  @override
  ConsumerState<EntitiesScreen> createState() => _EntitiesScreenState();
}

class _EntitiesScreenState extends ConsumerState<EntitiesScreen> {
  String _query = '';

  static final _exampleEntities = [
    BusinessEntity(
      id: 'camara-comercio-bogota',
      name: 'Cámara de Comercio Bogotá',
      imageUrl:
          'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=900&q=80',
      mainUrl: 'https://www.ccb.org.co/',
      createdAt: DateTime(2026, 6, 3),
      resources: const [
        EntityResource(
          name: 'Registro mercantil',
          url: 'https://www.ccb.org.co/servicios-registrales',
          type: EntityResourceType.link,
        ),
        EntityResource(
          name: 'Guía para empresarios',
          url: 'https://www.ccb.org.co/empresarial',
          type: EntityResourceType.link,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final entitiesStream = ref.watch(businessEntityRepositoryProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 92,
        leadingWidth: 56,
        leading: IconButton(
          tooltip: 'Cerrar',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
          icon: const Icon(
            Icons.arrow_back,
            size: 34,
            color: Color(0xFF789CA5),
          ),
        ),
        title: Text(
          'Entidades',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF7A7A7A),
                fontWeight: FontWeight.w800,
              ),
        ),
        centerTitle: false,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: StreamBuilder<List<BusinessEntity>>(
        stream: entitiesStream.watchEntities(),
        builder: (context, snapshot) {
          final remoteEntities = snapshot.data ?? const <BusinessEntity>[];
          final entities = [
            ...(remoteEntities.isEmpty ? _exampleEntities : remoteEntities),
          ]..sort((a, b) => a.name.compareTo(b.name));
          final q = _query.trim().toLowerCase();
          final filtered = entities
              .where((entity) =>
                  q.isEmpty || entity.name.toLowerCase().contains(q))
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 30, 14, 28),
            children: [
              TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Nombre de entidad',
                  prefixIcon: const Icon(Icons.search, size: 30),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFF4C8D93), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFF4C8D93), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              else if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: Text('No hay entidades publicadas.')),
                )
              else
                ...filtered.map(
                  (entity) => Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: _EntityCard(entity: entity),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _EntityCard extends StatelessWidget {
  const _EntityCard({required this.entity});

  final BusinessEntity entity;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: entity.name,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(2),
          onTap: () => _showEntityLinks(context, entity),
          child: Ink(
            height: 154,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    entity.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF4C8D93),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.apartment_outlined,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x00000000),
                          Color(0x12000000),
                          Color(0xD9000000),
                        ],
                        stops: [0.35, 0.58, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 18,
                    child: Text(
                      entity.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            height: 1.02,
                            letterSpacing: 0,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEntityLinks(BuildContext context, BusinessEntity entity) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            children: [
              Text(
                entity.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 16),
              if (entity.mainUrl.trim().isNotEmpty)
                FilledButton.icon(
                  onPressed: () => _open(entity.mainUrl),
                  icon: const Icon(Icons.open_in_new),
                  label: Text(entity.name),
                ),
              const SizedBox(height: 10),
              ...entity.resources.map(
                (resource) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton.icon(
                    onPressed: () => _open(resource.url),
                    icon: Icon(
                      resource.type == EntityResourceType.pdf
                          ? Icons.picture_as_pdf_outlined
                          : Icons.link,
                    ),
                    label: Text(resource.name),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
