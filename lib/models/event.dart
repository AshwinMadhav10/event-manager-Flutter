import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String eventName;
  final String studentName;
  final String studentNumber;
  final String studentEmail;
  final String clubOrLot;
  final String facultyIncharge;
  final String facultyPhone;
  final String facultyEmail;
  final String audienceParticipating;
  final DateTime eventDate;
  final String eventTime;
  final String venue;
  final List<String> selectedItems;
  final bool foodInformed;
  final int seatingArrangements;
  final bool accommodationInformed;
  final String status;
  final DateTime createdAt;
  final String userId;
  final String? rejectionReason;

  Event({
    required this.id,
    required this.eventName,
    required this.studentName,
    required this.studentNumber,
    required this.studentEmail,
    required this.clubOrLot,
    required this.facultyIncharge,
    required this.facultyPhone,
    required this.facultyEmail,
    required this.audienceParticipating,
    required this.eventDate,
    required this.eventTime,
    required this.venue,
    required this.selectedItems,
    required this.foodInformed,
    required this.seatingArrangements,
    required this.accommodationInformed,
    required this.status,
    required this.createdAt,
    required this.userId,
    this.rejectionReason,
  });

  factory Event.fromFirestore(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      eventName: data['eventName'] ?? '',
      studentName: data['studentName'] ?? '',
      studentNumber: data['studentNumber'] ?? '',
      studentEmail: data['studentEmail'] ?? '',
      clubOrLot: data['clubOrLot'] ?? '',
      facultyIncharge: data['facultyIncharge'] ?? '',
      facultyPhone: data['facultyPhone'] ?? '',
      facultyEmail: data['facultyEmail'] ?? '',
      audienceParticipating: data['audienceParticipating'] ?? '',
      eventDate: (data['eventDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      eventTime: data['eventTime'] ?? '',
      venue: data['venue'] ?? '',
      selectedItems: List<String>.from(data['selectedItems'] ?? []),
      foodInformed: data['foodInformed'] ?? false,
      seatingArrangements: data['seatingArrangements'] ?? 0,
      accommodationInformed: data['accommodationInformed'] ?? false,
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'] ?? '',
      rejectionReason: data['rejectionReason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventName': eventName,
      'studentName': studentName,
      'studentNumber': studentNumber,
      'studentEmail': studentEmail,
      'clubOrLot': clubOrLot,
      'facultyIncharge': facultyIncharge,
      'facultyPhone': facultyPhone,
      'facultyEmail': facultyEmail,
      'audienceParticipating': audienceParticipating,
      'eventDate': Timestamp.fromDate(eventDate),
      'eventTime': eventTime,
      'venue': venue,
      'selectedItems': selectedItems,
      'foodInformed': foodInformed,
      'seatingArrangements': seatingArrangements,
      'accommodationInformed': accommodationInformed,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
      'rejectionReason': rejectionReason,
    };
  }
} 