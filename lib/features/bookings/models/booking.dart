class Booking {
  const Booking({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.property,
  });

  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final BookingProperty? property;

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'] as String? ?? 'PENDING',
      createdAt: DateTime.parse(json['createdAt'] as String),
      property: json['property'] != null
          ? BookingProperty.fromJson(
              Map<String, dynamic>.from(
                json['property'] as Map,
              ),
            )
          : null,
    );
  }
}

class BookingProperty {
  const BookingProperty({
    required this.id,
    required this.title,
    required this.image,
  });

  final String id;
  final String title;
  final String? image;

  factory BookingProperty.fromJson(Map<String, dynamic> json) {
    return BookingProperty(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      image: json['image'] as String?,
    );
  }
}