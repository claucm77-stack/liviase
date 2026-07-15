import '../entities/content.dart';

abstract class ContentRepository {
  Future<void> createContent({
    required Content content,
    required String currentUserId,
    required String currentUserRole,
  });

  Future<void> updateContent({
    required Content content,
    required String currentUserId,
    required String currentUserRole,
  });

  Future<void> deleteContent({
    required String contentId,
    required String currentUserId,
    required String currentUserRole,
  });

  Future<Content?> getContentById(String contentId);

  Stream<List<Content>> watchContents({
    required String currentUserRole,
    String? categoria,
    int limit = 10,
  });

  Future<List<Content>> fetchContentsPage({
    required String currentUserRole,
    String? categoria,
    required int limit,
    DateTime? startAfterDate,
  });

  Future<void> toggleFavorite({
    required String contentId,
    required String userId,
  });

  Future<void> markAsViewed({
    required String contentId,
    required String userId,
  });
}
