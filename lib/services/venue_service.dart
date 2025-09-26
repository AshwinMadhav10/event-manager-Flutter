import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/venue.dart';

class VenueService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all available venues
  static Stream<List<Venue>> getAvailableVenues() {
    return _firestore
        .collection('venues')
        .where('isEnabled', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Venue.fromFirestore(doc))
            .toList());
  }

  // Get venue by ID
  static Future<Venue?> getVenueById(String venueId) async {
    try {
      final doc = await _firestore.collection('venues').doc(venueId).get();
      if (doc.exists) {
        return Venue.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Create a new venue
  static Future<Map<String, dynamic>> createVenue({
    required String name,
    required String description,
    required int capacity,
    required String location,
    required List<String> amenities,
  }) async {
    try {
      final venueData = {
        'name': name,
        'description': description,
        'capacity': capacity,
        'location': location,
        'amenities': amenities,
        'isEnabled': true,
        'createdAt': Timestamp.now(),
      };

      final docRef = await _firestore.collection('venues').add(venueData);
      
      return {
        'success': true,
        'venueId': docRef.id,
        'message': 'Venue created successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to create venue: $e',
      };
    }
  }

  // Update venue
  static Future<Map<String, dynamic>> updateVenue({
    required String venueId,
    required String name,
    required String description,
    required int capacity,
    required String location,
    required List<String> amenities,
    required bool isEnabled,
  }) async {
    try {
      final venueData = {
        'name': name,
        'description': description,
        'capacity': capacity,
        'location': location,
        'amenities': amenities,
        'isEnabled': isEnabled,
        'updatedAt': Timestamp.now(),
      };

      await _firestore.collection('venues').doc(venueId).update(venueData);
      
      return {
        'success': true,
        'message': 'Venue updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to update venue: $e',
      };
    }
  }

  // Delete venue
  static Future<Map<String, dynamic>> deleteVenue(String venueId) async {
    try {
      await _firestore.collection('venues').doc(venueId).delete();
      
      return {
        'success': true,
        'message': 'Venue deleted successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to delete venue: $e',
      };
    }
  }

  // Get all venues (for admin)
  static Stream<List<Venue>> getAllVenues() {
    return _firestore
        .collection('venues')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Venue.fromFirestore(doc))
            .toList());
  }

  // Toggle venue availability
  static Future<Map<String, dynamic>> toggleVenueAvailability(String venueId, bool isEnabled) async {
    try {
      await _firestore.collection('venues').doc(venueId).update({
        'isEnabled': isEnabled,
        'updatedAt': Timestamp.now(),
      });
      
      return {
        'success': true,
        'message': 'Venue availability updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to update venue availability: $e',
      };
    }
  }
} 