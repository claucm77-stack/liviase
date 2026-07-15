import '../../data/models/app_user_model.dart';
import '../../data/models/dashboard_metrics_model.dart';
import '../../data/models/content_model.dart';
import '../../data/models/microbusiness_model.dart';
import '../../domain/entities/content.dart';
import '../../domain/entities/microbusiness.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../services/firestore_service.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Stream<DashboardMetricsModel> watchMetrics() {
    return _firestoreService.watchDashboardMetrics();
  }

  @override
  Stream<List<AppUserModel>> watchUsers({
    String? role,
    bool? isActive,
  }) {
    return _firestoreService.watchUsers(
      role: role,
      isActive: isActive,
    );
  }

  @override
  Stream<List<Content>> watchContents({String? categoria}) {
    return _firestoreService
        .watchContents(onlyActive: false, categoria: categoria, limit: 100)
        .map((docs) => docs
            .map((doc) => ContentModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  @override
  Stream<List<Microbusiness>> watchMicrobusinesses({String? categoria}) {
    return _firestoreService
        .watchMicrobusinesses(onlyActive: false, categoria: categoria)
        .map((docs) => docs
            .map((doc) => MicrobusinessModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<void> updateUser({
    required String uid,
    required String role,
    required bool isActive,
  }) {
    return _firestoreService.updateUserFields(
      uid: uid,
      data: {
        'rol': role,
        'role': role,
        'isActive': isActive,
      },
    );
  }

  @override
  Future<void> updateContentStatus({
    required String contentId,
    required bool isActive,
  }) {
    return _firestoreService.updateContentFields(
      contentId: contentId,
      data: {'estado': isActive ? 'activo' : 'inactivo'},
    );
  }

  @override
  Future<void> deleteContent(String contentId) {
    return _firestoreService.deleteContent(contentId);
  }

  @override
  Future<void> updateMicrobusinessStatus({
    required String businessId,
    required bool isActive,
  }) {
    return _firestoreService.updateMicrobusinessFields(
      businessId: businessId,
      data: {'estado': isActive ? 'activo' : 'inactivo'},
    );
  }

  @override
  Future<void> deleteMicrobusiness(String businessId) {
    return _firestoreService.deleteMicrobusiness(businessId);
  }
}
