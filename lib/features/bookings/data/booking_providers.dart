import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_providers.dart';
import '../models/booking.dart';
import 'booking_api.dart';
import 'booking_repository.dart';

final bookingApiProvider = Provider<BookingApi>((ref) {
  return BookingApi(
    ref.watch(apiClientProvider),
  );
});

final bookingRepositoryProvider =
    Provider<BookingRepository>((ref) {
  return BookingRepository(
    ref.watch(bookingApiProvider),
  );
});

final bookingsProvider = FutureProvider.autoDispose<List<Booking>>(
  (ref) {
    return ref
        .watch(bookingRepositoryProvider)
        .getBookings();
  },
);