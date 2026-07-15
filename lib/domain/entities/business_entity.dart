import 'package:equatable/equatable.dart';

enum EntityResourceType { link, pdf }

class EntityResource extends Equatable {
  const EntityResource({
    required this.name,
    required this.url,
    required this.type,
  });

  final String name;
  final String url;
  final EntityResourceType type;

  EntityResource copyWith({
    String? name,
    String? url,
    EntityResourceType? type,
  }) {
    return EntityResource(
      name: name ?? this.name,
      url: url ?? this.url,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [name, url, type];
}

class BusinessEntity extends Equatable {
  const BusinessEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.mainUrl,
    required this.createdAt,
    this.resources = const [],
  });

  final String id;
  final String name;
  final String imageUrl;
  final String mainUrl;
  final DateTime createdAt;
  final List<EntityResource> resources;

  BusinessEntity copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? mainUrl,
    DateTime? createdAt,
    List<EntityResource>? resources,
  }) {
    return BusinessEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      mainUrl: mainUrl ?? this.mainUrl,
      createdAt: createdAt ?? this.createdAt,
      resources: resources ?? this.resources,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, imageUrl, mainUrl, createdAt, resources];
}
