import 'package:dio/dio.dart';

import '../models/property_details.dart';
import '../models/property_list_response.dart';
import 'property_api.dart';

class PropertyRepository {
  PropertyRepository(this._api);

  final PropertyApi _api;

  Future<PropertyListResponse> getProperties({
    String? query,
    String? city,
    String? category,
    String sort = 'newest',
    int page = 1,
  }) async {
    try {
      return await _api.getProperties(
        query: query,
        city: city,
        category: category,
        sort: sort,
        page: page,
      );
    } on DioException catch (error) {
      final data = error.response?.data;

      if (data is Map && data['message'] != null) {
        throw Exception(data['message'].toString());
      }

      throw Exception('تعذر الاتصال بالخادم');
    }
  }

  Future<PropertyDetails> getProperty(String id) async {
    try {
      return await _api.getProperty(id);
    } on DioException catch (error) {
      final data = error.response?.data;

      if (data is Map && data['message'] != null) {
        throw Exception(data['message'].toString());
      }

      throw Exception('تعذر الاتصال بالخادم');
    }
  }
}