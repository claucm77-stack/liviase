import '../entities/app_category.dart';

abstract class CategoryRepository {
  Stream<List<AppCategory>> watchCategories({
    required String scope,
    bool onlyActive = false,
  });

  Future<void> saveCategory(AppCategory category);

  Future<void> deleteCategory(String categoryId);
}
