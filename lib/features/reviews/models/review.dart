class Review {
  const Review({
    required this.id,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.user,
  });

  final String id;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final ReviewUser user;

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(
        json['createdAt'] as String,
      ),
      user: ReviewUser.fromJson(
        Map<String, dynamic>.from(
          json['user'] as Map,
        ),
      ),
    );
  }
}

class ReviewUser {
  const ReviewUser({
    required this.id,
    required this.name,
    required this.image,
  });

  final String id;
  final String? name;
  final String? image;

  factory ReviewUser.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReviewUser(
      id: json['id'] as String,
      name: json['name'] as String?,
      image: json['image'] as String?,
    );
  }
}

class ReviewsResponse {
  const ReviewsResponse({
    required this.reviews,
    required this.count,
    required this.averageRating,
  });

  final List<Review> reviews;
  final int count;
  final double averageRating;

  factory ReviewsResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final items = json['data'] as List? ?? [];

    final meta = json['meta'] is Map
        ? Map<String, dynamic>.from(
            json['meta'] as Map,
          )
        : <String, dynamic>{};

    return ReviewsResponse(
      reviews: items
          .map(
            (item) => Review.fromJson(
              Map<String, dynamic>.from(
                item as Map,
              ),
            ),
          )
          .toList(),
      count: (meta['count'] as num?)?.toInt() ?? items.length,
      averageRating:
          (meta['averageRating'] as num?)?.toDouble() ?? 0,
    );
  }
}