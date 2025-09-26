import 'package:cloud_firestore/cloud_firestore.dart';

class Equipment {
  final String id;
  final String name;
  final String category;
  final int totalQuantity;
  final int availableQuantity;
  final bool isEnabled;
  final Timestamp createdAt;
  final String? description;
  final bool maintenanceMode;
  final Timestamp lastUpdated;

  Equipment({
    required this.id,
    required this.name,
    required this.category,
    required this.totalQuantity,
    required this.availableQuantity,
    required this.isEnabled,
    required this.createdAt,
    this.description,
    required this.maintenanceMode,
    required this.lastUpdated,
  });

  factory Equipment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Equipment(
      id: doc.id,
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? '',
      totalQuantity: (data['totalQuantity'] as int?) ?? 0,
      availableQuantity: (data['availableQuantity'] as int?) ?? 0,
      isEnabled: (data['isEnabled'] as bool?) ?? true,
      createdAt: (data['createdAt'] as Timestamp?) ?? Timestamp.now(),
      description: data['description'] as String?,
      maintenanceMode: data['maintenanceMode'] as bool? ?? false,
      lastUpdated: (data['lastUpdated'] as Timestamp?) ?? (data['createdAt'] as Timestamp?) ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'totalQuantity': totalQuantity, 
      'availableQuantity': availableQuantity,
      'isEnabled': isEnabled,
      'createdAt': createdAt,
      'description': description,
      'maintenanceMode': maintenanceMode,
      'lastUpdated': lastUpdated,
    };
  }

  // Check if equipment is available
  bool get isAvailable {
    return isEnabled && !maintenanceMode && availableQuantity > 0;
  }

  // Get current usage status
  String get usageStatus {
    if (!isEnabled) return 'Disabled';
    if (maintenanceMode) return 'Under Maintenance';
    if (availableQuantity == 0) return 'Not Available';
    return 'Available';
  }

  // Get availability percentage
  double get availabilityPercentage {
    if (totalQuantity == 0) return 0.0;
    return (availableQuantity / totalQuantity) * 100;
  }
}