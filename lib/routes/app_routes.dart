import 'package:flutter/material.dart';

// 🧭 Screens Imports
import '../presentation/login_screen/login_screen.dart';
import '../presentation/user_registration/user_registration.dart';
import '../presentation/rider_home_screen/rider_home_screen.dart';
import '../presentation/ride_booking_confirmation/ride_booking_confirmation.dart';
import '../presentation/active_ride_tracking/active_ride_tracking.dart';
import '../presentation/ride_history/ride_history.dart';
//import '../presentation/user_profile/user_profile.dart';

// 🚗 Driver Screens
import '../presentation/driver_dashboard/driver_dashboard.dart';
import '../presentation/driver_wallet/driver_wallet_screen.dart';
import '../presentation/driver_profile/driver_profile.dart';
import '../presentation/driver_rides/driver_ride_requests.dart';
import '../presentation/driver_rides/driver_ongoing_ride.dart';


class AppRoutes {
  // 🌍 Route Names
  static const String login = '/login';
  static const String userRegistration = '/user-registration';
  static const String riderHomeScreen = '/rider-home-screen';
  static const String rideBookingConfirmation = '/ride-booking-confirmation';
  static const String activeRideTracking = '/active-ride-tracking';
  static const String rideHistory = '/ride-history';
  static const String userProfile = '/user-profile';

  // 🚘 Driver Routes
  static const String driverDashboard = '/driver-dashboard';
  static const String driverWallet = '/driver-wallet';
  static const String driverProfile = '/driver-profile';
  static const String driverRideRequests = '/driver-ride-requests';
  static const String driverOngoingRide = '/driver-ongoing-ride';

  // 🗺️ Route Map
  static Map<String, WidgetBuilder> routes = {
    // 🌍 General App
    login: (context) => const LoginScreen(),
    userRegistration: (context) => const UserRegistration(),
    riderHomeScreen: (context) => const RiderHomeScreen(),
    rideBookingConfirmation: (context) => const RideBookingConfirmation(),
    activeRideTracking: (context) => const ActiveRideTracking(),
    rideHistory: (context) => const RideHistory(),
   // userProfile: (context) => const UserProfile(),

    // 🚘 Driver
    driverDashboard: (context) => const DriverDashboard(),
    driverWallet: (context) => const DriverWalletScreen(),
    driverProfile: (context) => const DriverProfile(),
    driverRideRequests: (context) => const DriverRideRequests(),
    driverOngoingRide: (context) => const DriverOngoingRide(ride: {}),
  };
}
