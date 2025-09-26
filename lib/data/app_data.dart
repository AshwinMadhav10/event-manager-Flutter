import 'package:cloud_firestore/cloud_firestore.dart';



class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool read;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.createdAt,
    this.read = false,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      read: data['read'] ?? false,
    );
  }
}

class AdminProfile {
  String name;
  String email;
  String phone;

  AdminProfile({
    required this.name,
    required this.email,
    required this.phone,
  });
}

class AppData {
  static List<dynamic> allEquipment = [];
  static AdminProfile currentAdminProfile = AdminProfile(
    name: 'Admin User',
    email: 'admin@example.com',
    phone: '+1234567890',
  );
  static List<dynamic> venues = [];
  // No static data; rely on Firestore streams in respective screens
}