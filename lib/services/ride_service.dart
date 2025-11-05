import './supabase_service.dart';

class RideService {
  final _client = SupabaseService.instance.client;

  // Request a new ride
  Future<Map<String, dynamic>> requestRide({
    required double pickupLatitude,
    required double pickupLongitude,
    required String pickupAddress,
    required double destinationLatitude,
    required double destinationLongitude,
    required String destinationAddress,
    required String vehicleType,
    String paymentMethod = 'cash',
  }) async {
    try {
      final response = await _client
          .from('rides')
          .insert({
            'rider_id': _client.auth.currentUser?.id,
            'pickup_latitude': pickupLatitude,
            'pickup_longitude': pickupLongitude,
            'pickup_address': pickupAddress,
            'destination_latitude': destinationLatitude,
            'destination_longitude': destinationLongitude,
            'destination_address': destinationAddress,
            'vehicle_type': vehicleType,
            'payment_method': paymentMethod,
            'status': 'requested',
          })
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to request ride: $error');
    }
  }

  // Get available drivers near location
  Future<List<Map<String, dynamic>>> getNearbyDrivers({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    try {
      final response = await _client.from('driver_profiles').select('''
            id, user_id, vehicle_model, vehicle_color, vehicle_type, rating,
            current_latitude, current_longitude,
            user_profiles!inner(full_name, profile_picture_url)
          ''').eq('is_online', true).eq('is_verified', true);

      return response;
    } catch (error) {
      throw Exception('Failed to get nearby drivers: $error');
    }
  }

  // Get user's ride history
  Future<List<Map<String, dynamic>>> getUserRides() async {
    try {
      var query = _client.from('rides').select('''
            id, pickup_address, destination_address, status, fare_amount,
            requested_at, completed_at, vehicle_type, payment_method
          ''');

      query = query.eq('rider_id', _client.auth.currentUser!.id);

      final response =
          await query.order('requested_at', ascending: false).limit(50);

      return response;
    } catch (error) {
      throw Exception('Failed to get user rides: $error');
    }
  }

  // Get active ride for user
  Future<Map<String, dynamic>?> getActiveRide() async {
    try {
      final response = await _client
          .from('rides')
          .select('''
            id, driver_id, pickup_address, destination_address, status,
            pickup_latitude, pickup_longitude, destination_latitude,
            destination_longitude, vehicle_type, requested_at, accepted_at,
            driver_profiles!inner(user_id, vehicle_model, vehicle_color, rating,
              user_profiles!inner(full_name, phone_number, profile_picture_url))
          ''')
          .eq('rider_id', _client.auth.currentUser!.id)
          .inFilter('status', ['requested', 'accepted', 'in_progress'])
          .order('requested_at', ascending: false)
          .limit(1);

      return response.isEmpty ? null : response.first;
    } catch (error) {
      throw Exception('Failed to get active ride: $error');
    }
  }

  // Cancel a ride
  Future<Map<String, dynamic>> cancelRide(String rideId) async {
    try {
      final response = await _client
          .from('rides')
          .update({
            'status': 'cancelled',
            'cancelled_at': DateTime.now().toIso8601String(),
          })
          .eq('id', rideId)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to cancel ride: $error');
    }
  }

  // Submit ride rating
  Future<Map<String, dynamic>> submitRideRating({
    required String rideId,
    required String rateeId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await _client
          .from('ride_ratings')
          .insert({
            'ride_id': rideId,
            'rater_id': _client.auth.currentUser!.id,
            'ratee_id': rateeId,
            'rating': rating,
            'comment': comment,
          })
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to submit rating: $error');
    }
  }

  // Real-time ride updates subscription
  Stream<Map<String, dynamic>> subscribeToRideUpdates(String rideId) {
    return _client
        .from('rides')
        .stream(primaryKey: ['id'])
        .eq('id', rideId)
        .map((data) => data.isNotEmpty ? data.first : {});
  }

  // Get driver location updates
  Stream<List<Map<String, dynamic>>> subscribeToDriverLocations() {
    return _client
        .from('driver_profiles')
        .stream(primaryKey: ['id']);
  }
}