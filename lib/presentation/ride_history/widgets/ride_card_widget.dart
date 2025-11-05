import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RideCardWidget extends StatelessWidget {
  final Map<String, dynamic> ride;
  final VoidCallback? onTap;

  const RideCardWidget({
    Key? key,
    required this.ride,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with date and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(ride['requested_at']),
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Trip route
              Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        width: 2.w,
                        height: 20.h,
                        color: Colors.grey[300],
                      ),
                      Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride['pickup_address'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          ride['destination_address'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Bottom row with vehicle type and fare
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getVehicleIcon(),
                        size: 16.sp,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _getVehicleTypeText(),
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Icon(
                        _getPaymentIcon(),
                        size: 16.sp,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _getPaymentMethodText(),
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (ride['fare_amount'] != null)
                    Text(
                      '\$${ride['fare_amount'].toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryLight,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (ride['status']) {
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

  String _getStatusText() {
    switch (ride['status']) {
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

  IconData _getVehicleIcon() {
    switch (ride['vehicle_type']) {
      case 'economy':
        return Icons.directions_car;
      case 'comfort':
        return Icons.directions_car;
      case 'premium':
        return Icons.directions_car;
      case 'suv':
        return Icons.drive_eta;
      default:
        return Icons.directions_car;
    }
  }

  String _getVehicleTypeText() {
    switch (ride['vehicle_type']) {
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

  IconData _getPaymentIcon() {
    switch (ride['payment_method']) {
      case 'cash':
        return Icons.money;
      case 'card':
        return Icons.credit_card;
      case 'mobile_money':
        return Icons.phone_android;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentMethodText() {
    switch (ride['payment_method']) {
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
      return DateFormat('MMM dd, HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}