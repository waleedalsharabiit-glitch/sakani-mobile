import '../../../core/network/api_client.dart';
import '../models/booking.dart';

class BookingApi {
  BookingApi(this._apiClient);

  final ApiClient _apiClient;

  Future<Booking> createBooking({
    required String propertyId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _apiClient.dio.post(
      '/bookings',
      data: {
        'propertyId': propertyId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
    );

    final data = Map<String, dynamic>.from(
      response.data as Map,
    );

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'فشل إنشاء الحجز',
      );
    }

    return Booking.fromJson(
      Map<String, dynamic>.from(
        data['data'] as Map,
      ),
    );
  }

  Future<List<Booking>> getBookings() async {
    final response = await _apiClient.dio.get('/bookings');

    final data = Map<String, dynamic>.from(
      response.data as Map,
    );

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'فشل جلب الحجوزات',
      );
    }

    final items = data['data'] as List? ?? [];

    return items
        .map(
          (item) => Booking.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }
}