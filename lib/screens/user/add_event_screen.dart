import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/event.dart';
import '../../models/equipment.dart';
import '../../utils/theme.dart';
import 'dart:async';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _coordinatorNameController = TextEditingController();
  final _coordinatorPhoneController = TextEditingController();
  final _coordinatorEmailController = TextEditingController();
  final _facultyInchargeController = TextEditingController();
  final _facultyPhoneController = TextEditingController();
  final _facultyEmailController = TextEditingController();
  final _eventNameController = TextEditingController();
  final _audienceController = TextEditingController();
  final _seatingController = TextEditingController();
  final _foodInformedByController = TextEditingController();
  final _seatingAdditionalInfoController = TextEditingController();

  String? _selectedClubOrLot;
  String? _customClubOrLot;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  String? _selectedVenueId;
  String? _selectedVenueName;
  bool _foodInformed = false;
  bool _accommodationInformed = false;
  bool _seatingArrangementNeeded = false;

  final List<String> _clubsAndLots = [
    'Leadography', 'Placement', 'OBT', 'Event Lot', 'IEDC Lot', 'JCI', 'ROTARACT',
  ];

  final Map<String, int> _selectedQuantities = {};
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _coordinatorNameController.dispose();
    _coordinatorPhoneController.dispose();
    _coordinatorEmailController.dispose();
    _facultyInchargeController.dispose();
    _facultyPhoneController.dispose();
    _facultyEmailController.dispose();
    _eventNameController.dispose();
    _audienceController.dispose();
    _seatingController.dispose();
    _foodInformedByController.dispose();
    _seatingAdditionalInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionCard([
                  _buildSectionTitle('Event Details'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _eventNameController,
                    decoration: const InputDecoration(labelText: 'Event Name', prefixIcon: Icon(Icons.title)),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => value!.isEmpty ? 'Please enter event name' : null,
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('venues').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const CircularProgressIndicator();
                      final venues = snapshot.data!.docs;
                      return DropdownButtonFormField<String>(
                        value: _selectedVenueId,
                        decoration: const InputDecoration(labelText: 'Venue', prefixIcon: Icon(Icons.place_outlined)),
                        items: venues.map<DropdownMenuItem<String>>((venue) {
                          final data = venue.data() as Map<String, dynamic>;
                          return DropdownMenuItem<String>(
                            value: venue.id,
                            child: Text(
                              '${data['name']} (${data['location'] ?? ''})',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedVenueId = value;
                            if (value != null) {
                              final venueData = venues.firstWhere((v) => v.id == value).data() as Map<String, dynamic>;
                              _selectedVenueName = venueData['name'] as String;
                            }
                          });
                        },
                        validator: (value) => value == null ? 'Please select a venue' : null,
                        isExpanded: true,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _audienceController,
                    decoration: const InputDecoration(labelText: 'Audience Participating', prefixIcon: Icon(Icons.people_outline)),
                    keyboardType: TextInputType.text,
                    validator: (value) => value!.isEmpty ? 'Please enter audience details' : null,
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSectionCard([
                  _buildSectionTitle('Date & Time'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(8),
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Event Date', prefixIcon: Icon(Icons.calendar_today)),
                            child: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _pickTime(isStart: true),
                          borderRadius: BorderRadius.circular(8),
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Start Time', prefixIcon: Icon(Icons.access_time)),
                            child: Text(_startTime.format(context)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _pickTime(isStart: false),
                          borderRadius: BorderRadius.circular(8),
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'End Time', prefixIcon: Icon(Icons.access_time)),
                            child: Text(_endTime.format(context)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSectionCard([
                  _buildSectionTitle('Coordinator Information'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _coordinatorNameController,
                    decoration: const InputDecoration(labelText: 'Program Coordinator', prefixIcon: Icon(Icons.person_outline)),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => value!.isEmpty ? 'Please enter coordinator name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _coordinatorEmailController,
                    decoration: const InputDecoration(labelText: 'Coordinator Email', prefixIcon: Icon(Icons.email)),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value!.isEmpty ? 'Please enter coordinator email' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _coordinatorPhoneController,
                    decoration: const InputDecoration(labelText: 'Coordinator Mobile', prefixIcon: Icon(Icons.phone)),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? 'Please enter coordinator phone' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedClubOrLot,
                    decoration: const InputDecoration(labelText: 'Club or Lot', prefixIcon: Icon(Icons.group_outlined)),
                    items: [
                      ..._clubsAndLots.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                      const DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) => setState(() {
                      _selectedClubOrLot = value;
                      if (value != 'Other') _customClubOrLot = null;
                    }),
                    validator: (value) => value == null ? 'Please select a club/lot' : null,
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _selectedClubOrLot == 'Other'
                        ? Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: TextFormField(
                              decoration: const InputDecoration(labelText: 'Enter Club or Lot'),
                              onChanged: (val) => _customClubOrLot = val,
                              validator: (val) => _selectedClubOrLot == 'Other' && (val == null || val.isEmpty) ? 'Please enter a club or lot' : null,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSectionCard([
                  _buildSectionTitle('Faculty Information'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _facultyInchargeController,
                    decoration: const InputDecoration(labelText: 'Faculty Incharge', prefixIcon: Icon(Icons.person_outline)),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => value!.isEmpty ? 'Please enter faculty incharge name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _facultyPhoneController,
                    decoration: const InputDecoration(labelText: 'Faculty Phone Number', prefixIcon: Icon(Icons.phone)),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? 'Please enter faculty phone number' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _facultyEmailController,
                    decoration: const InputDecoration(labelText: 'Faculty Email', prefixIcon: Icon(Icons.email)),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter faculty email' : !value.contains('@') ? 'Please enter a valid email' : null,
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSectionCard([
                  _buildSectionTitle('Equipment'),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('equipment').where('isEnabled', isEqualTo: true).orderBy('name').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) return const Text('No equipment available.');
                      final equipment = docs.map((doc) => Equipment.fromFirestore(doc)).toList();
                      return Column(
                        children: equipment.map((item) {
                          final available = item.availableQuantity;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(item.name)),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline),
                                      onPressed: _selectedQuantities[item.id] != null && _selectedQuantities[item.id]! > 0
                                          ? () => setState(() => _selectedQuantities[item.id] = (_selectedQuantities[item.id] ?? 0) - 1)
                                          : null,
                                    ),
                                    Text('${_selectedQuantities[item.id] ?? 0}'),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      onPressed: (_selectedQuantities[item.id] ?? 0) < available
                                          ? () => setState(() => _selectedQuantities[item.id] = (_selectedQuantities[item.id] ?? 0) + 1)
                                          : null,
                                    ),
                                    Text('/ $available'),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSectionCard([
                  _buildSectionTitle('Additional Information'),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: CheckboxListTile(
                      value: _foodInformed,
                      onChanged: (val) => setState(() => _foodInformed = val ?? false),
                      title: const Text('Food arrangement informed'),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _foodInformed
                        ? Padding(
                            padding: const EdgeInsets.only(left: 36.0, bottom: 16.0),
                            child: TextFormField(
                              controller: _foodInformedByController,
                              decoration: const InputDecoration(labelText: 'Name?'),
                              validator: (val) => _foodInformed && (val == null || val.isEmpty) ? 'Please specify who informed' : null,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: CheckboxListTile(
                      value: _seatingArrangementNeeded,
                      onChanged: (val) => setState(() => _seatingArrangementNeeded = val ?? false),
                      title: const Text('Seating arrangement needed'),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _seatingArrangementNeeded
                        ? Padding(
                            padding: const EdgeInsets.only(left: 36.0, bottom: 8.0),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _seatingController,
                                  decoration: const InputDecoration(labelText: 'Number of chairs'),
                                  keyboardType: TextInputType.number,
                                  validator: (val) => _seatingArrangementNeeded && (val == null || val.isEmpty) ? 'Please enter number of chairs' : null,
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _seatingAdditionalInfoController,
                                  decoration: const InputDecoration(labelText: 'Additional seating info (e.g., table, carpet, etc.)'),
                                  validator: (val) => _seatingArrangementNeeded && (val == null || val.isEmpty) ? 'Please enter additional seating info' : null,
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ]),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    child: _isSubmitting
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Submit Request'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primaryColor));
  }

  Future<Map<String, dynamic>> _checkVenueConflict() async {
    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    final events = await FirebaseFirestore.instance
        .collection('events')
        .where('venue', isEqualTo: _selectedVenueName)
        .where('eventDate', isEqualTo: Timestamp.fromDate(_selectedDate))
        .where('status', whereIn: ['pending', 'approved'])
        .get();

    for (final eventDoc in events.docs) {
      final event = Event.fromFirestore(eventDoc);
      final eventTimes = event.eventTime.split(' - ');
      
      // Parse time strings properly
      TimeOfDay eventStart;
      TimeOfDay eventEnd;
      
      try {
        // Handle different time formats
        if (eventTimes[0].contains('AM') || eventTimes[0].contains('PM')) {
          // Format: "9:00 AM" or "2:30 PM"
          final timeStr = eventTimes[0].trim();
          final isPM = timeStr.contains('PM');
          final timeOnly = timeStr.replaceAll(RegExp(r'\s*(AM|PM)'), '');
          final parts = timeOnly.split(':');
          int hour = int.parse(parts[0]);
          int minute = int.parse(parts[1]);
          
          if (isPM && hour != 12) hour += 12;
          if (!isPM && hour == 12) hour = 0;
          
          eventStart = TimeOfDay(hour: hour, minute: minute);
        } else {
          // Format: "09:00" or "14:30"
          final parts = eventTimes[0].split(':');
          eventStart = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
        
        if (eventTimes[1].contains('AM') || eventTimes[1].contains('PM')) {
          final timeStr = eventTimes[1].trim();
          final isPM = timeStr.contains('PM');
          final timeOnly = timeStr.replaceAll(RegExp(r'\s*(AM|PM)'), '');
          final parts = timeOnly.split(':');
          int hour = int.parse(parts[0]);
          int minute = int.parse(parts[1]);
          
          if (isPM && hour != 12) hour += 12;
          if (!isPM && hour == 12) hour = 0;
          
          eventEnd = TimeOfDay(hour: hour, minute: minute);
        } else {
          final parts = eventTimes[1].split(':');
          eventEnd = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
      } catch (e) {
        // If parsing fails, skip this event
        continue;
      }
      
      final eventStartDateTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, eventStart.hour, eventStart.minute);
      final eventEndDateTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, eventEnd.hour, eventEnd.minute);

      if ((startDateTime.isBefore(eventEndDateTime) && endDateTime.isAfter(eventStartDateTime)) ||
          (startDateTime.isAtSameMomentAs(eventStartDateTime))) {
        return {
          'hasConflict': true,
          'conflictingEvent': event,
          'eventStart': eventStart,
          'eventEnd': eventEnd,
        };
      }
    }
    return {'hasConflict': false};
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final startDateTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _startTime.hour, _startTime.minute);
    final endDateTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _endTime.hour, _endTime.minute);

    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End time must be after start time.')));
      return;
    }

    final conflictResult = await _checkVenueConflict();
    if (conflictResult['hasConflict']) {
      final conflictingEvent = conflictResult['conflictingEvent'] as Event;
      final eventStart = conflictResult['eventStart'] as TimeOfDay;
      final eventEnd = conflictResult['eventEnd'] as TimeOfDay;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Venue Conflict'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This venue is already booked for the selected time.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conflicting Event: ${conflictingEvent.eventName}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('Date: ${conflictingEvent.eventDate.day}/${conflictingEvent.eventDate.month}/${conflictingEvent.eventDate.year}'),
                    Text('Time: ${eventStart.format(context)} - ${eventEnd.format(context)}'),
                    Text('Organizer: ${conflictingEvent.studentName}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please select a different time or venue.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final selectedItems = <String>[];
    final equipmentDocs = await FirebaseFirestore.instance.collection('equipment').get();
    for (final entry in _selectedQuantities.entries) {
      if (entry.value > 0) {
        final doc = equipmentDocs.docs.firstWhere((doc) => doc.id == entry.key);
        final name = doc['name'] as String;
        for (int i = 0; i < entry.value; i++) {
          selectedItems.add(name);
        }
        // Update equipment availability
        final currentAvailable = doc['availableQuantity'] as int;
        await doc.reference.update({'availableQuantity': currentAvailable - entry.value});
      }
    }

    final newEvent = Event(
      id: FirebaseFirestore.instance.collection('events').doc().id,
      eventName: _eventNameController.text,
      studentName: _coordinatorNameController.text,
      studentNumber: _coordinatorPhoneController.text,
      studentEmail: _coordinatorEmailController.text,
      clubOrLot: _selectedClubOrLot == 'Other' ? (_customClubOrLot ?? '') : _selectedClubOrLot!,
      facultyIncharge: _facultyInchargeController.text,
      facultyPhone: _facultyPhoneController.text,
      facultyEmail: _facultyEmailController.text,
      audienceParticipating: _audienceController.text,
      eventDate: _selectedDate,
      eventTime: '${_startTime.format(context)} - ${_endTime.format(context)}',
      venue: _selectedVenueName!,
      selectedItems: selectedItems,
      foodInformed: _foodInformed,
      seatingArrangements: _seatingArrangementNeeded ? int.tryParse(_seatingController.text) ?? 0 : 0,
      accommodationInformed: _accommodationInformed,
      status: 'pending',
      createdAt: DateTime.now(),
      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
    );

    try {
      final eventMap = {
        'eventName': newEvent.eventName,
        'studentName': newEvent.studentName,
        'studentNumber': newEvent.studentNumber,
        'studentEmail': newEvent.studentEmail,
        'clubOrLot': newEvent.clubOrLot,
        'facultyIncharge': newEvent.facultyIncharge,
        'facultyPhone': newEvent.facultyPhone,
        'facultyEmail': newEvent.facultyEmail,
        'audienceParticipating': newEvent.audienceParticipating,
        'eventDate': Timestamp.fromDate(newEvent.eventDate),
        'eventTime': newEvent.eventTime,
        'venue': newEvent.venue,
        'selectedItems': newEvent.selectedItems,
        'foodInformed': newEvent.foodInformed,
        'seatingArrangements': newEvent.seatingArrangements,
        'accommodationInformed': newEvent.accommodationInformed,
        'status': newEvent.status,
        'createdAt': Timestamp.fromDate(newEvent.createdAt),
        'userId': newEvent.userId,
      };

      await FirebaseFirestore.instance.collection('events').doc(newEvent.id).set(eventMap);
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': 'admin',
        'title': 'New Event Request',
        'message': 'A new event "${newEvent.eventName}" has been requested by ${newEvent.studentName}.',
        'createdAt': Timestamp.now(),
        'read': false,
      });

      setState(() => _isSubmitting = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your event request has been submitted!')));
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success!'),
            content: const Text('Your event request has been submitted.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.of(context).popUntil((route) => route.isFirst); // Go to home page
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit event: $e')));
      }
    }
  }

  void _pickDate() async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isAfter(tomorrow) ? _selectedDate : tomorrow,
      firstDate: tomorrow,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }
}