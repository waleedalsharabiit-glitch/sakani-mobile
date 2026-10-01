import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_providers.dart';
import '../models/property_details.dart';
import '../models/property_list_response.dart';
import 'property_api.dart';
import 'property_repository.dart';

final propertyApiProvider = Provider<PropertyApi>((ref) {
  return PropertyApi(
    ref.watch(apiClientProvider),
  );
});

final propertyRepositoryProvider =
    Provider<PropertyRepository>((ref) {
  return PropertyRepository(
    ref.watch(propertyApiProvider),
  );
});

class PropertyQuery {
  const PropertyQuery({
    this.search = '',
    this.city,
    this.category,
    this.sort = 'newest',
    this.page = 1,
  });

  final String search;
  final String? city;
  final String? category;
  final String sort;
  final int page;

  @override
  bool operator ==(Object other) {
    return other is PropertyQuery &&
        other.search == search &&
        other.city == city &&
        other.category == category &&
        other.sort == sort &&
        other.page == page;
  }

  @override
  int get hashCode => Object.hash(
        search,
        city,
        category,
        sort,
        page,
      );
}

final propertiesProvider = FutureProvider.autoDispose
    .family<PropertyListResponse, PropertyQuery>((ref, query) {
  return ref
      .watch(propertyRepositoryProvider)
      .getProperties(
        query: query.search,
        city: query.city,
        category: query.category,
        sort: query.sort,
        page: query.page,
      );
});

final propertyDetailsProvider = FutureProvider.autoDispose
    .family<PropertyDetails, String>((ref, id) {
  return ref
      .watch(propertyRepositoryProvider)
      .getProperty(id);
});