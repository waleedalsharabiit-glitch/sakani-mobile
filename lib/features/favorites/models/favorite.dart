class Favorite {
  const Favorite({
    required this.id,
    required this.createdAt,
    required this.property,
  });

  final String id;
  final DateTime createdAt;
  final FavoriteProperty property;

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      property: FavoriteProperty.fromJson(
        Map<String, dynamic>.from(json['property'] as Map),
      ),
    );
  }
}

class FavoriteProperty {
  const FavoriteProperty({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.price,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.image,
  });

  final String id;
  final String title;
  final String slug;
  final String? description;
  final double price;
  final String address;
  final String city;
  final double? latitude;
  final double? longitude;
  final FavoriteCategory? category;
  final String? image;

  factory FavoriteProperty.fromJson(Map<String, dynamic> json) {
    return FavoriteProperty(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      category: json['category'] != null
          ? FavoriteCategory.fromJson(
              Map<String, dynamic>.from(
                json['category'] as Map,
              ),
            )
          : null,
      image: json['image'] as String?,
    );
  }
}

class FavoriteCategory {
  const FavoriteCategory({
    required this.id,
    required this.name,
    required this.slug,
  });

  final String id;
  final String name;
  final String slug;

  factory FavoriteCategory.fromJson(Map<String, dynamic> json) {
    return FavoriteCategory(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}