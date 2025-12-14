class TripOffer {
  final String id;
  final String serviceType;
  final double price;
  final double rating;
  final String pickupEta;      // e.g. "2 min (0.4 km)"
  final String tripDuration;   // e.g. "15 min (5.2 km)"
  final String pickupAddress;
  final String dropoffAddress;

  const TripOffer({
    required this.id,
    required this.serviceType,
    required this.price,
    required this.rating,
    required this.pickupEta,
    required this.tripDuration,
    required this.pickupAddress,
    required this.dropoffAddress,
  });

  /// -------------------------
  /// FACTORY: Convert JSON → TripOffer
  /// -------------------------
  factory TripOffer.fromJson(Map<String, dynamic> json) {
    return TripOffer(
      id: json["id"].toString(),
      serviceType: json["service_type"] ?? "Standard",
      price: double.tryParse(json["price"].toString()) ?? 0.0,
      rating: double.tryParse(json["rating"].toString()) ?? 5.0,
      pickupEta: json["pickup_eta"] ?? "N/A",
      tripDuration: json["trip_duration"] ?? "N/A",
      pickupAddress: json["pickup_address"] ?? "Unknown pickup",
      dropoffAddress: json["dropoff_address"] ?? "Unknown dropoff",
    );
  }

  /// -------------------------
  /// Convert TripOffer → JSON (Useful for debugging, sockets, etc.)
  /// -------------------------
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "service_type": serviceType,
      "price": price,
      "rating": rating,
      "pickup_eta": pickupEta,
      "trip_duration": tripDuration,
      "pickup_address": pickupAddress,
      "dropoff_address": dropoffAddress,
    };
  }
}
