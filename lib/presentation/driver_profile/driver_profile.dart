import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/api/driver_api.dart';
import '../../utils/toast_helper.dart';

import '../driver_dashboard/widgets/driver_logout_button.dart';

// Widgets
import 'widgets/driver_header_widget.dart';
import 'widgets/profile_menu_item_widget.dart';

// Screens
import 'edit/vehicle_edit_screen.dart';
import '../driver_wallet/driver_wallet_screen.dart';
import 'screens/recent_orders_screen.dart';
import '../settings/app_suggestions_screen.dart';
import '../settings/app_language_screen.dart';
import '../settings/invite_friend_screen.dart';
import '../settings/delete_account_screen.dart';
import '../update/app_update_screen.dart';

// NEW Screens
import 'edit/driver_info_screen.dart';
import 'screens/documents_screen.dart';
import 'screens/earnings_screen.dart';

class DriverProfile extends StatefulWidget {
  const DriverProfile({Key? key}) : super(key: key);

  @override
  State<DriverProfile> createState() => _DriverProfileState();
}

class _DriverProfileState extends State<DriverProfile> {
  bool _isLoading = true;
  Map<String, dynamic> driverProfile = {};

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _loadDriverProfile);
  }

  // ---------------------------------------------------------
  // LOAD DRIVER PROFILE
  // ---------------------------------------------------------
  Future<void> _loadDriverProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        ToastHelper.showError("Session expired. Please log in again.");
        setState(() => _isLoading = false);
        return;
      }

      final res = await DriverApi.getDriverProfile();

      if (res['success'] != true) {
        ToastHelper.showError(res['message']);
        setState(() => _isLoading = false);
        return;
      }

      setState(() {
        driverProfile = res['profile'] ?? {};
        _isLoading = false;
      });
    } catch (e) {
      ToastHelper.showError("Error loading profile.");
      setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------
  // UI
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Stack(
          children: [
            // PROGRESS or MAIN CONTENT
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: _loadDriverProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 2.h),

                    /// HEADER
                    DriverHeaderWidget(driverProfile: driverProfile),
                    SizedBox(height: 3.h),

                    // =============================
                    // ACCOUNT OVERVIEW SECTION
                    // =============================
                    _sectionTitle("Account Overview", theme),

                    // ----- DRIVER PROFILE -----
                    ProfileMenuItemWidget(
                      icon: Icons.person,
                      title: "Driver Profile",
                      subtitle: "Edit your personal information",
                      showArrow: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DriverInfoScreen(data: driverProfile),
                          ),
                        );
                      },
                    ),

                    // ----- DOCUMENTS -----
                    ProfileMenuItemWidget(
                      icon: Icons.description,
                      title: "Documents",
                      subtitle:
                      "Upload License & Vehicle Registration",
                      showArrow: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DocumentsScreen(),
                          ),
                        );
                      },
                    ),

                    // ----- EARNINGS -----
                    ProfileMenuItemWidget(
                      icon: Icons.monetization_on,
                      title: "Earnings",
                      subtitle: "View payouts & daily earnings",
                      showArrow: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EarningsScreen(),
                          ),
                        );
                      },
                    ),

                    // ----- VEHICLE -----
                    ProfileMenuItemWidget(
                      icon: Icons.car_rental,
                      title: "Vehicle Details",
                      subtitle: "View or update your vehicle",
                      showArrow: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VehicleEditScreen(
                              vehicleData: {},
                            ),
                          ),
                        );
                      },
                    ),

                    // ----- RECENT ORDERS -----
                    ProfileMenuItemWidget(
                      icon: Icons.history,
                      title: "Recent Orders",
                      subtitle: "Completed rides & earnings",
                      showArrow: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const RecentOrdersScreen(),
                          ),
                        );
                      },
                    ),

                    // ----- WALLET -----
                    ProfileMenuItemWidget(
                      icon: Icons.account_balance_wallet,
                      title: "Wallet",
                      subtitle: "Balance, send & receive money",
                      showArrow: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const DriverWalletScreen(),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 3.h),

                    // =============================
                    // ACCOUNT SETTINGS SECTION
                    // =============================
                    _sectionTitle("Account Settings", theme),

                    ProfileMenuItemWidget(
                      icon: Icons.feedback_outlined,
                      title: "App Suggestions",
                      subtitle: "Send feedback to improve the app",
                      showArrow: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const AppSuggestionsScreen(),
                          ),
                        );
                      },
                    ),

                    ProfileMenuItemWidget(
                      icon: Icons.language,
                      title: "App Language",
                      subtitle: "English • Spanish • Portuguese",
                      showArrow: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const AppLanguageScreen(),
                          ),
                        );
                      },
                    ),

                    ProfileMenuItemWidget(
                      icon: Icons.group_add,
                      title: "Invite a Friend",
                      subtitle: "Earn rewards",
                      showArrow: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const InviteFriendScreen(),
                          ),
                        );
                      },
                    ),

                    ProfileMenuItemWidget(
                      icon: Icons.system_update,
                      title: "App Update",
                      subtitle: "Check for updates",
                      showArrow: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const AppUpdateScreen(),
                          ),
                        );
                      },
                    ),

                    ProfileMenuItemWidget(
                      icon: Icons.delete_forever,
                      title: "Delete Account",
                      subtitle: "Permanently delete your account",
                      iconColor: Colors.red,
                      titleColor: Colors.red,
                      showArrow: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const DeleteAccountScreen(),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 3.h),

                    // LOGOUT
                    const DriverLogoutButton(),

                    SizedBox(height: 5.h),
                  ],
                ),
              ),
            ),

            // ===== BACK BUTTON =====
            Positioned(
              top: 10,
              left: 15,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // SECTION TITLE
  // ---------------------------------------------------------
  Widget _sectionTitle(String title, ColorScheme theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 1.h),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: theme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
