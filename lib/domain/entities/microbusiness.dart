import 'package:equatable/equatable.dart';

enum MicrobusinessStatus { activo, inactivo }

class Microbusiness extends Equatable {
  final String id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final String direccion;
  final double latitud;
  final double longitud;
  final String mapsUrl;
  final String imagen;
  final String propietarioId;
  final String contacto;
  final String horario;
  final MicrobusinessStatus estado;
  final DateTime fechaCreacion;
  final List<String> favoritos;
  final double? ratingPromedio;
  final int? totalCalificaciones;
  final Map<String, String> campos;

  const Microbusiness({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    this.mapsUrl = '',
    required this.imagen,
    required this.propietarioId,
    required this.contacto,
    required this.horario,
    required this.estado,
    required this.fechaCreacion,
    this.favoritos = const [],
    this.ratingPromedio,
    this.totalCalificaciones,
    this.campos = const {},
  });

  bool get isActivo => estado == MicrobusinessStatus.activo;

  bool isFavoriteFor(String userId) => favoritos.contains(userId);

  Microbusiness copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? categoria,
    String? direccion,
    double? latitud,
    double? longitud,
    String? mapsUrl,
    String? imagen,
    String? propietarioId,
    String? contacto,
    String? horario,
    MicrobusinessStatus? estado,
    DateTime? fechaCreacion,
    List<String>? favoritos,
    double? ratingPromedio,
    int? totalCalificaciones,
    Map<String, String>? campos,
  }) {
    return Microbusiness(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      direccion: direccion ?? this.direccion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      mapsUrl: mapsUrl ?? this.mapsUrl,
      imagen: imagen ?? this.imagen,
      propietarioId: propietarioId ?? this.propietarioId,
      contacto: contacto ?? this.contacto,
      horario: horario ?? this.horario,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      favoritos: favoritos ?? this.favoritos,
      ratingPromedio: ratingPromedio ?? this.ratingPromedio,
      totalCalificaciones: totalCalificaciones ?? this.totalCalificaciones,
      campos: campos ?? this.campos,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nombre,
        descripcion,
        categoria,
        direccion,
        latitud,
        longitud,
        mapsUrl,
        imagen,
        propietarioId,
        contacto,
        horario,
        estado,
        fechaCreacion,
        favoritos,
        ratingPromedio,
        totalCalificaciones,
        campos,
      ];
}
