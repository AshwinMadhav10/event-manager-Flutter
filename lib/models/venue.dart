import 'package:cloud_firestore/cloud_firestore.dart';

class Venue {
  final String id;
  final String name;
  final String description;
  final int capacity;
  final bool isEnabled;
  final String location;
  final List<String> amenities;
  final Timestamp createdAt;
  final String? imageUrl;

  Venue({
    required this.id,
    required this.name,
    required this.description,
    required this.capacity,
    required this.isEnabled,
    required this.location,
    required this.amenities,
    required this.createdAt,
    this.imageUrl,
  });

  factory Venue.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Venue(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      capacity: (data['capacity'] as int?) ?? 0,
      isEnabled: (data['isEnabled'] as bool?) ?? true,
      location: data['location'] as String? ?? '',
      amenities: List<String>.from(data['amenities'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?) ?? Timestamp.now(),
      imageUrl: data['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'capacity': capacity,
      'isEnabled': isEnabled,
      'location': location,
      'amenities': amenities,
      'createdAt': createdAt,
      'imageUrl': imageUrl,
    };
  }
} 