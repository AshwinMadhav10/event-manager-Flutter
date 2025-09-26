import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../utils/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyEventsScreen extends StatelessWidget {
  final String? statusFilter;
  const MyEventsScreen({super.key, this.statusFilter});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Center(child: Text('Not logged in.'));
    }
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          final events = docs.map((doc) => Event.fromFirestore(doc)).toList();
          final filteredEvents = statusFilter == null
              ? events
              : events.where((e) => e.status == statusFilter).toList();
          if (filteredEvents.isEmpty) {
            return Center(
              child: Text(
                statusFilter == 'pending'
                    ? 'No pending events found.'
                    : statusFilter == 'approved'
                        ? 'No approved events found.'
                        : 'No events found.',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: filteredEvents.length,
            itemBuilder: (context, index) {
              final event = filteredEvents[index];
              return Card(
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(event.status),
                    child: Text(
                      event.eventName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(event.eventName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${event.venue} • ${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year}'),
                  trailing: Chip(
                    label: Text(
                      event.status.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                    backgroundColor: _getStatusColor(event.status),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Student Name', event.studentName),
                          _buildInfoRow('Club/Lot', event.clubOrLot),
                          _buildInfoRow('Faculty', event.facultyIncharge),
                          _buildInfoRow('Audience', event.audienceParticipating),
                          if (event.selectedItems.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Text('Requested Equipment:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 2,
                              runSpacing: 4,
                              children: _getEquipmentCounts(event.selectedItems)
                                  .entries
                                  .map((entry) => Chip(label: Text('${entry.key} (${entry.value})')))
                                  .toList(),
                            ),
                          ],
                          if (event.status == 'rejected' && event.rejectionReason != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.errorColor.withAlpha(25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Rejection Reason', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.errorColor)),
                                  const SizedBox(height: 4),
                                  Text(event.rejectionReason!),
                                ],
                              ),
                            ),
                          ],
                          if (event.status == 'pending' || event.status == 'approved') ...[
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.cancel, color: Colors.white),
                              label: const Text('Cancel Event'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Cancel Event'),
                                    content: const Text('Are you sure you want to cancel this event request?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        child: const Text('Yes, Cancel'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  // Update equipment availability
                                  for (final item in _getEquipmentCounts(event.selectedItems).keys) {
                                    final equipmentDocs = await FirebaseFirestore.instance
                                        .collection('equipment')
                                        .where('name', isEqualTo: item)
                                        .get();
                                    for (final doc in equipmentDocs.docs) {
                                      final currentAvailable = doc['availableQuantity'] as int;
                                      await doc.reference.update({
                                        'availableQuantity': currentAvailable + _getEquipmentCounts(event.selectedItems)[item]!,
                                      });
                                    }
                                  }
                                  // Update event status
                                  await FirebaseFirestore.instance.collection('events').doc(event.id).update({'status': 'cancelled'});
                                  // Log cancellation
                                  await FirebaseFirestore.instance.collection('cancellations').add({
                                    'eventId': event.id,
                                    'eventName': event.eventName,
                                    'cancelledBy': userId,
                                    'cancelledAt': Timestamp.now(),
                                  });
                                  // Notify admin
                                  await FirebaseFirestore.instance.collection('notifications').add({
                                    'userId': 'admin', // Assuming admin has a fixed userId
                                    'title': 'Event Cancelled',
                                    'message': 'Event "${event.eventName}" was cancelled by ${event.studentName}.',
                                    'createdAt': Timestamp.now(),
                                    'read': false,
                                  });
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event cancelled.')));
                                  }
                                }
                              },
                            ),
                          ],
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
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

  Map<String, int> _getEquipmentCounts(List<String> items) {
    final Map<String, int> counts = {};
    for (final item in items) {
      counts[item] = (counts[item] ?? 0) + 1;
    }
    return counts;
  }
}