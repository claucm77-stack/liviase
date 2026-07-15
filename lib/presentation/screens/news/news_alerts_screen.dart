import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_roles.dart';
import '../../../core/di/providers.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/app_scaffold.dart';

class NewsAlertsScreen extends ConsumerWidget {
  const NewsAlertsScreen({super.key});

  static const _alerts = [
    (
      'dian-calendario',
      'DIAN',
      'Calendario tributario para microempresas',
      'Fuente oficial pendiente de sincronización'
    ),
    (
      'ccb-renovacion',
      'Cámara de Comercio',
      'Renovación de matrícula mercantil',
      'Segmentado por sector económico'
    ),
    (
      'sic-consumidor',
      'SIC',
      'Recomendaciones de protección al consumidor',
      'Actualización normativa'
    ),
    (
      'desarrollo-convocatorias',
      'Secretaría de Desarrollo Económico',
      'Convocatorias y programas de fomento',
      'Alertas personalizables'
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authViewModelProvider).user;
    final canRate = AppRoles.isMicroempresario(user?.role);

    return AppScaffold(
      title: 'Noticias y alertas',
      showBack: true,
      child: ListView.separated(
        itemCount: _alerts.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const SectionHeader(
              title: 'Fuentes oficiales',
              subtitle:
                  'Información de entidades para seguimiento académico y empresarial.',
              icon: Icons.campaign_outlined,
            );
          }

          final alert = _alerts[index - 1];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.campaign_outlined),
              title: Text(alert.$2),
              subtitle: _EventRatingSubtitle(
                eventId: alert.$1,
                text: '${alert.$3}\n${alert.$4}',
              ),
              isThreeLine: true,
              trailing: canRate
                  ? IconButton(
                      tooltip: 'Calificar evento',
                      onPressed: () => _rateEvent(context, ref, alert.$1),
                      icon: const Icon(
                        Icons.star_rate,
                        color: Color(0xFFFFCA55),
                      ),
                    )
                  : const Icon(Icons.notifications_active_outlined),
            ),
          );
        },
      ),
    );
  }

  Future<void> _rateEvent(
    BuildContext context,
    WidgetRef ref,
    String eventId,
  ) async {
    final user = ref.read(authViewModelProvider).user;
    if (user == null) return;

    final rating = await showDialog<double>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Calificar evento'),
        children: [
          for (var value = 5; value >= 1; value--)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, value.toDouble()),
              child: Row(
                children: [
                  for (var i = 0; i < value; i++)
                    const Icon(Icons.star, color: Color(0xFFFFCA55)),
                  const SizedBox(width: 8),
                  Text('$value'),
                ],
              ),
            ),
        ],
      ),
    );

    if (rating == null) return;
    await ref.read(firestoreServiceProvider).rateEvent(
          eventId: eventId,
          userId: user.uid,
          rating: rating,
        );
  }
}

class _EventRatingSubtitle extends ConsumerWidget {
  const _EventRatingSubtitle({
    required this.eventId,
    required this.text,
  });

  final String eventId;
  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder(
      stream: ref.watch(firestoreServiceProvider).watchEventRatings(eventId),
      builder: (context, snapshot) {
        final docs = snapshot.data ?? const [];
        final ratings = docs
            .map((doc) => (doc.data()['rating'] as num?)?.toDouble())
            .whereType<double>()
            .toList();
        final avg = ratings.isEmpty
            ? null
            : ratings.reduce((a, b) => a + b) / ratings.length;
        final ratingText = avg == null
            ? 'Sin calificaciones'
            : 'Calificación: ${avg.toStringAsFixed(1)} (${ratings.length})';
        return Text('$text\n$ratingText');
      },
    );
  }
}
