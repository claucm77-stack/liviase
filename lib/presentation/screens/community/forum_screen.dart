import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_roles.dart';
import '../../../core/di/providers.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/app_scaffold.dart';

class ForumScreen extends ConsumerStatefulWidget {
  const ForumScreen({super.key});

  @override
  ConsumerState<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends ConsumerState<ForumScreen> {
  Future<void> _showQuestionDialog() async {
    final titleCtrl = TextEditingController();
    final categoryCtrl = TextEditingController(text: 'General');

    final result = await showDialog<(String, String)>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Pregunta o tema',
                prefixIcon: Icon(Icons.help_outline),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: categoryCtrl,
              decoration: const InputDecoration(
                labelText: 'Tema',
                prefixIcon: Icon(Icons.category_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              Navigator.pop(
                context,
                (titleCtrl.text.trim(), categoryCtrl.text.trim()),
              );
            },
            icon: const Icon(Icons.send_outlined),
            label: const Text('Publicar'),
          ),
        ],
      ),
    );

    titleCtrl.dispose();
    categoryCtrl.dispose();

    final user = ref.read(authViewModelProvider).user;
    if (result == null || user == null) return;

    await ref.read(firestoreServiceProvider).createForumTopic(
          title: result.$1,
          category: result.$2.isEmpty ? 'General' : result.$2,
          authorId: user.uid,
          authorName: user.name.trim().isEmpty ? user.email : user.name.trim(),
          authorRole: AppRoles.normalize(user.role),
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tema publicado en el foro.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authViewModelProvider).user;
    final canAnswer = AppRoles.canModerateForums(user?.role);
    final canCreate = AppRoles.canUseForums(user?.role);

    return AppScaffold(
      title: 'Foros temáticos',
      showBack: true,
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: _showQuestionDialog,
              icon: const Icon(Icons.add_comment_outlined),
              label: const Text('Abrir tema'),
            )
          : null,
      child: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        stream: ref.watch(firestoreServiceProvider).watchForumTopics(),
        builder: (context, snapshot) {
          final docs = snapshot.data ?? const [];

          return ListView.separated(
            itemCount: docs.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index == 0) {
                return SectionHeader(
                  title: canAnswer
                      ? 'Consultas por resolver'
                      : 'Consulta a docentes expertos',
                  subtitle: canAnswer
                      ? 'Responde preguntas y orienta a los empresarios.'
                      : 'Abre un tema y revisa respuestas de docentes.',
                  icon: Icons.forum_outlined,
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (docs.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text('Aún no hay temas publicados.'),
                  ),
                );
              }

              final doc = docs[index - 1];
              final data = doc.data();
              return _ForumTopicCard(
                topicId: doc.id,
                data: data,
                canAnswer: canAnswer,
                onReply: () => _showReplyDialog(doc.id),
                onContactTeacher: () => _contactTeacher(data),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showReplyDialog(String topicId) async {
    final user = ref.read(authViewModelProvider).user;
    if (user == null) return;
    final ctrl = TextEditingController();

    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Responder como docente'),
        content: TextField(
          controller: ctrl,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Respuesta',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Responder'),
          ),
        ],
      ),
    );

    ctrl.dispose();
    if (text == null || text.isEmpty) return;

    await ref.read(firestoreServiceProvider).replyForumTopic(
          topicId: topicId,
          text: text,
          teacherId: user.uid,
          teacherName: user.name.trim().isEmpty ? user.email : user.name.trim(),
        );
  }

  void _contactTeacher(Map<String, dynamic> data) {
    final teacherId = (data['teacherId'] ?? '').toString();
    final teacherName = (data['teacherName'] ?? '').toString();
    if (teacherId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Este tema aún no tiene docente asignado.')),
      );
      return;
    }
    context.push(
      Uri(
        path: '/docentes/chat',
        queryParameters: {
          'id': teacherId,
          'name': teacherName,
          'area': 'Docente asesor',
          'image': '',
        },
      ).toString(),
    );
  }
}

class _ForumTopicCard extends ConsumerWidget {
  const _ForumTopicCard({
    required this.topicId,
    required this.data,
    required this.canAnswer,
    required this.onReply,
    required this.onContactTeacher,
  });

  final String topicId;
  final Map<String, dynamic> data;
  final bool canAnswer;
  final VoidCallback onReply;
  final VoidCallback onContactTeacher;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = (data['title'] ?? '').toString();
    final category = (data['category'] ?? 'General').toString();
    final status = (data['status'] ?? 'Pendiente').toString();
    final authorName = (data['authorName'] ?? 'Usuario').toString();

    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.forum_outlined),
        title: Text(title),
        subtitle: Text('$category • $status • $authorName'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        children: [
          StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
            stream:
                ref.watch(firestoreServiceProvider).watchForumReplies(topicId),
            builder: (context, snapshot) {
              final replies = snapshot.data ?? const [];
              if (replies.isEmpty) {
                return const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text('Sin respuestas todavía.'),
                  ),
                );
              }
              return Column(
                children: replies.map((reply) {
                  final item = reply.data();
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.school_outlined),
                    title: Text((item['teacherName'] ?? 'Docente').toString()),
                    subtitle: Text((item['text'] ?? '').toString()),
                  );
                }).toList(),
              );
            },
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (canAnswer) ...[
                  FilledButton.icon(
                    onPressed: onReply,
                    icon: const Icon(Icons.rate_review_outlined),
                    label: const Text('Responder'),
                  ),
                  const SizedBox(height: 8),
                ],
                OutlinedButton.icon(
                  onPressed: onContactTeacher,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Contactar docente'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
