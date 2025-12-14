import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/trip_radar_viewmodel.dart';
import '../models/trip_offer.dart';

final tripOffersProvider =
StateNotifierProvider<TripRadarViewModel, List<TripOffer>>(
      (ref) => TripRadarViewModel(),
);
