import 'package:dio/dio.dart';

import '../models/booking.dart';
import 'booking_api.dart';

class BookingRepository {
  BookingRepository(this._api);

  final BookingApi _api;

  Future<Booking> createBooking({
    required String propertyId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await _api.createBooking(
        propertyId: propertyId,
        startDate: startDate,
        endDate: endDate,
      );
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

  Future<List<Booking>> getBookings() async {
    try {
      return await _api.getBookings();
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