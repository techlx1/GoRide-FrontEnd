import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';


class LocationSearchWidget extends StatefulWidget {
  final Function(String address, LatLng location) onPickupLocationSelected;
  final Function(String address, LatLng location) onDestinationLocationSelected;

  const LocationSearchWidget({
    Key? key,
    required this.onPickupLocationSelected,
    required this.onDestinationLocationSelected,
  }) : super(key: key);

  @override
  State<LocationSearchWidget> createState() => _LocationSearchWidgetState();
}

class _LocationSearchWidgetState extends State<LocationSearchWidget> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _pickupFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();

  List<Map<String, dynamic>> _pickupSuggestions = [];
  List<Map<String, dynamic>> _destinationSuggestions = [];
  bool _showPickupSuggestions = false;
  bool _showDestinationSuggestions = false;

  // Popular locations in Georgetown, Guyana
  final List<Map<String, dynamic>> _popularLocations = [
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
  ];

  @override
  void initState() {
    super.initState();
    _pickupController.text = 'Current Location';

    _pickupFocusNode.addListener(() {
      if (_pickupFocusNode.hasFocus) {
        _updatePickupSuggestions(_pickupController.text);
      } else {
        setState(() {
          _showPickupSuggestions = false;
        });
      }
    });

    _destinationFocusNode.addListener(() {
      if (_destinationFocusNode.hasFocus) {
        _updateDestinationSuggestions(_destinationController.text);
      } else {
        setState(() {
          _showDestinationSuggestions = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _pickupFocusNode.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  void _updatePickupSuggestions(String query) {
    setState(() {
      if (query.isEmpty) {
        _pickupSuggestions = _popularLocations;
      } else {
        _pickupSuggestions = _popularLocations
            .where((location) =>
                location['name'].toLowerCase().contains(query.toLowerCase()) ||
                location['address'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      _showPickupSuggestions = true;
    });
  }

  void _updateDestinationSuggestions(String query) {
    setState(() {
      if (query.isEmpty) {
        _destinationSuggestions = _popularLocations;
      } else {
        _destinationSuggestions = _popularLocations
            .where((location) =>
                location['name'].toLowerCase().contains(query.toLowerCase()) ||
                location['address'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      _showDestinationSuggestions = true;
    });
  }

  void _selectPickupLocation(Map<String, dynamic> location) {
    setState(() {
      _pickupController.text = location['name'];
      _showPickupSuggestions = false;
    });
    _pickupFocusNode.unfocus();
    widget.onPickupLocationSelected(
      location['address'],
      LatLng(location['lat'], location['lng']),
    );
  }

  void _selectDestinationLocation(Map<String, dynamic> location) {
    setState(() {
      _destinationController.text = location['name'];
      _showDestinationSuggestions = false;
    });
    _destinationFocusNode.unfocus();
    widget.onDestinationLocationSelected(
      location['address'],
      LatLng(location['lat'], location['lng']),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8.w,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pickup Location Field
          Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: TextField(
                  controller: _pickupController,
                  focusNode: _pickupFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Pickup location',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16.sp,
                    ),
                  ),
                  style: TextStyle(fontSize: 16.sp),
                  onChanged: _updatePickupSuggestions,
                ),
              ),
            ],
          ),

          Divider(color: Colors.grey[300], height: 24.h),

          // Destination Location Field
          Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: TextField(
                  controller: _destinationController,
                  focusNode: _destinationFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Where to?',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16.sp,
                    ),
                  ),
                  style: TextStyle(fontSize: 16.sp),
                  onChanged: _updateDestinationSuggestions,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  // Add to favorites or saved locations
                },
              ),
            ],
          ),

          // Suggestions
          if (_showPickupSuggestions && _pickupSuggestions.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: 8.h),
              constraints: BoxConstraints(maxHeight: 200.h),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _pickupSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _pickupSuggestions[index];
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.location_on,
                      color: Colors.grey[600],
                      size: 20.w,
                    ),
                    title: Text(
                      suggestion['name'],
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      suggestion['address'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    onTap: () => _selectPickupLocation(suggestion),
                  );
                },
              ),
            ),

          if (_showDestinationSuggestions && _destinationSuggestions.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: 8.h),
              constraints: BoxConstraints(maxHeight: 200.h),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _destinationSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _destinationSuggestions[index];
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.location_on,
                      color: Colors.grey[600],
                      size: 20.w,
                    ),
                    title: Text(
                      suggestion['name'],
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      suggestion['address'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    onTap: () => _selectDestinationLocation(suggestion),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
