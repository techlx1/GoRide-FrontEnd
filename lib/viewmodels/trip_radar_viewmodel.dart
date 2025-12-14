import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip_offer.dart';

class TripRadarViewModel extends StateNotifier<List<TripOffer>> {
  TripRadarViewModel() : super(const []) {
    _loadMockOffers();
  }

  void _loadMockOffers() {
    state = [
      TripOffer(
        id: "1",
        serviceType: "Standard",
        price: 1200,
        rating: 4.8,
        pickupEta: "2 min (0.4 km)",
        tripDuration: "15 min (5.2 km)",
        pickupAddress: "North Road",
        dropoffAddress: "Diamond",
      ),
      TripOffer(
        id: "2",
        serviceType: "Comfort",
        price: 1800,
        rating: 4.9,
        pickupEta: "3 min (0.6 km)",
        tripDuration: "18 min (6.1 km)",
        pickupAddress: "Sheriff Street",
        dropoffAddress: "Eccles",
      ),
    ];
  }

  void removeOffer(String id) {
    state = state.where((o) => o.id != id).toList();
  }

  void clear() {
    state = [];
  }
}
