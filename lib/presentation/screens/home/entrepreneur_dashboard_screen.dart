import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../widgets/role_home.dart';

class EntrepreneurDashboardScreen extends StatelessWidget {
  const EntrepreneurDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleHomeScreen(
      title: 'Inicio',
      greeting: 'Hola Microempresario',
      description:
          'Consulta contenidos, registra tu negocio y recibe acompañamiento para crecer.',
      icon: Icons.storefront,
      actions: [
        RoleHomeAction(
          label: 'Mis micronegocios',
          description: 'Registra, actualiza y consulta tu negocio',
          icon: Icons.add_business_outlined,
          route: '/micronegocios',
        ),
        RoleHomeAction(
          label: 'Cronograma',
          description: 'Talleres, contenidos y actividades',
          icon: Icons.event_available_outlined,
          route: '/contenidos',
          color: AppColors.secondary,
        ),
        RoleHomeAction(
          label: 'Foros',
          description: 'Preguntas a docentes y expertos',
          icon: Icons.forum_outlined,
          route: '/foros',
          color: AppColors.accent,
        ),
        RoleHomeAction(
          label: 'Alertas',
          description: 'Noticias oficiales y recordatorios',
          icon: Icons.notifications_active_outlined,
          route: '/noticias',
          color: AppColors.warning,
        ),
        RoleHomeAction(
          label: 'Perfil',
          description: 'Datos personales y contacto',
          icon: Icons.person_outline,
          route: '/perfil',
        ),
      ],
    );
  }
}
