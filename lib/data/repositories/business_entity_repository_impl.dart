import '../../domain/entities/business_entity.dart';
import '../../domain/repositories/business_entity_repository.dart';
import '../../services/firestore_service.dart';
import '../models/business_entity_model.dart';

class BusinessEntityRepositoryImpl implements BusinessEntityRepository {
  BusinessEntityRepositoryImpl(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Stream<List<BusinessEntity>> watchEntities() {
    return _firestoreService.watchBusinessEntities().map(
          (docs) => docs
              .map((doc) => BusinessEntityModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Future<void> saveEntity(BusinessEntity entity) async {
    final model = BusinessEntityModel.fromEntity(entity);
    await _firestoreService.setBusinessEntity(
      id: model.id,
      data: model.toMap(),
    );
  }

  @override
  Future<void> deleteEntity(String entityId) {
    return _firestoreService.deleteBusinessEntity(entityId);
  }
}
