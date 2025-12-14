import 'package:flutter/material.dart';

// 🧭 Screens Imports
import '../presentation/login_screen/login_screen.dart';
import '../presentation/user_registration/user_registration.dart';
import '../presentation/rider_home_screen/rider_home_screen.dart';
import '../presentation/ride_booking_confirmation/ride_booking_confirmation.dart';
import '../presentation/active_ride_tracking/active_ride_tracking.dart';
import '../presentation/ride_history/ride_history.dart';

// 🚗 Driver Screens
import '../presentation/driver_dashboard/driver_dashboard.dart';
import '../presentation/driver_wallet/driver_wallet_screen.dart';
import '../presentation/driver_profile/driver_profile.dart';
import '../presentation/driver_rides/driver_ride_requests.dart';
import '../presentation/driver_rides/driver_ongoing_ride.dart';

// ⭐ NEW DRIVER MENU SCREENS
import '../presentation/driver_profile/screens/recent_orders_screen.dart';
import '../presentation/settings/app_suggestions_screen.dart';
import '../presentation/settings/app_language_screen.dart';
import '../presentation/settings/delete_account_screen.dart';
import '../presentation/settings/invite_friend_screen.dart';
import '../presentation/update/app_update_screen.dart';

// ⭐ OTP SCREEN IMPORT (ADD THIS)
import '../../../presentation/otp_verification/otp_verification.dart';

class AppRoutes {
  // 🌍 GENERAL ROUTES
  static const String login = '/login';
  static const String userRegistration = '/user-registration';
  static const String otpVerification = '/otp-verification'; // ⭐ NEW
  static const String riderHomeScreen = '/rider-home-screens';
  static const String rideBookingConfirmation = '/ride-booking-confirmation';
  static const String activeRideTracking = '/active-ride-tracking';
  static const String rideHistory = '/ride-history';

  // 🚘 DRIVER ROUTES
  static const String driverDashboard = '/driver-dashboard';
  static const String driverWallet = '/driver-wallet';
  static const String driverProfile = '/driver-profile';
  static const String driverRideRequests = '/driver-ride-requests';
  static const String driverOngoingRide = '/driver-ongoing-ride';

  // ⭐ NEW DRIVER PROFILE MENU ROUTES
  static const String recentOrders = '/driver-recent-orders';
  static const String appSuggestions = '/app-suggestions';
  static const String appLanguage = '/app-language';
  static const String deleteAccount = '/delete-account';
  static const String inviteFriend = '/invite-friend';
  static const String appUpdate = '/app-update';

  // 🗺️ ROUTE MAP
  static Map<String, WidgetBuilder> routes = {
    // General
    login: (_) => const LoginScreen(),
    userRegistration: (_) => const UserRegistration(),

    otpVerification: (_) => const OtpVerification(),

    riderHomeScreen: (_) => const RiderHomeScreen(),
    rideBookingConfirmation: (_) => const RideBookingConfirmation(),
    activeRideTracking: (_) => const ActiveRideTracking(),
    rideHistory: (_) => const RideHistory(),

    // Driver Core
    driverDashboard: (_) => const DriverDashboard(),
    driverWallet: (_) => const DriverWalletScreen(),
    driverProfile: (_) => const DriverProfile(),
    driverRideRequests: (_) => const DriverRideRequests(),
    driverOngoingRide: (_) => const DriverOngoingRide(ride: {}),

    // ⭐ NEW DRIVER MENU
    recentOrders: (_) => const RecentOrdersScreen(),
    appSuggestions: (_) => const AppSuggestionsScreen(),
    appLanguage: (_) => const AppLanguageScreen(),
    deleteAccount: (_) => const DeleteAccountScreen(),
    inviteFriend: (_) => const InviteFriendScreen(),
    appUpdate: (_) => const AppUpdateScreen(),
  };
}
