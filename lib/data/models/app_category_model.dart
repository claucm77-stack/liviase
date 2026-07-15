import '../../domain/entities/app_category.dart';

class AppCategoryModel extends AppCategory {
  const AppCategoryModel({
    required super.id,
    required super.nombre,
    required super.scope,
    super.descripcion,
    super.imageUrl,
    super.orden,
    super.isActive,
    super.createdAt,
  });

  factory AppCategoryModel.fromMap(String id, Map<String, dynamic> map) {
    return AppCategoryModel(
      id: id,
      nombre: (map['nombre'] ?? '').toString(),
      scope: (map['scope'] ?? AppCategoryScope.contenidos).toString(),
      descripcion: (map['descripcion'] ?? '').toString(),
      imageUrl: (map['imageUrl'] ?? '').toString(),
      orden: int.tryParse((map['orden'] ?? 0).toString()) ?? 0,
      isActive: (map['isActive'] ?? true) == true,
      createdAt: _parseDate(map['createdAt']),
    );
  }

  factory AppCategoryModel.fromEntity(AppCategory category) {
    return AppCategoryModel(
      id: category.id,
      nombre: category.nombre,
      scope: category.scope,
      descripcion: category.descripcion,
      imageUrl: category.imageUrl,
      orden: category.orden,
      isActive: category.isActive,
      createdAt: category.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'scope': scope,
      'descripcion': descripcion,
      'imageUrl': imageUrl,
      'orden': orden,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
