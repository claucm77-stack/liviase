import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/di/providers.dart';
import '../../viewmodels/auth_viewmodel.dart';

class TeachersScreen extends ConsumerStatefulWidget {
  const TeachersScreen({super.key});

  @override
  ConsumerState<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends ConsumerState<TeachersScreen> {
  String _query = '';
  String _category = 'Publicidad';

  static const _categories = ['Publicidad', 'Derecho', 'Contabilidad'];

  static const _teachers = [
    _Teacher(
      id: 'alirio_camacho',
      name: 'Alirio Camacho',
      area: 'Publicidad',
      specialty: 'Marketing Digital',
      imageUrl:
          'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=300&q=80',
    ),
    _Teacher(
      id: 'ana_maria_camelo',
      name: 'Ana María Camelo',
      area: 'Derecho',
      specialty: 'Administrativo',
      imageUrl:
          'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=300&q=80',
    ),
    _Teacher(
      id: 'antonio_fernandez',
      name: 'Antonio Fernandez',
      area: 'Contaduría',
      specialty: 'Tributación',
      imageUrl:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=300&q=80',
    ),
    _Teacher(
      id: 'pedro_rosas',
      name: 'Pedro Rosas',
      area: 'Administración',
      specialty: 'Emprendimiento',
      imageUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _teachers.where((teacher) {
      final q = _query.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          teacher.name.toLowerCase().contains(q) ||
          teacher.area.toLowerCase().contains(q) ||
          teacher.specialty.toLowerCase().contains(q);
      final matchesCategory = _category == 'Publicidad'
          ? true
          : teacher.area.toLowerCase().contains(_category.toLowerCase());
      return matchesQuery && matchesCategory;
    }).toList();

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
          'Docentes',
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 34, 14, 24),
        children: [
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Nombre o negocio',
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
          const SizedBox(height: 34),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                if (index == _categories.length) {
                  return IconButton(
                    tooltip: 'Más categorías',
                    onPressed: () {},
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Color(0xFF4C8D93),
                      size: 34,
                    ),
                  );
                }
                final category = _categories[index];
                return ChoiceChip(
                  label: Text(category),
                  selected: _category == category,
                  onSelected: (_) => setState(() => _category = category),
                  showCheckmark: false,
                  selectedColor: const Color(0xFFFFC34E),
                  backgroundColor: const Color(0xFFFFC34E),
                  labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                    side: BorderSide.none,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 44),
          ...filtered.map(
            (teacher) => Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: _TeacherTile(
                teacher: teacher,
                onMessage: () => _openChat(context, teacher),
                onRate: () => _rateTeacher(teacher),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openChat(BuildContext context, _Teacher teacher) {
    final params = {
      'id': teacher.id,
      'name': teacher.name,
      'area': '${teacher.area} · ${teacher.specialty}',
      'image': teacher.imageUrl,
    };
    context
        .push(Uri(path: '/docentes/chat', queryParameters: params).toString());
  }

  Future<void> _rateTeacher(_Teacher teacher) async {
    final user = ref.read(authViewModelProvider).user;
    if (user == null || !AppRoles.isMicroempresario(user.role)) return;

    final rating = await showDialog<double>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Calificar a ${teacher.name}'),
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
    await ref.read(firestoreServiceProvider).rateTeacher(
          teacherId: teacher.id,
          userId: user.uid,
          rating: rating,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gracias por calificar a ${teacher.name}.')),
    );
  }
}

class _TeacherTile extends ConsumerWidget {
  const _TeacherTile({
    required this.teacher,
    required this.onMessage,
    required this.onRate,
  });

  final _Teacher teacher;
  final VoidCallback onMessage;
  final VoidCallback onRate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authViewModelProvider).user;
    final canRate = AppRoles.isMicroempresario(user?.role);
    return Row(
      children: [
        ClipOval(
          child: Image.network(
            teacher.imageUrl,
            width: 76,
            height: 76,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 76,
              height: 76,
              color: AppColors.surfaceAlt,
              child: const Icon(Icons.person, color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                teacher.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
              ),
              Text(
                teacher.area,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black,
                      fontSize: 16,
                      height: 1.2,
                    ),
              ),
              Text(
                teacher.specialty,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black,
                      fontSize: 16,
                      height: 1.2,
                    ),
              ),
              StreamBuilder(
                stream: ref
                    .watch(firestoreServiceProvider)
                    .watchTeacherRatings(teacher.id),
                builder: (context, snapshot) {
                  final docs = snapshot.data ?? const [];
                  final ratings = docs
                      .map((doc) => (doc.data()['rating'] as num?)?.toDouble())
                      .whereType<double>()
                      .toList();
                  final avg = ratings.isEmpty
                      ? 0.0
                      : ratings.reduce((a, b) => a + b) / ratings.length;
                  return Text(
                    ratings.isEmpty
                        ? 'Sin calificaciones'
                        : '${avg.toStringAsFixed(1)} (${ratings.length})',
                    style: Theme.of(context).textTheme.labelMedium,
                  );
                },
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Mensaje',
          onPressed: onMessage,
          icon: const Icon(
            Icons.chat_bubble,
            color: Color(0xFF4C8290),
            size: 34,
          ),
        ),
        if (canRate)
          IconButton(
            tooltip: 'Calificar docente',
            onPressed: onRate,
            icon: const Icon(
              Icons.star_rate,
              color: Color(0xFFFFCA55),
              size: 32,
            ),
          ),
      ],
    );
  }
}

class _Teacher {
  const _Teacher({
    required this.id,
    required this.name,
    required this.area,
    required this.specialty,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String area;
  final String specialty;
  final String imageUrl;
}
