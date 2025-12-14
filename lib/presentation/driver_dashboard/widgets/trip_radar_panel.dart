import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/trip_radar_providers.dart';
import '../../../providers/driver_providers.dart';
import '../../../models/trip_offer.dart';
import 'trip_offer_card.dart';

class TripRadarPanel extends ConsumerWidget {
  const TripRadarPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = ref.watch(tripOffersProvider);
    final showTripRadar = ref.watch(showTripRadarProvider);

    if (!showTripRadar) return const SizedBox.shrink();
    if (offers.isEmpty) {
      // auto hide when empty
      ref.read(showTripRadarProvider.notifier).state = false;
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // dim background
        Positioned.fill(
          child: GestureDetector(
            onTap: () =>
            ref.read(showTripRadarProvider.notifier).state = false,
            child: Container(
              color: Colors.black.withOpacity(0.35),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: const EdgeInsets.only(top: 10),
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Column(
              children: [
                _buildHeader(context, ref),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: offers.length,
                    itemBuilder: (context, index) {
                      final offer = offers[index];
                      return TripOfferCard(
                        offer: offer,
                        onAccept: () => _onAccept(context, ref, offer),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Trip Radar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            onPressed: () =>
            ref.read(showTripRadarProvider.notifier).state = false,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  void _onAccept(BuildContext context, WidgetRef ref, TripOffer offer) {
    // TODO: hook this to backend/socket accept
    ref.read(tripOffersProvider.notifier).removeOffer(offer.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Accepted trip ${offer.id} (${offer.price})')),
    );
  }
}
