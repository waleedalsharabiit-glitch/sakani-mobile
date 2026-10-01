import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_providers.dart';
import '../models/review.dart';
import 'review_api.dart';
import 'review_repository.dart';

final reviewApiProvider = Provider<ReviewApi>((ref) {
  return ReviewApi(
    ref.watch(apiClientProvider),
  );
});

final reviewRepositoryProvider =
    Provider<ReviewRepository>((ref) {
  return ReviewRepository(
    ref.watch(reviewApiProvider),
  );
});

final reviewsProvider = FutureProvider.autoDispose
    .family<ReviewsResponse, String>((ref, propertyId) {
  return ref
      .watch(reviewRepositoryProvider)
      .getReviews(propertyId);
});