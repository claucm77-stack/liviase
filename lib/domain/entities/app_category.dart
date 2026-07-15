import 'package:equatable/equatable.dart';

class AppCategoryScope {
  static const contenidos = 'contenidos';
  static const micronegocios = 'micronegocios';

  static const all = [contenidos, micronegocios];

  static String label(String scope) {
    switch (scope) {
      case contenidos:
        return 'Contenidos, cronograma y eventos';
      case micronegocios:
        return 'Micronegocios';
      default:
        return 'General';
    }
  }
}

class AppCategory extends Equatable {
  const AppCategory({
    required this.id,
    required this.nombre,
    required this.scope,
    this.descripcion = '',
    this.imageUrl = '',
    this.orden = 0,
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String nombre;
  final String scope;
  final String descripcion;
  final String imageUrl;
  final int orden;
  final bool isActive;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
        id,
        nombre,
        scope,
        descripcion,
        imageUrl,
        orden,
        isActive,
        createdAt,
      ];
}
