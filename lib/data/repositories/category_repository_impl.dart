import '../../domain/entities/app_category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../services/firestore_service.dart';
import '../models/app_category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Stream<List<AppCategory>> watchCategories({
    required String scope,
    bool onlyActive = false,
  }) {
    return _firestoreService
        .watchCategories(scope: scope, onlyActive: onlyActive)
        .map((docs) => docs
            .map((doc) => AppCategoryModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<void> saveCategory(AppCategory category) {
    final model = AppCategoryModel.fromEntity(category);
    return _firestoreService.setCategory(
      id: category.id,
      data: model.toMap(),
    );
  }

  @override
  Future<void> deleteCategory(String categoryId) {
    return _firestoreService.deleteCategory(categoryId);
  }
}
