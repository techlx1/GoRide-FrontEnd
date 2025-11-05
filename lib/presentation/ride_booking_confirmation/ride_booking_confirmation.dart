import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/booking_status_widget.dart';
import './widgets/driver_preferences_widget.dart';
import './widgets/fare_breakdown_widget.dart';
import './widgets/mini_map_widget.dart';
import './widgets/payment_method_widget.dart';
import './widgets/promo_code_widget.dart';
import './widgets/ride_summary_card_widget.dart';
import './widgets/vehicle_selection_widget.dart';

class RideBookingConfirmation extends StatefulWidget {
  const RideBookingConfirmation({Key? key}) : super(key: key);

  @override
  State<RideBookingConfirmation> createState() =>
      _RideBookingConfirmationState();
}

class _RideBookingConfirmationState extends State<RideBookingConfirmation> {
  // Mock data for ride details
  final Map<String, dynamic> _rideDetails = {
    'pickupAddress': 'Georgetown Public Hospital, Georgetown',
    'dropoffAddress': 'Stabroek Market, Water Street, Georgetown',
    'pickupLatitude': -6.8014,
    'pickupLongitude': -58.1552,
    'dropoffLatitude': -6.7834,
    'dropoffLongitude': -58.1234,
    'estimatedDuration': 15,
    'estimatedDistance': 8.5,
  };

  // Mock vehicle types
  final List<Map<String, dynamic>> _vehicleTypes = [
    {
      'id': 'economy',
      'name': 'Economy',
      'price': 850,
      'icon':
          'https://images.unsplash.com/photo-1549924231-f129b911e442?w=400&h=300&fit=crop',
    },
    {
      'id': 'comfort',
      'name': 'Comfort',
      'price': 1200,
      'icon':
          'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400&h=300&fit=crop',
    },
    {
      'id': 'premium',
      'name': 'Premium',
      'price': 1800,
      'icon':
          'https://images.unsplash.com/photo-1563720223185-11003d516935?w=400&h=300&fit=crop',
    },
  ];

  // State variables
  String _selectedVehicleId = 'economy';
  Map<String, dynamic> _selectedPaymentMethod = {
    'id': 'cash',
    'name': 'Cash Payment',
    'type': 'cash',
    'details': 'Pay your driver directly',
  };
  String _appliedPromoCode = '';
  bool _femaleDriverPreference = false;
  bool _accessibilityRequired = false;
  String _bookingStatus = 'ready';
  int _nearbyDrivers = 12;
  int _estimatedWaitTime = 3;
  bool _isBooking = false;

  @override
  Widget build(BuildContext context) {
    final selectedVehicle = _vehicleTypes.firstWhere(
      (vehicle) => vehicle['id'] == _selectedVehicleId,
      orElse: () => _vehicleTypes.first,
    );

    final fareDetails = _calculateFareDetails(selectedVehicle['price'] as int);

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Confirm Booking',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          onPressed: () => _handleBackPress(),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mini Map
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: MiniMapWidget(rideDetails: _rideDetails),
                    ),
                    SizedBox(height: 2.h),

                    // Ride Summary Card
                    RideSummaryCardWidget(
                      rideDetails: _rideDetails,
                      onEditPickup: _handleEditPickup,
                      onEditDestination: _handleEditDestination,
                    ),

                    // Vehicle Selection
                    VehicleSelectionWidget(
                      vehicleTypes: _vehicleTypes,
                      selectedVehicleId: _selectedVehicleId,
                      onVehicleSelected: _handleVehicleSelection,
                    ),

                    // Fare Breakdown
                    FareBreakdownWidget(fareDetails: fareDetails),

                    // Payment Method
                    PaymentMethodWidget(
                      selectedPaymentMethod: _selectedPaymentMethod,
                      onChangePaymentMethod: _handleChangePaymentMethod,
                    ),

                    // Promo Code
                    PromoCodeWidget(
                      onPromoCodeApplied: _handlePromoCodeApplied,
                      appliedPromoCode: _appliedPromoCode.isNotEmpty
                          ? _appliedPromoCode
                          : null,
                    ),

                    // Driver Preferences
                    DriverPreferencesWidget(
                      femaleDriverPreference: _femaleDriverPreference,
                      accessibilityRequired: _accessibilityRequired,
                      onFemaleDriverToggle: (value) {
                        setState(() {
                          _femaleDriverPreference = value;
                        });
                      },
                      onAccessibilityToggle: (value) {
                        setState(() {
                          _accessibilityRequired = value;
                        });
                      },
                    ),

                    // Booking Status
                    BookingStatusWidget(
                      status: _bookingStatus,
                      nearbyDrivers: _nearbyDrivers,
                      estimatedWaitTime: _estimatedWaitTime,
                    ),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),

            // Bottom Action Buttons
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Estimated Arrival Time
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'schedule',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 5.w,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Estimated arrival: ${_estimatedWaitTime} minutes',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            onPressed: _isBooking ? null : _handleCancelBooking,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              side: BorderSide(
                                color: AppTheme.lightTheme.colorScheme.error,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed:
                                _isBooking ? null : _handleConfirmBooking,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              backgroundColor:
                                  AppTheme.lightTheme.colorScheme.primary,
                            ),
                            child: _isBooking
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 4.w,
                                        height: 4.w,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            AppTheme.lightTheme.colorScheme
                                                .onPrimary,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        'Booking...',
                                        style: AppTheme
                                            .lightTheme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: AppTheme
                                              .lightTheme.colorScheme.onPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    'Confirm Booking',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateFareDetails(int basePrice) {
    final baseFare = basePrice.toDouble();
    final distanceCharge = (_rideDetails['estimatedDistance'] as double) * 15.0;
    final timeCharge = (_rideDetails['estimatedDuration'] as int) * 5.0;
    final surgeMultiplier = 1.2; // Peak hour surge

    double discount = 0.0;
    if (_appliedPromoCode.isNotEmpty) {
      switch (_appliedPromoCode) {
        case 'RIDE10':
          discount = (baseFare + distanceCharge + timeCharge) * 0.1;
          break;
        case 'WELCOME20':
          discount = (baseFare + distanceCharge + timeCharge) * 0.2;
          break;
        case 'GUYANA15':
          discount = (baseFare + distanceCharge + timeCharge) * 0.15;
          break;
        case 'NEWUSER25':
          discount = (baseFare + distanceCharge + timeCharge) * 0.25;
          break;
      }
    }

    return {
      'baseFare': baseFare,
      'distanceCharge': distanceCharge,
      'timeCharge': timeCharge,
      'surgeMultiplier': surgeMultiplier,
      'discount': discount,
    };
  }

  void _handleVehicleSelection(String vehicleId) {
    setState(() {
      _selectedVehicleId = vehicleId;
    });
    HapticFeedback.selectionClick();
  }

  void _handleEditPickup() {
    _showLocationSelectionModal(isPickup: true);
  }

  void _handleEditDestination() {
    _showLocationSelectionModal(isPickup: false);
  }

  void _showLocationSelectionModal({required bool isPickup}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: CustomIconWidget(
                        iconName: 'arrow_back',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 6.w,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        isPickup
                            ? 'Select Pickup Location'
                            : 'Select Destination',
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 12.w), // Balance the back button
                  ],
                ),
              ),

              // Location Search and Selection
              Expanded(
                child: _buildLocationSelector(isPickup: isPickup),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationSelector({required bool isPickup}) {
    final TextEditingController searchController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setModalState) {
        List<Map<String, dynamic>> filteredLocations =
            _getFilteredLocations(searchController.text);

        return Column(
          children: [
            // Search Field
            Container(
              margin: EdgeInsets.all(4.w),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'search',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: isPickup
                            ? 'Search pickup location...'
                            : 'Search destination...',
                        border: InputBorder.none,
                        hintStyle:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                      onChanged: (value) {
                        setModalState(() {
                          // Trigger rebuild to update filtered locations
                        });
                      },
                    ),
                  ),
                  if (searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        searchController.clear();
                        setModalState(() {});
                      },
                      child: CustomIconWidget(
                        iconName: 'clear',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 5.w,
                      ),
                    ),
                ],
              ),
            ),

            // Current Location Option (for pickup only)
            if (isPickup)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                child: ListTile(
                  leading: Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'my_location',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 5.w,
                      ),
                    ),
                  ),
                  title: Text(
                    'Use Current Location',
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                  subtitle: Text(
                    'Automatically detect your location',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onTap: () {
                    _useCurrentLocation(isPickup: isPickup);
                    Navigator.pop(context);
                  },
                ),
              ),

            if (isPickup) SizedBox(height: 1.h),

            // Popular Locations List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: filteredLocations.length,
                itemBuilder: (context, index) {
                  final location = filteredLocations[index];
                  return ListTile(
                    leading: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'location_on',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 5.w,
                        ),
                      ),
                    ),
                    title: Text(
                      location['name'] as String,
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      location['address'] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onTap: () {
                      _selectLocation(
                        address: location['address'] as String,
                        name: location['name'] as String,
                        latitude: location['lat'] as double,
                        longitude: location['lng'] as double,
                        isPickup: isPickup,
                      );
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> _getFilteredLocations(String query) {
    final popularLocations = [
      {
        'name': 'Stabroek Market',
        'address': 'Water Street, Georgetown',
        'lat': 6.8206,
        'lng': -58.1624,
      },
      {
        'name': 'Georgetown Public Hospital',
        'address': 'New Market Street, Georgetown',
        'lat': 6.8083,
        'lng': -58.1598,
      },
      {
        'name': 'Guyana National Stadium',
        'address': 'Thomas Lands, Georgetown',
        'lat': 6.8264,
        'lng': -58.1441,
      },
      {
        'name': 'Cheddi Jagan International Airport',
        'address': 'East Bank Demerara',
        'lat': 6.4985,
        'lng': -58.2539,
      },
      {
        'name': 'University of Guyana',
        'address': 'Turkeyen, Georgetown',
        'lat': 6.8472,
        'lng': -58.1028,
      },
      {
        'name': 'Bourda Market',
        'address': 'Bourda Street, Georgetown',
        'lat': 6.8031,
        'lng': -58.1542,
      },
      {
        'name': 'City Mall',
        'address': 'Regent Street, Georgetown',
        'lat': 6.8047,
        'lng': -58.1598,
      },
      {
        'name': 'Georgetown Cricket Club',
        'address': 'Bourda, Georgetown',
        'lat': 6.8017,
        'lng': -58.1528,
      },
      {
        'name': 'Seawall Bandstand',
        'address': 'Kingston, Georgetown',
        'lat': 6.8019,
        'lng': -58.1625,
      },
      {
        'name': 'Main Street Georgetown',
        'address': 'Main Street, Georgetown',
        'lat': 6.8056,
        'lng': -58.1598,
      },
    ];

    if (query.isEmpty) {
      return popularLocations;
    }

    return popularLocations.where((location) {
      final name = (location['name'] as String).toLowerCase();
      final address = (location['address'] as String).toLowerCase();
      final searchQuery = query.toLowerCase();
      return name.contains(searchQuery) || address.contains(searchQuery);
    }).toList();
  }

  void _useCurrentLocation({required bool isPickup}) {
    // Simulate getting current location
    const currentLat = 6.8013;
    const currentLng = -58.1551;
    const currentAddress = 'Current Location, Georgetown';

    _selectLocation(
      address: currentAddress,
      name: 'Current Location',
      latitude: currentLat,
      longitude: currentLng,
      isPickup: isPickup,
    );
  }

  void _selectLocation({
    required String address,
    required String name,
    required double latitude,
    required double longitude,
    required bool isPickup,
  }) {
    setState(() {
      if (isPickup) {
        _rideDetails['pickupAddress'] = address;
        _rideDetails['pickupLatitude'] = latitude;
        _rideDetails['pickupLongitude'] = longitude;
      } else {
        _rideDetails['dropoffAddress'] = address;
        _rideDetails['dropoffLatitude'] = latitude;
        _rideDetails['dropoffLongitude'] = longitude;
      }
    });

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${isPickup ? 'Pickup' : 'Destination'} updated to $name',
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleChangePaymentMethod() {
    _showPaymentMethodModal();
  }

  void _showPaymentMethodModal() {
    final paymentMethods = [
      {
        'id': 'cash',
        'name': 'Cash Payment',
        'type': 'cash',
        'details': 'Pay your driver directly',
      },
      {
        'id': 'card_1',
        'name': 'Credit Card',
        'type': 'card',
        'details': '**** **** **** 1234',
      },
      {
        'id': 'mobile_money',
        'name': 'Mobile Money',
        'type': 'mobile_money',
        'details': 'GTT Mobile Money',
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Payment Method',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              ...paymentMethods.map((method) {
                return ListTile(
                  leading: CustomIconWidget(
                    iconName: method['type'] == 'cash'
                        ? 'payments'
                        : method['type'] == 'card'
                            ? 'credit_card'
                            : 'phone_android',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 6.w,
                  ),
                  title: Text(method['name'] as String),
                  subtitle: Text(method['details'] as String),
                  trailing: _selectedPaymentMethod['id'] == method['id']
                      ? CustomIconWidget(
                          iconName: 'check_circle',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 5.w,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = method;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  void _handlePromoCodeApplied(String promoCode) {
    setState(() {
      _appliedPromoCode = promoCode;
    });
    if (promoCode.isNotEmpty) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Promo code "$promoCode" applied successfully!'),
          backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        ),
      );
    }
  }

  Future<void> _handleConfirmBooking() async {
    setState(() {
      _isBooking = true;
      _bookingStatus = 'searching';
    });

    HapticFeedback.mediumImpact();

    // Simulate booking process
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isBooking = false;
      _bookingStatus = 'confirmed';
    });

    HapticFeedback.heavyImpact();

    // Navigate to active ride tracking
    Navigator.pushReplacementNamed(context, '/active-ride-tracking');
  }

  void _handleCancelBooking() {
    _showCancelConfirmationDialog();
  }

  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Booking'),
          content: const Text('Are you sure you want to cancel this booking?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                'Yes, Cancel',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleBackPress() {
    if (_isBooking) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait while we process your booking'),
        ),
      );
      return;
    }
    Navigator.pop(context);
  }
}
