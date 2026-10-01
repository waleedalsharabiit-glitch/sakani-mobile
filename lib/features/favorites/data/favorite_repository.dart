import 'package:dio/dio.dart';

import '../models/favorite.dart';
import 'favorite_api.dart';

class FavoriteRepository {
  FavoriteRepository(this._api);

  final FavoriteApi _api;

  Future<List<Favorite>> getFavorites() async {
    try {
      return await _api.getFavorites();
    } on DioException catch (error) {
      final data = error.response?.data;

      if (data is Map && data['message'] != null) {
        throw Exception(
          data['message'].toString(),
        );
      }

      throw Exception('تعذر الاتصال بالخادم');
    }
  }

  Future<bool> addFavorite(String propertyId) async {
    try {
      return await _api.addFavorite(propertyId);
    } on DioException catch (error) {
      final data = error.response?.data;

      if (data is Map && data['message'] != null) {
        throw Exception(
          data['message'].toString(),
        );
      }

      throw Exception('تعذر الاتصال بالخادم');
    }
  }

  Future<bool> removeFavorite(String propertyId) async {
    try {
      return await _api.removeFavorite(propertyId);
    } on DioException catch (error) {
      final data = error.response?.data;

      if (data is Map && data['message'] != null) {
        throw Exception(
          data['message'].toString(),
        );
      }

      throw Exception('تعذر الاتصال بالخادم');
    }
  }
}