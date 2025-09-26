import 'package:flutter/material.dart';
import 'package:lead_project/screens/admin/admin_home_screen.dart';
import '../../models/event.dart';
import '../../utils/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventManagementScreen extends StatefulWidget {
  const EventManagementScreen({super.key});

  @override
  State<EventManagementScreen> createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  Future<void> _approveEvent(Event event) async {
    await FirebaseFirestore.instance.collection('events')
        .doc(event.id)
        .update({
      'status': 'approved',
    });
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': event.userId,
      'title': 'Event Approved',
      'message': 'Your event "${event.eventName}" has been approved.',
      'createdAt': Timestamp.now(),
      'read': false,
    });
  }

  Future<void> _rejectEvent(Event event, String reason) async {
    await FirebaseFirestore.instance.collection('events')
        .doc(event.id)
        .update({
      'status': 'rejected',
      'rejectionReason': reason,
    });
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': event.userId,
      'title': 'Event Rejected',
      'message': 'Your event "${event.eventName}" was rejected. Reason: $reason',
      'createdAt': Timestamp.now(),
      'read': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('events')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty)
            return const Center(child: Text('No events to manage.'));
          final events = docs.map((doc) => Event.fromFirestore(doc)).toList();
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              // Count equipment items
              final equipmentCounts = <String, int>{};
              for (var item in event.selectedItems) {
                equipmentCounts[item] = (equipmentCounts[item] ?? 0) + 1;
              }
              return Card(
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(event.status),
                    child: Text(event.eventName.substring(0, 1).toUpperCase()),
                  ),
                  title: Text(
                    event.eventName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(event.studentName),
                  trailing: Chip(
                    label: Text(
                      event.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: _getStatusColor(event.status),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Event Details'),
                          _buildInfoRow('Event Name', event.eventName),
                          _buildInfoRow('Venue', event.venue),
                          _buildInfoRow(
                            'Date',
                            '${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year}',
                          ),
                          _buildInfoRow('Time', event.eventTime),
                          _buildInfoRow('Audience', event.audienceParticipating),
                          _buildInfoRow('Club or Lot', event.clubOrLot),

                          const SizedBox(height: 16),
                          _buildSectionTitle('Coordinator Information'),
                          _buildInfoRow('Coordinator Name', event.studentName),
                          _buildInfoRow('Coordinator Email', event.studentEmail),
                          _buildInfoRow('Coordinator Phone', event.studentNumber),

                          const SizedBox(height: 16),
                          _buildSectionTitle('Faculty Information'),
                          _buildInfoRow('Faculty Incharge', event.facultyIncharge),
                          _buildInfoRow('Faculty Phone', event.facultyPhone),
                          _buildInfoRow('Faculty Email', event.facultyEmail),

                          const SizedBox(height: 16),
                          _buildSectionTitle('Equipment'),
                          if (equipmentCounts.isNotEmpty)
                            ...equipmentCounts.entries.map((entry) =>
                                _buildInfoRow('item', '${entry.key}     (${entry.value})'))
                          else
                            const Text('No equipment selected'),

                          const SizedBox(height: 16),
                          _buildSectionTitle('Additional Information'),
                          _buildInfoRow('Food Informed',
                              event.foodInformed ? 'Yes' : 'No'),
                          _buildInfoRow('Seating Arrangements',
                              event.seatingArrangements.toString()),
                          _buildInfoRow('Accommodation Informed',
                              event.accommodationInformed ? 'Yes' : 'No'),

                          if (event.status == 'rejected' &&
                              event.rejectionReason != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                _buildSectionTitle('Rejection Reason'),
                                Text(
                                  event.rejectionReason!,
                                  style: const TextStyle(color: AppTheme.errorColor),
                                ),
                              ],
                            ),

                          const SizedBox(height: 16),
                          if (event.status == 'pending')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    String? reason = await showDialog(
                                      context: context,
                                      builder: (context) {
                                        final controller =
                                            TextEditingController();
                                        return AlertDialog(
                                          title: const Text('Reject Event'),
                                          content: TextField(
                                            controller: controller,
                                            decoration: const InputDecoration(
                                              labelText: 'Reason for rejection',
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.black),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.black),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.black, width: 2),
                                              ),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(
                                                context,
                                                controller.text,
                                              ),
                                              child: const Text('Reject'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (reason != null && reason.isNotEmpty) {
                                      await _rejectEvent(event, reason);
                                    }
                                  },
                                  child: const Text(
                                    'Reject',
                                    style: TextStyle(
                                      color: AppTheme.errorColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => _approveEvent(event),
                                  child: const Text('Approve'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return AppTheme.successColor;
      case 'pending':
        return AppTheme.warningColor;
      case 'rejected':
        return AppTheme.errorColor;
      default:
        return AppTheme.textTertiary;
    }
  }
}
