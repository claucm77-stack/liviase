import '../entities/business_entity.dart';

abstract class BusinessEntityRepository {
  Stream<List<BusinessEntity>> watchEntities();

  Future<void> saveEntity(BusinessEntity entity);

  Future<void> deleteEntity(String entityId);
}
