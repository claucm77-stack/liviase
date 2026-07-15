import '../../domain/entities/business_entity.dart';

class BusinessEntityModel extends BusinessEntity {
  const BusinessEntityModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.mainUrl,
    required super.createdAt,
    super.resources,
  });

  factory BusinessEntityModel.fromEntity(BusinessEntity entity) {
    return BusinessEntityModel(
      id: entity.id,
      name: entity.name,
      imageUrl: entity.imageUrl,
      mainUrl: entity.mainUrl,
      createdAt: entity.createdAt,
      resources: entity.resources,
    );
  }

  factory BusinessEntityModel.fromMap(String id, Map<String, dynamic> map) {
    return BusinessEntityModel(
      id: id,
      name: (map['name'] ?? '').toString(),
      imageUrl: (map['imageUrl'] ?? '').toString(),
      mainUrl: (map['mainUrl'] ?? '').toString(),
      createdAt: DateTime.tryParse((map['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      resources: ((map['resources'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) => EntityResource(
                name: (item['name'] ?? '').toString(),
                url: (item['url'] ?? '').toString(),
                type: _resourceTypeFromString((item['type'] ?? '').toString()),
              ))
          .where((item) => item.name.isNotEmpty && item.url.isNotEmpty)
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'mainUrl': mainUrl,
      'createdAt': createdAt.toIso8601String(),
      'resources': resources
          .map(
            (item) => {
              'name': item.name,
              'url': item.url,
              'type': item.type.name,
            },
          )
          .toList(),
    };
  }

  static EntityResourceType _resourceTypeFromString(String value) {
    return value == EntityResourceType.pdf.name
        ? EntityResourceType.pdf
        : EntityResourceType.link;
  }
}
