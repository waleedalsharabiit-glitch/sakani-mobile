import '../../../core/network/api_client.dart';
import '../models/review.dart';

class ReviewApi {
  ReviewApi(this._apiClient);

  final ApiClient _apiClient;

  Future<ReviewsResponse> getReviews(
    String propertyId,
  ) async {
    final response = await _apiClient.dio.get(
      '/reviews',
      queryParameters: {
        'propertyId': propertyId,
      },
    );

    final data = Map<String, dynamic>.from(
      response.data as Map,
    );

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'فشل جلب التقييمات',
      );
    }

    return ReviewsResponse.fromJson(data);
  }

  Future<Review> addReview({
    required String propertyId,
    required int rating,
    String? comment,
  }) async {
    final response = await _apiClient.dio.post(
      '/reviews',
      data: {
        'propertyId': propertyId,
        'rating': rating,
        'comment': comment,
      },
    );

    final data = Map<String, dynamic>.from(
      response.data as Map,
    );

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'فشل إضافة التقييم',
      );
    }

    return Review.fromJson(
      Map<String, dynamic>.from(
        data['data'] as Map,
      ),
    );
  }

  Future<Review> updateReview({
    required String reviewId,
    required int rating,
    String? comment,
  }) async {
    final response = await _apiClient.dio.put(
      '/reviews/$reviewId',
      data: {
        'rating': rating,
        'comment': comment,
      },
    );

    final data = Map<String, dynamic>.from(
      response.data as Map,
    );

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'فشل تعديل التقييم',
      );
    }

    return Review.fromJson(
      Map<String, dynamic>.from(
        data['data'] as Map,
      ),
    );
  }

  Future<void> deleteReview(
    String reviewId,
  ) async {
    final response = await _apiClient.dio.delete(
      '/reviews/$reviewId',
    );

    final data = Map<String, dynamic>.from(
      response.data as Map,
    );

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'فشل حذف التقييم',
      );
    }
  }
}