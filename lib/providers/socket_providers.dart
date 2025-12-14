import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/socket_service.dart';
import 'trip_radar_providers.dart';
import '../models/trip_offer.dart';

final socketListenerProvider = Provider((ref) {
  final socket = SocketService().socket;

  // Listen for Trip Radar offers from backend
  socket.on("trip_radar_offers", (data) {
    // Example data is an array of trip objects
    final offers = (data as List)
        .map((json) => TripOffer(
      id: json["id"],
      serviceType: json["serviceType"],
      price: json["price"],
      rating: json["rating"].toDouble(),
      pickupEta: json["pickupEta"],
      tripDuration: json["tripDuration"],
      pickupAddress: json["pickupAddress"],
      dropoffAddress: json["dropoffAddress"],
    ))
        .toList();

    ref.read(tripOffersProvider.notifier).setOffers(offers);
    ref.read(showTripRadarProvider.notifier).state = true;
  });

  return true;
});
