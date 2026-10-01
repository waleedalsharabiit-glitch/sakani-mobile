import 'property.dart';

class PropertyListResponse {
  const PropertyListResponse({
    required this.properties,
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  final List<Property> properties;
  final int page;
  final int perPage;
  final int total;
  final int totalPages;

  bool get hasNextPage => page < totalPages;

  factory PropertyListResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json['data'] as List? ?? [];

    final pagination = Map<String, dynamic>.from(
      json['pagination'] as Map,
    );

    return PropertyListResponse(
      properties: data
          .map(
            (item) => Property.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      page: pagination['page'] as int? ?? 1,
      perPage: pagination['perPage'] as int? ?? 9,
      total: pagination['total'] as int? ?? 0,
      totalPages: pagination['totalPages'] as int? ?? 0,
    );
  }
}