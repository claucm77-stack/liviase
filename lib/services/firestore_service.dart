import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_roles.dart';
import '../data/models/app_user_model.dart';
import '../data/models/dashboard_metrics_model.dart';
import '../data/models/log_model.dart';
import '../data/models/teacher_chat_message_model.dart';

class FirestoreService {
  FirestoreService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _contenidos =>
      _firestore.collection('contenidos');

  CollectionReference<Map<String, dynamic>> get _micronegocios =>
      _firestore.collection('micronegocios');

  CollectionReference<Map<String, dynamic>> get _logs =>
      _firestore.collection('logs');

  CollectionReference<Map<String, dynamic>> get _teacherChats =>
      _firestore.collection('teacher_chats');

  CollectionReference<Map<String, dynamic>> get _businessEntities =>
      _firestore.collection('entidades');

  CollectionReference<Map<String, dynamic>> get _categories =>
      _firestore.collection('categorias');

  CollectionReference<Map<String, dynamic>> get _forumTopics =>
      _firestore.collection('forum_topics');

  CollectionReference<Map<String, dynamic>> get _teacherRatings =>
      _firestore.collection('teacher_ratings');

  CollectionReference<Map<String, dynamic>> get _eventRatings =>
      _firestore.collection('event_ratings');

  Future<void> setUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _users.doc(uid).set(data, SetOptions(merge: true));
  }

  Future<void> updateUserFields({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _users.doc(uid).set(data, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    return doc.data();
  }

  Stream<Map<String, dynamic>?> userProfileStream(String uid) {
    return _users.doc(uid).snapshots().map((doc) => doc.data());
  }

  Future<void> setContent({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    await _contenidos.doc(id).set(data, SetOptions(merge: true));
  }

  Future<void> deleteContent(String id) async {
    await _contenidos.doc(id).delete();
  }

  Future<void> updateContentFields({
    required String contentId,
    required Map<String, dynamic> data,
  }) async {
    await _contenidos.doc(contentId).update(data);
  }

  Future<Map<String, dynamic>?> getContentById(String id) async {
    final doc = await _contenidos.doc(id).get();
    return doc.data();
  }

  Query<Map<String, dynamic>> _buildContentsQuery({
    required bool onlyActive,
    String? categoria,
    int? limit,
    DateTime? startAfterDate,
  }) {
    Query<Map<String, dynamic>> query = _contenidos.orderBy(
      'fechaCreacion',
      descending: true,
    );

    if (onlyActive) {
      query = query.where('estado', isEqualTo: 'activo');
    }

    if (categoria != null && categoria.isNotEmpty) {
      query = query.where('categoria', isEqualTo: categoria);
    }

    if (startAfterDate != null) {
      query = query.startAfter([startAfterDate.toIso8601String()]);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query;
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> watchContents({
    required bool onlyActive,
    String? categoria,
    int limit = 10,
  }) {
    final primaryQuery = _buildContentsQuery(
      onlyActive: onlyActive,
      categoria: categoria,
      limit: limit,
    );

    return Stream.multi((controller) {
      StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? sub;
      var switchedToFallback = false;

      void subscribeTo(Query<Map<String, dynamic>> query) {
        sub = query.snapshots().listen(
          (snapshot) {
            controller.add(snapshot.docs);
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!switchedToFallback &&
                !onlyActive &&
                error is FirebaseException &&
                error.code == 'permission-denied') {
              switchedToFallback = true;
              sub?.cancel();
              final fallbackQuery = _buildContentsQuery(
                onlyActive: true,
                categoria: categoria,
                limit: limit,
              );
              subscribeTo(fallbackQuery);
              return;
            }

            controller.addError(error, stackTrace);
          },
        );
      }

      subscribeTo(primaryQuery);

      controller.onCancel = () async {
        await sub?.cancel();
      };
    });
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchContentsPage({
    required bool onlyActive,
    String? categoria,
    required int limit,
    DateTime? startAfterDate,
  }) async {
    Query<Map<String, dynamic>> query = _buildContentsQuery(
      onlyActive: onlyActive,
      categoria: categoria,
      limit: limit,
      startAfterDate: startAfterDate,
    );

    try {
      final snapshot = await query.get();
      return snapshot.docs;
    } on FirebaseException catch (e) {
      if (!onlyActive && e.code == 'permission-denied') {
        query = _buildContentsQuery(
          onlyActive: true,
          categoria: categoria,
          limit: limit,
          startAfterDate: startAfterDate,
        );
        final fallbackSnapshot = await query.get();
        return fallbackSnapshot.docs;
      }
      rethrow;
    }
  }

  Future<void> addUserToArrayField({
    required String contentId,
    required String field,
    required String userId,
  }) async {
    await _contenidos.doc(contentId).update({
      field: FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> removeUserFromArrayField({
    required String contentId,
    required String field,
    required String userId,
  }) async {
    await _contenidos.doc(contentId).update({
      field: FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> setMicrobusiness({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    await _micronegocios.doc(id).set(data, SetOptions(merge: true));
  }

  Future<void> setBusinessEntity({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    await _businessEntities.doc(id).set(data, SetOptions(merge: true));
  }

  Future<void> deleteBusinessEntity(String id) async {
    await _businessEntities.doc(id).delete();
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      watchBusinessEntities() {
    return _businessEntities
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Future<void> setCategory({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    await _categories.doc(id).set(data, SetOptions(merge: true));
  }

  Future<void> deleteCategory(String id) async {
    await _categories.doc(id).delete();
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> watchCategories({
    required String scope,
    bool onlyActive = false,
  }) {
    Query<Map<String, dynamic>> query = _categories.where(
      'scope',
      isEqualTo: scope,
    );

    if (onlyActive) {
      query = query.where('isActive', isEqualTo: true);
    }

    return query.snapshots().map((snapshot) {
      final docs = [...snapshot.docs];
      docs.sort((a, b) {
        final aData = a.data();
        final bData = b.data();
        final orderCompare = ((aData['orden'] ?? 0) as num)
            .compareTo((bData['orden'] ?? 0) as num);
        if (orderCompare != 0) return orderCompare;
        return (aData['nombre'] ?? '')
            .toString()
            .compareTo((bData['nombre'] ?? '').toString());
      });
      return docs;
    });
  }

  Future<void> deleteMicrobusiness(String id) async {
    await _micronegocios.doc(id).delete();
  }

  Future<Map<String, dynamic>?> getMicrobusinessById(String id) async {
    final doc = await _micronegocios.doc(id).get();
    return doc.data();
  }

  Query<Map<String, dynamic>> _buildMicrobusinessQuery({
    required bool onlyActive,
    String? categoria,
  }) {
    Query<Map<String, dynamic>> query = _micronegocios;

    if (onlyActive) {
      query = query.where('estado', isEqualTo: 'activo');
    }

    if (categoria != null && categoria.isNotEmpty) {
      query = query.where('categoria', isEqualTo: categoria);
    }

    query = query.orderBy(
      'fechaCreacion',
      descending: true,
    );

    return query;
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      watchMicrobusinesses({
    required bool onlyActive,
    String? categoria,
  }) {
    final primaryQuery = _buildMicrobusinessQuery(
      onlyActive: onlyActive,
      categoria: categoria,
    );

    return Stream.multi((controller) {
      StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? sub;
      var switchedToFallback = false;

      void subscribeTo(Query<Map<String, dynamic>> query) {
        sub = query.snapshots().listen(
          (snapshot) => controller.add(snapshot.docs),
          onError: (Object error, StackTrace stackTrace) {
            if (!switchedToFallback && error is FirebaseException) {
              switchedToFallback = true;
              sub?.cancel();

              Query<Map<String, dynamic>> fallback = _micronegocios.limit(50);

              subscribeTo(fallback);
              return;
            }

            controller.addError(error, stackTrace);
          },
        );
      }

      subscribeTo(primaryQuery);

      controller.onCancel = () async {
        await sub?.cancel();
      };
    });
  }

  Future<void> addUserToMicrobusinessArrayField({
    required String businessId,
    required String field,
    required String userId,
  }) async {
    await _micronegocios.doc(businessId).update({
      field: FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> removeUserFromMicrobusinessArrayField({
    required String businessId,
    required String field,
    required String userId,
  }) async {
    await _micronegocios.doc(businessId).update({
      field: FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> updateMicrobusinessFields({
    required String businessId,
    required Map<String, dynamic> data,
  }) async {
    await _micronegocios.doc(businessId).update(data);
  }

  Stream<DashboardMetricsModel> watchDashboardMetrics() {
    final users = _users.snapshots();
    final contenidos = _contenidos.snapshots();
    final micronegocios = _micronegocios.snapshots();

    return Stream.multi((controller) {
      int totalUsers = 0;
      int totalContents = 0;
      int totalMicronegocios = 0;
      int activeContents = 0;
      int activeMicronegocios = 0;

      StreamSubscription? usersSub;
      StreamSubscription? contentsSub;
      StreamSubscription? microSub;

      void emit() {
        controller.add(
          DashboardMetricsModel(
            totalUsers: totalUsers,
            totalContents: totalContents,
            totalMicrobusinesses: totalMicronegocios,
            activeContents: activeContents,
            inactiveContents: totalContents - activeContents,
            activeMicrobusinesses: activeMicronegocios,
            inactiveMicrobusinesses: totalMicronegocios - activeMicronegocios,
          ),
        );
      }

      usersSub = users.listen((snapshot) {
        totalUsers = snapshot.docs.length;
        emit();
      }, onError: controller.addError);

      contentsSub = contenidos.listen((snapshot) {
        totalContents = snapshot.docs.length;
        activeContents = snapshot.docs
            .where((d) => (d.data()['estado'] ?? '').toString() == 'activo')
            .length;
        emit();
      }, onError: controller.addError);

      microSub = micronegocios.listen((snapshot) {
        totalMicronegocios = snapshot.docs.length;
        activeMicronegocios = snapshot.docs
            .where((d) => (d.data()['estado'] ?? '').toString() == 'activo')
            .length;
        emit();
      }, onError: controller.addError);

      controller.onCancel = () async {
        await usersSub?.cancel();
        await contentsSub?.cancel();
        await microSub?.cancel();
      };
    });
  }

  Stream<List<AppUserModel>> watchUsers({
    String? role,
    bool? isActive,
  }) {
    Query<Map<String, dynamic>> query = _users;
    if (role != null && role.isNotEmpty) {
      query = query.where('rol', isEqualTo: role);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final map = doc.data();
            final normalized = <String, dynamic>{
              ...map,
              'uid': doc.id,
              'rol': AppRoles.normalize(
                (map['rol'] ?? map['role'])?.toString(),
              ),
            };

            if (isActive != null) {
              final active = (map['isActive'] ?? true) == true;
              if (active != isActive) {
                return null;
              }
            }

            return AppUserModel.fromMap(normalized);
          })
          .whereType<AppUserModel>()
          .toList();
    });
  }

  Future<void> addLog({
    required String usuarioId,
    required String accion,
    required String modulo,
    String origen = 'mobile',
    String detalle = '',
  }) async {
    final log = LogModel(
      id: '',
      usuarioId: usuarioId,
      accion: accion,
      modulo: modulo,
      fecha: DateTime.now(),
      origen: origen,
      detalle: detalle,
    );
    await _logs.add(log.toMap());
  }

  Stream<List<LogModel>> watchLogs({
    String? modulo,
    int limit = 100,
  }) {
    Query<Map<String, dynamic>> query = _logs;

    if (modulo != null && modulo.isNotEmpty) {
      query = query.where('modulo', isEqualTo: modulo);
    }

    query = query.orderBy('fecha', descending: true).limit(limit);

    return Stream.multi((controller) {
      StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? sub;
      var switchedToFallback = false;

      void subscribeTo(Query<Map<String, dynamic>> q) {
        sub = q.snapshots().listen(
          (snapshot) {
            controller.add(
              snapshot.docs
                  .map((doc) => LogModel.fromFirestore(doc.id, doc.data()))
                  .toList(),
            );
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!switchedToFallback &&
                modulo != null &&
                modulo.isNotEmpty &&
                error is FirebaseException &&
                error.code == 'failed-precondition') {
              switchedToFallback = true;
              sub?.cancel();

              final fallbackQuery =
                  _logs.orderBy('fecha', descending: true).limit(limit);
              subscribeTo(fallbackQuery);
              return;
            }

            controller.addError(error, stackTrace);
          },
        );
      }

      subscribeTo(query);

      controller.onCancel = () async {
        await sub?.cancel();
      };
    });
  }

  Stream<List<TeacherChatMessageModel>> watchTeacherMessages({
    required String userId,
    required String teacherId,
  }) {
    return _teacherChats
        .doc(_teacherConversationId(userId: userId, teacherId: teacherId))
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) =>
                  TeacherChatMessageModel.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> ensureTeacherConversation({
    required String userId,
    required String userName,
    required String teacherId,
    required String teacherName,
    required String teacherArea,
  }) async {
    final conversationId = _teacherConversationId(
      userId: userId,
      teacherId: teacherId,
    );
    await _teacherChats.doc(conversationId).set({
      'userId': userId,
      'userName': userName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'teacherArea': teacherArea,
      'lastMessage': '',
      'updatedAt': Timestamp.now(),
      'participants': [userId, teacherId],
    }, SetOptions(merge: true));
  }

  Future<void> sendTeacherMessage({
    required String userId,
    required String userName,
    required String teacherId,
    required String teacherName,
    required String teacherArea,
    required String text,
  }) async {
    final conversationId = _teacherConversationId(
      userId: userId,
      teacherId: teacherId,
    );
    final conversationRef = _teacherChats.doc(conversationId);
    final now = Timestamp.now();

    await conversationRef.set({
      'userId': userId,
      'userName': userName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'teacherArea': teacherArea,
      'lastMessage': text,
      'updatedAt': now,
      'participants': [userId, teacherId],
    }, SetOptions(merge: true));

    await conversationRef.collection('messages').add({
      'senderId': userId,
      'senderName': userName,
      'text': text,
      'sentAt': now,
      'isTeacher': false,
    });
  }

  String _teacherConversationId({
    required String userId,
    required String teacherId,
  }) {
    return '${userId}_$teacherId'.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> watchForumTopics() {
    return _forumTopics
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> watchForumReplies(
    String topicId,
  ) {
    return _forumTopics
        .doc(topicId)
        .collection('replies')
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Future<void> createForumTopic({
    required String title,
    required String category,
    required String authorId,
    required String authorName,
    required String authorRole,
  }) async {
    await _forumTopics.add({
      'title': title,
      'category': category,
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'status': 'Pendiente de respuesta',
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'teacherId': '',
      'teacherName': '',
    });
  }

  Future<void> replyForumTopic({
    required String topicId,
    required String text,
    required String teacherId,
    required String teacherName,
  }) async {
    final topicRef = _forumTopics.doc(topicId);
    await topicRef.collection('replies').add({
      'text': text,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'createdAt': Timestamp.now(),
    });
    await topicRef.set({
      'status': 'Respondido por docente',
      'teacherId': teacherId,
      'teacherName': teacherName,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Future<void> rateTeacher({
    required String teacherId,
    required String userId,
    required double rating,
  }) async {
    await _teacherRatings.doc('${teacherId}_$userId').set({
      'teacherId': teacherId,
      'userId': userId,
      'rating': rating,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> watchTeacherRatings(
    String teacherId,
  ) {
    return _teacherRatings
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Future<void> rateEvent({
    required String eventId,
    required String userId,
    required double rating,
  }) async {
    await _eventRatings.doc('${eventId}_$userId').set({
      'eventId': eventId,
      'userId': userId,
      'rating': rating,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> watchEventRatings(
    String eventId,
  ) {
    return _eventRatings
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }
}
