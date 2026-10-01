import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_providers.dart';
import '../models/favorite.dart';
import 'favorite_api.dart';
import 'favorite_repository.dart';

final favoriteApiProvider = Provider<FavoriteApi>((ref) {
  return FavoriteApi(
    ref.watch(apiClientProvider),
  );
});

final favoriteRepositoryProvider =
    Provider<FavoriteRepository>((ref) {
  return FavoriteRepository(
    ref.watch(favoriteApiProvider),
  );
});

final favoritesProvider =
    FutureProvider.autoDispose<List<Favorite>>((ref) {
  return ref
      .watch(favoriteRepositoryProvider)
      .getFavorites();
});

final favoriteIdsProvider =
    Provider.autoDispose<Set<String>>((ref) {
  final favorites = ref.watch(favoritesProvider);

  return favorites.maybeWhen(
    data: (items) => {
      for (final item in items) item.property.id,
    },
    orElse: () => <String>{},
  );
});