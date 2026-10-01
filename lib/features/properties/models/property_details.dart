class PropertyDetails {
  const PropertyDetails({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    required this.price,
    required this.address,
    required this.city,
    this.latitude,
    this.longitude,
    required this.category,
    required this.images,
    required this.amenities,
    required this.owner,
    required this.reviews,
    required this.rating,
    required this.favoritesCount,
    required this.bookingsCount,
    required this.createdAt,
    required this.updatedAt,
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
  final PropertyDetailsCategory category;
  final List<PropertyImage> images;
  final List<PropertyAmenity> amenities;
  final PropertyOwner owner;
  final List<PropertyReview> reviews;
  final PropertyRating rating;
  final int favoritesCount;
  final int bookingsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory PropertyDetails.fromJson(Map<String, dynamic> json) {
    return PropertyDetails(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      category: PropertyDetailsCategory.fromJson(
        Map<String, dynamic>.from(json['category'] as Map),
      ),
      images: (json['images'] as List? ?? [])
          .map(
            (item) => PropertyImage.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      amenities: (json['amenities'] as List? ?? [])
          .map(
            (item) => PropertyAmenity.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      owner: PropertyOwner.fromJson(
        Map<String, dynamic>.from(json['owner'] as Map),
      ),
      reviews: (json['reviews'] as List? ?? [])
          .map(
            (item) => PropertyReview.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      rating: PropertyRating.fromJson(
        Map<String, dynamic>.from(json['rating'] as Map),
      ),
      favoritesCount: json['favoritesCount'] as int? ?? 0,
      bookingsCount: json['bookingsCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class PropertyDetailsCategory {
  const PropertyDetailsCategory({
    required this.id,
    required this.name,
    required this.slug,
  });

  final String id;
  final String name;
  final String slug;

  factory PropertyDetailsCategory.fromJson(
    Map<String, dynamic> json,
  ) {
    return PropertyDetailsCategory(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}

class PropertyImage {
  const PropertyImage({
    required this.id,
    required this.url,
    this.alt,
    required this.sortOrder,
  });

  final String id;
  final String url;
  final String? alt;
  final int sortOrder;

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(
      id: json['id'] as String,
      url: json['url'] as String? ?? '',
      alt: json['alt'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }
}

class PropertyAmenity {
  const PropertyAmenity({
    required this.id,
    required this.name,
    this.description,
  });

  final String id;
  final String name;
  final String? description;

  factory PropertyAmenity.fromJson(
    Map<String, dynamic> json,
  ) {
    return PropertyAmenity(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
    );
  }
}

class PropertyOwner {
  const PropertyOwner({
    required this.id,
    this.name,
    this.image,
  });

  final String id;
  final String? name;
  final String? image;

  factory PropertyOwner.fromJson(Map<String, dynamic> json) {
    return PropertyOwner(
      id: json['id'] as String,
      name: json['name'] as String?,
      image: json['image'] as String?,
    );
  }
}

class PropertyReview {
  const PropertyReview({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.user,
  });

  final String id;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final PropertyOwner user;

  factory PropertyReview.fromJson(Map<String, dynamic> json) {
    return PropertyReview(
      id: json['id'] as String,
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      user: PropertyOwner.fromJson(
        Map<String, dynamic>.from(json['user'] as Map),
      ),
    );
  }
}

class PropertyRating {
  const PropertyRating({
    required this.average,
    required this.count,
  });

  final double average;
  final int count;

  factory PropertyRating.fromJson(Map<String, dynamic> json) {
    return PropertyRating(
      average: (json['average'] as num?)?.toDouble() ?? 0,
      count: json['count'] as int? ?? 0,
    );
  }
}