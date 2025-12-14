import 'package:flutter/material.dart';
import '../../../models/trip_offer.dart';

class TripOfferCard extends StatelessWidget {
  final TripOffer offer;
  final VoidCallback onAccept;

  const TripOfferCard({
    Key? key,
    required this.offer,
    required this.onAccept,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Service + rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black87, width: 1),
                  ),
                  child: Text(
                    offer.serviceType,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14),
                    const SizedBox(width: 3),
                    Text(
                      offer.rating.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// Price
            Text(
              "GYD ${offer.price.toStringAsFixed(0)}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),
            Text(offer.pickupEta, style: const TextStyle(fontSize: 13)),
            Text(offer.tripDuration, style: const TextStyle(fontSize: 13)),

            const SizedBox(height: 8),
            Text(
              offer.pickupAddress,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              offer.dropoffAddress,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Accept',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
