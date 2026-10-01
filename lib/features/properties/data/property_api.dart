
import '../../../core/network/api_client.dart';
import '../models/property_details.dart';
import '../models/property_list_response.dart';

class PropertyApi {
  PropertyApi(this._apiClient);

  final ApiClient _apiClient;

  Future<PropertyListResponse> getProperties({
    String? query,
    String? city,
    String? category,
    String sort = 'newest',
    int page = 1,
  }) async {
    final response = await _apiClient.dio.get(
      '/properties',
      queryParameters: {
        if (query != null && query.trim().isNotEmpty)
          'q': query.trim(),
        if (city != null && city.trim().isNotEmpty)
          'city': city.trim(),
        if (category != null && category.trim().isNotEmpty)
          'category': category.trim(),
        'sort': sort,
        'page': page,
      },
    );

    final data = Map<String, dynamic>.from(
      response.data as Map,
    );

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'فشل جلب العقارات',
      );
    }

    return PropertyListResponse.fromJson(data);
  }
    Future<PropertyDetails> getProperty(String id) async {
    final response = await _apiClient.dio.get(
      '/properties/$id',
    );

    final data = Map<String, dynamic>.from(
      response.data as Map,
    );

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'فشل جلب بيانات العقار',
      );
    }

    return PropertyDetails.fromJson(
      Map<String, dynamic>.from(
        data['data'] as Map,
      ),
    );
  }
}