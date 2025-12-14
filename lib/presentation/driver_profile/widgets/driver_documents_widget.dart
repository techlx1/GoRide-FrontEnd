import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class DriverDocumentsWidget extends StatelessWidget {
  final List<dynamic> documents;

  const DriverDocumentsWidget({
    Key? key,
    required this.documents,
  }) : super(key: key);

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  // Convert backend types → readable labels
  String _formatType(String type) {
    switch (type) {
      case "license_front":
        return "License (Front)";
      case "license_back":
        return "License (Back)";
      case "vehicle_registration":
        return "Vehicle Registration";
      default:
        return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return _emptyBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Uploaded Documents",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 1.5.h),

        ...documents.map((doc) => _buildDocItem(doc)).toList(),
      ],
    );
  }

  Widget _emptyBox() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Text(
          "No documents uploaded",
          style: TextStyle(fontSize: 12.sp, color: Colors.black54),
        ),
      ),
    );
  }

  Widget _buildDocItem(dynamic doc) {
    final status = doc['status'] ?? 'unknown';
    final type = _formatType(doc['type'] ?? '');
    final uploadedAt = doc['uploaded_at'];

    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _statusIcon(status),
            color: _statusColor(status),
            size: 22.sp,
          ),
          SizedBox(width: 4.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: .5.h),

                Text(
                  "Status: ${status[0].toUpperCase()}${status.substring(1)}",
                  style: TextStyle(fontSize: 10.sp, color: Colors.black54),
                ),

                if (uploadedAt != null) ...[
                  SizedBox(height: .7.h),
                  Text(
                    "Uploaded: $uploadedAt",
                    style: TextStyle(fontSize: 9.sp, color: Colors.black38),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
