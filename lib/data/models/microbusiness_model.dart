import '../../domain/entities/microbusiness.dart';

class MicrobusinessModel extends Microbusiness {
  const MicrobusinessModel({
    required super.id,
    required super.nombre,
    required super.descripcion,
    required super.categoria,
    required super.direccion,
    required super.latitud,
    required super.longitud,
    super.mapsUrl,
    required super.imagen,
    required super.propietarioId,
    required super.contacto,
    required super.horario,
    required super.estado,
    required super.fechaCreacion,
    super.favoritos,
    super.ratingPromedio,
    super.totalCalificaciones,
    super.campos,
  });

  factory MicrobusinessModel.fromEntity(Microbusiness entity) {
    return MicrobusinessModel(
      id: entity.id,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      categoria: entity.categoria,
      direccion: entity.direccion,
      latitud: entity.latitud,
      longitud: entity.longitud,
      mapsUrl: entity.mapsUrl,
      imagen: entity.imagen,
      propietarioId: entity.propietarioId,
      contacto: entity.contacto,
      horario: entity.horario,
      estado: entity.estado,
      fechaCreacion: entity.fechaCreacion,
      favoritos: entity.favoritos,
      ratingPromedio: entity.ratingPromedio,
      totalCalificaciones: entity.totalCalificaciones,
      campos: entity.campos,
    );
  }

  factory MicrobusinessModel.fromMap(String id, Map<String, dynamic> map) {
    return MicrobusinessModel(
      id: id,
      nombre: (map['nombre'] ?? '') as String,
      descripcion: (map['descripcion'] ?? '') as String,
      categoria: (map['categoria'] ?? '') as String,
      direccion: (map['direccion'] ?? '') as String,
      latitud: _toDouble(map['latitud']),
      longitud: _toDouble(map['longitud']),
      mapsUrl: (map['mapsUrl'] ?? map['googleMapsUrl'] ?? '') as String,
      imagen: (map['imagen'] ?? '') as String,
      propietarioId: (map['propietarioId'] ?? '') as String,
      contacto: (map['contacto'] ?? '') as String,
      horario: (map['horario'] ?? '') as String,
      estado: _parseStatus((map['estado'] ?? 'activo') as String),
      fechaCreacion: _parseDate(map['fechaCreacion']),
      favoritos: _parseStringList(map['favoritos']),
      ratingPromedio: map['ratingPromedio'] == null
          ? null
          : _toDouble(map['ratingPromedio']),
      totalCalificaciones: (map['totalCalificaciones'] as num?)?.toInt(),
      campos: _parseStringMap(map['campos'] ?? map['customFields']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria': categoria,
      'direccion': direccion,
      'latitud': latitud,
      'longitud': longitud,
      'mapsUrl': mapsUrl,
      'imagen': imagen,
      'propietarioId': propietarioId,
      'contacto': contacto,
      'horario': horario,
      'estado': estado.name,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'favoritos': favoritos,
      'ratingPromedio': ratingPromedio,
      'totalCalificaciones': totalCalificaciones,
      'campos': campos,
    };
  }

  static MicrobusinessStatus _parseStatus(String raw) {
    switch (raw) {
      case 'inactivo':
        return MicrobusinessStatus.inactivo;
      case 'activo':
      default:
        return MicrobusinessStatus.activo;
    }
  }

  static DateTime _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static List<String> _parseStringList(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return [];
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  static Map<String, String> _parseStringMap(dynamic raw) {
    if (raw is Map) {
      return raw
          .map((key, value) => MapEntry(key.toString(), value.toString()));
    }
    return const {};
  }
}
