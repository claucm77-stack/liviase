import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../widgets/role_home.dart';

class EducatorDashboardScreen extends StatelessWidget {
  const EducatorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleHomeScreen(
      title: 'Panel docente',
      greeting: 'Hola Docente',
      description:
          'Gestiona contenidos académicos, atiende consultas y acompaña a los microempresarios.',
      icon: Icons.school_outlined,
      actions: [
        RoleHomeAction(
          label: 'Cronograma',
          description: 'Actividades, talleres y materiales académicos',
          icon: Icons.event_note_outlined,
          route: '/contenidos',
          color: AppColors.secondary,
        ),
        RoleHomeAction(
          label: 'Foros',
          description: 'Responder consultas por tema',
          icon: Icons.forum_outlined,
          route: '/foros',
          color: AppColors.accent,
        ),
        RoleHomeAction(
          label: 'Alertas oficiales',
          description: 'Fuentes DIAN, SIC, Cámara y Secretaría',
          icon: Icons.campaign_outlined,
          route: '/noticias',
          color: AppColors.warning,
        ),
        RoleHomeAction(
          label: 'Directorio',
          description: 'Consulta micronegocios registrados',
          icon: Icons.storefront,
          route: '/micronegocios',
        ),
        RoleHomeAction(
          label: 'Perfil',
          description: 'Información de cuenta docente',
          icon: Icons.person_outline,
          route: '/perfil',
        ),
      ],
    );
  }
}
