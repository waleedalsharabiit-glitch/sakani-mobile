import '../../../core/network/api_client.dart';
import '../models/favorite.dart';

class FavoriteApi {
  FavoriteApi(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Favorite>> getFavorites() async {
    final response = await _apiClient.dio.get('/favorites');

    final data = Map<String, dynamic>.from(
      response.data as Map,
    );

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'فشل جلب المفضلة',
      );
    }

    final items = data['data'] as List? ?? [];

    return items
        .map(
          (item) => Favorite.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<bool> addFavorite(String propertyId) async {
    final response = await _apiClient.dio.post(
      '/favorites',
      data: {
        'propertyId': propertyId,
      },
    );

    final data = Map<String, dynamic>.from(
      response.data as Map,
    );

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'فشل إضافة العقار إلى المفضلة',
      );
    }

    return data['data']?['isFavorite'] == true;
  }

  Future<bool> removeFavorite(String propertyId) async {
    final response = await _apiClient.dio.delete(
      '/favorites/$propertyId',
    );

    final data = Map<String, dynamic>.from(
      response.data as Map,
    );

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'فشل حذف العقار من المفضلة',
      );
    }

    return data['data']?['isFavorite'] == true;
  }
}