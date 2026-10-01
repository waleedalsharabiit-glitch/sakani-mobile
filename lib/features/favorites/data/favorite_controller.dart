import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'favorite_providers.dart';

final favoriteControllerProvider =
    Provider<FavoriteController>((ref) {
  return FavoriteController(ref);
});

class FavoriteController {
  FavoriteController(this.ref);

  final Ref ref;

  Future<void> toggle(String propertyId) async {
    final favoriteIds = ref.read(favoriteIdsProvider);

    final repository = ref.read(
      favoriteRepositoryProvider,
    );

    if (favoriteIds.contains(propertyId)) {
      await repository.removeFavorite(propertyId);
    } else {
      await repository.addFavorite(propertyId);
    }

    ref.invalidate(favoritesProvider);
  }
}