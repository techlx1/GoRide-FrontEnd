import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/ride_service.dart';
import './widgets/empty_ride_history_widget.dart';
import './widgets/ride_card_widget.dart';
import './widgets/ride_filter_widget.dart';
import './widgets/ride_search_widget.dart';

class RideHistory extends StatefulWidget {
  const RideHistory({Key? key}) : super(key: key);

  @override
  State<RideHistory> createState() => _RideHistoryState();
}

class _RideHistoryState extends State<RideHistory> {
  final RideService _rideService = RideService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _rides = [];
  List<Map<String, dynamic>> _filteredRides = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _selectedFilter = 'all';
  String _selectedSort = 'newest';

  @override
  void initState() {
    super.initState();
    _loadRides();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Implement infinite scroll if needed
    }
  }

  Future<void> _loadRides() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final rides = await _rideService.getUserRides();

      setState(() {
        _rides = rides;
        _filteredRides = List.from(rides);
        _isLoading = false;
      });

      _applyFilters();
    } catch (error) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_rides);

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      filtered =
          filtered.where((ride) {
            final searchTerm = _searchController.text.toLowerCase();
            return ride['pickup_address']?.toLowerCase().contains(searchTerm) ==
                    true ||
                ride['destination_address']?.toLowerCase().contains(
                      searchTerm,
                    ) ==
                    true;
          }).toList();
    }

    // Apply status filter
    if (_selectedFilter != 'all') {
      filtered =
          filtered.where((ride) {
            return ride['status'] == _selectedFilter;
          }).toList();
    }

    // Apply sorting
    switch (_selectedSort) {
      case 'newest':
        filtered.sort(
          (a, b) => DateTime.parse(
            b['requested_at'] ?? '',
          ).compareTo(DateTime.parse(a['requested_at'] ?? '')),
        );
        break;
      case 'oldest':
        filtered.sort(
          (a, b) => DateTime.parse(
            a['requested_at'] ?? '',
          ).compareTo(DateTime.parse(b['requested_at'] ?? '')),
        );
        break;
      case 'highest_fare':
        filtered.sort(
          (a, b) => (b['fare_amount'] ?? 0).compareTo(a['fare_amount'] ?? 0),
        );
        break;
      case 'lowest_fare':
        filtered.sort(
          (a, b) => (a['fare_amount'] ?? 0).compareTo(b['fare_amount'] ?? 0),
        );
        break;
    }

    setState(() {
      _filteredRides = filtered;
    });
  }

  void _onSearchChanged(String value) {
    _applyFilters();
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _applyFilters();
  }

  void _onSortChanged(String sort) {
    setState(() {
      _selectedSort = sort;
    });
    _applyFilters();
  }

  Future<void> _onRefresh() async {
    await _loadRides();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Ride History',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryLight,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryLight),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppTheme.primaryLight),
            onPressed: _onRefresh,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _hasError
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                    SizedBox(height: 16.h),
                    Text(
                      'Failed to load ride history',
                      style: GoogleFonts.inter(fontSize: 16.sp),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: _loadRides,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _onRefresh,
                child: Column(
                  children: [
                    // Search and Filter Section
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          RideSearchWidget(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                          ),
                          SizedBox(height: 12.h),
                          RideFilterWidget(
                            selectedFilter: _selectedFilter,
                            selectedSort: _selectedSort,
                            onFilterChanged: _onFilterChanged,
                            onSortChanged: _onSortChanged,
                          ),
                        ],
                      ),
                    ),

                    // Results Summary
                    Container(
                      width: double.infinity,
                      color: Colors.grey[100],
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      child: Text(
                        '${_filteredRides.length} ride${_filteredRides.length != 1 ? 's' : ''}',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),

                    // Ride List
                    Expanded(
                      child:
                          _filteredRides.isEmpty
                              ? const EmptyRideHistoryWidget()
                              : ListView.builder(
                                controller: _scrollController,
                                padding: EdgeInsets.all(16.w),
                                itemCount: _filteredRides.length,
                                itemBuilder: (context, index) {
                                  final ride = _filteredRides[index];
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 12.h),
                                    child: RideCardWidget(
                                      ride: ride,
                                      onTap: () => _showRideDetails(ride),
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
    );
  }

  void _showRideDetails(Map<String, dynamic> ride) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 8.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),

                // Header
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ride Details',
                        style: GoogleFonts.inter(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              ride['status'],
                            ).withAlpha(26),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            _getStatusText(ride['status']),
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: _getStatusColor(ride['status']),
                            ),
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // Trip Info
                        _buildDetailRow(
                          'Date',
                          _formatDate(ride['requested_at']),
                        ),
                        _buildDetailRow('Pickup', ride['pickup_address'] ?? ''),
                        _buildDetailRow(
                          'Destination',
                          ride['destination_address'] ?? '',
                        ),
                        _buildDetailRow(
                          'Vehicle Type',
                          _getVehicleTypeText(ride['vehicle_type']),
                        ),
                        _buildDetailRow(
                          'Payment Method',
                          _getPaymentMethodText(ride['payment_method']),
                        ),

                        if (ride['fare_amount'] != null)
                          _buildDetailRow(
                            'Fare',
                            '\$${ride['fare_amount'].toStringAsFixed(2)}',
                          ),

                        if (ride['completed_at'] != null)
                          _buildDetailRow(
                            'Completed',
                            _formatDate(ride['completed_at']),
                          ),

                        SizedBox(height: 30.h),

                        // Action Buttons
                        if (ride['status'] == 'completed') ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _rebookRide(ride);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryLight,
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Text(
                                'Book Again',
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _downloadReceipt(ride);
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppTheme.primaryLight),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Text(
                                'Download Receipt',
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.primaryLight,
                                ),
                              ),
                            ),
                          ),
                        ],

                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'in_progress':
        return Colors.blue;
      case 'accepted':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'in_progress':
        return 'In Progress';
      case 'accepted':
        return 'Accepted';
      case 'requested':
        return 'Requested';
      default:
        return 'Unknown';
    }
  }

  String _getVehicleTypeText(String? type) {
    switch (type) {
      case 'economy':
        return 'Economy';
      case 'comfort':
        return 'Comfort';
      case 'premium':
        return 'Premium';
      case 'suv':
        return 'SUV';
      default:
        return 'Unknown';
    }
  }

  String _getPaymentMethodText(String? method) {
    switch (method) {
      case 'cash':
        return 'Cash';
      case 'card':
        return 'Card';
      case 'mobile_money':
        return 'Mobile Money';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  void _rebookRide(Map<String, dynamic> ride) {
    // Navigate to ride booking with pre-filled data
    Navigator.pushNamed(
      context,
      '/ride-booking-confirmation',
      arguments: {
        'pickup_address': ride['pickup_address'],
        'destination_address': ride['destination_address'],
        'vehicle_type': ride['vehicle_type'],
      },
    );
  }

  void _downloadReceipt(Map<String, dynamic> ride) {
    // Implement receipt download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Receipt download functionality coming soon'),
      ),
    );
  }
}