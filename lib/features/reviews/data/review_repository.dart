import 'package:dio/dio.dart';

import '../models/review.dart';
import 'review_api.dart';

class ReviewRepository {
  ReviewRepository(this._api);

  final ReviewApi _api;

  Future<ReviewsResponse> getReviews(
    String propertyId,
  ) async {
    try {
      return await _api.getReviews(propertyId);
    } on DioException catch (error) {
      throw Exception(_messageFromError(error));
    }
  }

  Future<Review> addReview({
    required String propertyId,
    required int rating,
    String? comment,
  }) async {
    try {
      return await _api.addReview(
        propertyId: propertyId,
        rating: rating,
        comment: comment,
      );
    } on DioException catch (error) {
      throw Exception(_messageFromError(error));
    }
  }

  Future<Review> updateReview({
    required String reviewId,
    required int rating,
    String? comment,
  }) async {
    try {
      return await _api.updateReview(
        reviewId: reviewId,
        rating: rating,
        comment: comment,
      );
    } on DioException catch (error) {
      throw Exception(_messageFromError(error));
    }
  }

  Future<void> deleteReview(
    String reviewId,
  ) async {
    try {
      await _api.deleteReview(reviewId);
    } on DioException catch (error) {
      throw Exception(_messageFromError(error));
    }
  }

  String _messageFromError(DioException error) {
    final responseData = error.response?.data;

    if (responseData is Map &&
        responseData['message'] != null) {
      return responseData['message'].toString();
    }

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'تعذر الاتصال بالخادم';
    }

    return 'حدث خطأ غير متوقع';
  }
}