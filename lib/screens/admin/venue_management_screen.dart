import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/venue.dart';
import '../../services/venue_service.dart';
import '../../utils/theme.dart';
import 'admin_home_screen.dart';

class VenueManagementScreen extends StatefulWidget {
  const VenueManagementScreen({super.key});

  @override
  State<VenueManagementScreen> createState() => _VenueManagementScreenState();
}

class _VenueManagementScreenState extends State<VenueManagementScreen> {
  @override
  void initState() {
    super.initState();
    _createDefaultVenuesIfNeeded();
  }

  Future<void> _createDefaultVenuesIfNeeded() async {
    try {
      final venuesSnapshot = await FirebaseFirestore.instance.collection('venues').get();
      if (venuesSnapshot.docs.isEmpty) {
        // Create default venues
        final defaultVenues = [
          {
            'name': 'Main Auditorium', 
            'location': 'Block A, Ground Floor', 
            'description': 'Large auditorium with seating for 500 people',
            'capacity': 500,
            'isEnabled': true,
            'amenities': ['Stage', 'Audio System', 'Projector', 'Lighting'],
            'createdAt': Timestamp.now(),
          },
          {
            'name': 'Seminar Hall 1', 
            'location': 'Block B, First Floor', 
            'description': 'Medium-sized seminar hall with seating for 100 people',
            'capacity': 100,
            'isEnabled': true,
            'amenities': ['Projector', 'Whiteboard', 'Audio System'],
            'createdAt': Timestamp.now(),
          },
          {
            'name': 'Conference Room', 
            'location': 'Block C, Second Floor', 
            'description': 'Small conference room with seating for 30 people',
            'capacity': 30,
            'isEnabled': true,
            'amenities': ['TV Screen', 'Whiteboard'],
            'createdAt': Timestamp.now(),
          },
          {
            'name': 'Open Air Amphitheater', 
            'location': 'Central Campus', 
            'description': 'Outdoor venue for large events',
            'capacity': 1000,
            'isEnabled': true,
            'amenities': ['Stage', 'Audio System'],
            'createdAt': Timestamp.now(),
          },
          {
            'name': 'Computer Lab', 
            'location': 'Block D, Ground Floor', 
            'description': 'Computer lab with 50 workstations',
            'capacity': 50,
            'isEnabled': true,
            'amenities': ['Computers', 'Projector', 'Network'],
            'createdAt': Timestamp.now(),
          },
        ];

        for (final venue in defaultVenues) {
          await FirebaseFirestore.instance.collection('venues').add(venue);
        }
      }
    } catch (e) {
      print('Error creating default venues: $e');
    }
  }

  void _showVenueDialog({Venue? venue}) {
    final isEdit = venue != null;
    final nameController = TextEditingController(text: venue?.name ?? '');
    final locationController = TextEditingController(text: venue?.location ?? '');
    final descriptionController = TextEditingController(text: venue?.description ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Venue' : 'Add Venue'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Venue Name',
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
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
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
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              
              final venueData = {
                'name': name,
                'location': locationController.text.trim(),
                'description': descriptionController.text.trim(),
                'capacity': 50, // Default capacity
                'isEnabled': true,
                'amenities': [], // Empty amenities list
                'createdAt': Timestamp.now(),
              };

              if (isEdit) {
                await FirebaseFirestore.instance
                    .collection('venues')
                    .doc(venue.id)
                    .update(venueData);
              } else {
                await FirebaseFirestore.instance
                    .collection('venues')
                    .add(venueData);
              }
              
              Navigator.pop(context);
            },
            child: Text(isEdit ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _deleteVenue(Venue venue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Venue'),
        content: Text('Are you sure you want to delete "${venue.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('venues')
                  .doc(venue.id)
                  .delete();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showAddVenueDialog() {
    _showVenueDialog();
  }

  Future<void> _createSampleVenues() async {
    try {
      final sampleVenues = [
        {
          'name': 'Conference Room A',
          'description': 'Large conference room with projector and audio system',
          'capacity': 50,
          'location': 'Building A, Floor 2',
          'amenities': ['Projector', 'Whiteboard', 'Audio System', 'Video Conferencing'],
          'isEnabled': true,
          'createdAt': Timestamp.now(),
        },
        {
          'name': 'Meeting Room B',
          'description': 'Medium-sized meeting room for small groups',
          'capacity': 15,
          'location': 'Building A, Floor 1',
          'amenities': ['Whiteboard', 'TV Screen'],
          'isEnabled': true,
          'createdAt': Timestamp.now(),
        },
        {
          'name': 'Auditorium',
          'description': 'Large auditorium for major events and presentations',
          'capacity': 200,
          'location': 'Building B, Ground Floor',
          'amenities': ['Stage', 'Professional Audio', 'Lighting System', 'Projector'],
          'isEnabled': true,
          'createdAt': Timestamp.now(),
        },
        {
          'name': 'Seminar Hall',
          'description': 'Academic seminar hall with modern facilities',
          'capacity': 80,
          'location': 'Building C, Floor 1',
          'amenities': ['Projector', 'Microphone', 'Podium'],
          'isEnabled': true,
          'createdAt': Timestamp.now(),
        },
      ];

      for (final venueData in sampleVenues) {
        await VenueService.createVenue(
          name: venueData['name'] as String,
          description: venueData['description'] as String,
          capacity: venueData['capacity'] as int,
          location: venueData['location'] as String,
          amenities: List<String>.from(venueData['amenities'] as List),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample venues created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating sample venues: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('venues').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final venues = snapshot.data!.docs.map((doc) {
            try {
              return Venue.fromFirestore(doc);
            } catch (e) {
              print('Error parsing venue document ${doc.id}: $e');
              return null;
            }
          }).where((venue) => venue != null).cast<Venue>().toList();
          
          if (venues.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 64, color: AppTheme.textTertiary),
                  const SizedBox(height: 16),
                  Text('No venues found.', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text('Add your first venue using the + button.', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: venues.length,
            itemBuilder: (context, index) {
              final venue = venues[index];
              return ListTile(
                title: Text(venue.name),
                subtitle: Text(
                  [venue.location, venue.description].where((e) => e.isNotEmpty).join(' • '),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showVenueDialog(venue: venue),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteVenue(venue),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'venue_fab',
        onPressed: () => _showVenueDialog(),
        child: const Icon(Icons.add),
        tooltip: 'Add Venue',
      ),
    );
  }
} 