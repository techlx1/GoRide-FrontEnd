import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';


class RideTypeSelectorWidget extends StatefulWidget {
  final Function(String vehicleType) onRideTypeSelected;
  final LatLng? pickupLocation;
  final LatLng? destinationLocation;

  const RideTypeSelectorWidget({
    Key? key,
    required this.onRideTypeSelected,
    this.pickupLocation,
    this.destinationLocation,
  }) : super(key: key);

  @override
  State<RideTypeSelectorWidget> createState() => _RideTypeSelectorWidgetState();
}

class _RideTypeSelectorWidgetState extends State<RideTypeSelectorWidget> {
  String _selectedVehicleType = 'economy';

  final List<Map<String, dynamic>> _vehicleTypes = [
    {
      'type': 'economy',
      'name': 'Economy',
      'description': 'Affordable rides with reliable cars',
      'icon': Icons.directions_car,
      'basePrice': 8.00,
      'pricePerKm': 1.50,
      'eta': '3-5 min',
      'capacity': '4 seats',
    },
    {
      'type': 'comfort',
      'name': 'Comfort',
      'description': 'Extra legroom and newer vehicles',
      'icon': Icons.airport_shuttle,
      'basePrice': 12.00,
      'pricePerKm': 2.00,
      'eta': '5-8 min',
      'capacity': '4 seats',
    },
    {
      'type': 'premium',
      'name': 'Premium',
      'description': 'High-end cars with professional drivers',
      'icon': Icons.local_taxi,
      'basePrice': 20.00,
      'pricePerKm': 3.00,
      'eta': '8-12 min',
      'capacity': '4 seats',
    },
    {
      'type': 'suv',
      'name': 'SUV',
      'description': 'More space for groups and luggage',
      'icon': Icons.airport_shuttle,
      'basePrice': 15.00,
      'pricePerKm': 2.50,
      'eta': '6-10 min',
      'capacity': '6 seats',
    },
  ];

  double _calculateEstimatedPrice(Map<String, dynamic> vehicleType) {
    if (widget.pickupLocation == null || widget.destinationLocation == null) {
      return vehicleType['basePrice'];
    }

    // Simple distance calculation (in practice, use proper route calculation)
    final double distanceKm = _calculateDistance(
      widget.pickupLocation!,
      widget.destinationLocation!,
    );

    return vehicleType['basePrice'] + (distanceKm * vehicleType['pricePerKm']);
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    // Simplified distance calculation (Haversine formula would be more accurate)
    const double earthRadius = 6371; // Earth's radius in kilometers
    final double dLat = (point2.latitude - point1.latitude) * (3.14159 / 180);
    final double dLon = (point2.longitude - point1.longitude) * (3.14159 / 180);

    final double a = (dLat / 2) * (dLat / 2) +
        (point1.latitude * (3.14159 / 180)) *
            (point2.latitude * (3.14159 / 180)) *
            (dLon / 2) *
            (dLon / 2);

    final double c = 2 * (a / (1 + a)).abs();
    return earthRadius * c;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose a ride',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),

        // Vehicle Type List
        Container(
          constraints: BoxConstraints(maxHeight: 240.h),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _vehicleTypes.length,
            separatorBuilder: (context, index) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final vehicleType = _vehicleTypes[index];
              final isSelected = _selectedVehicleType == vehicleType['type'];
              final estimatedPrice = _calculateEstimatedPrice(vehicleType);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedVehicleType = vehicleType['type'];
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withAlpha(26)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12.w),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Vehicle Icon
                      Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8.w),
                        ),
                        child: Icon(
                          vehicleType['icon'],
                          color: isSelected ? Colors.white : Colors.grey[600],
                          size: 24.w,
                        ),
                      ),
                      SizedBox(width: 16.w),

                      // Vehicle Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  vehicleType['name'],
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(4.w),
                                  ),
                                  child: Text(
                                    vehicleType['eta'],
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              vehicleType['description'],
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.people,
                                  size: 14.w,
                                  color: Colors.grey[500],
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  vehicleType['capacity'],
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'GY\$${estimatedPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          if (widget.pickupLocation == null ||
                              widget.destinationLocation == null)
                            Text(
                              'Base fare',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey[500],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 16.h),

        // Book Ride Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (widget.pickupLocation != null &&
                    widget.destinationLocation != null)
                ? () => widget.onRideTypeSelected(_selectedVehicleType)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.w),
              ),
              elevation: 0,
            ),
            child: Text(
              (widget.pickupLocation != null &&
                      widget.destinationLocation != null)
                  ? 'Book ${_vehicleTypes.firstWhere((v) => v['type'] == _selectedVehicleType)['name']}'
                  : 'Select pickup and destination',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
