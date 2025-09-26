import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import 'venue_management_screen.dart';
import 'event_management_screen.dart';
import 'equipment_management_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;
  static const List<String> _titles = ['Dashboard', 'Venues', 'Events', 'Equipment'];

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in. Please log in to continue.')),
      );
    }

    return StreamBuilder<List<dynamic>>(
      stream: Rx.combineLatest3(
        FirebaseFirestore.instance.collection('events').snapshots(),
        FirebaseFirestore.instance.collection('venues').snapshots(),
        FirebaseFirestore.instance.collection('equipment').snapshots(),
        (QuerySnapshot events, QuerySnapshot venues, QuerySnapshot equipment) => [events, venues, equipment],
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_titles[_selectedIndex]),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _logout,
                  tooltip: 'Logout',
                ),
              ],
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.location_on_outlined),
                  activeIcon: Icon(Icons.location_on),
                  label: 'Venues',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.event_outlined),
                  activeIcon: Icon(Icons.event),
                  label: 'Events',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2_outlined),
                  activeIcon: Icon(Icons.inventory_2),
                  label: 'Equipment',
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('An error occurred: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No data available.'));
        }

        final eventsSnapshot = snapshot.data![0] as QuerySnapshot;
        final venuesSnapshot = snapshot.data![1] as QuerySnapshot;
        final equipmentSnapshot = snapshot.data![2] as QuerySnapshot;

        final totalEvents = eventsSnapshot.docs.length;
        final totalVenues = venuesSnapshot.docs.length;
        final totalEquipment = equipmentSnapshot.docs.length;

        final pendingEvents = eventsSnapshot.docs.where((doc) => doc['status'] == 'pending').length;
        final approvedEvents = eventsSnapshot.docs.where((doc) => doc['status'] == 'approved').length;
        final rejectedEvents = eventsSnapshot.docs.where((doc) => doc['status'] == 'rejected').length;

        return Scaffold(
          appBar: AppBar(
            title: Text(_titles[_selectedIndex]),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _logout,
                tooltip: 'Logout',
              ),
            ],
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              _buildDashboardTab(
                totalEvents,
                totalVenues,
                totalEquipment,
                pendingEvents,
                approvedEvents,
                rejectedEvents,
              ),
              const VenueManagementScreen(),
              const EventManagementScreen(),
              const EquipmentManagementScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.location_on_outlined),
                activeIcon: Icon(Icons.location_on),
                label: 'Venues',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event_outlined),
                activeIcon: Icon(Icons.event),
                label: 'Events',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined),
                activeIcon: Icon(Icons.inventory_2),
                label: 'Equipment',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboardTab(
    int totalEvents,
    int totalVenues,
    int totalEquipment,
    int pendingEvents,
    int approvedEvents,
    int rejectedEvents,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.25,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryColor.withAlpha(204)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withAlpha(76),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Dashboard',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your events, venues, and equipment',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text('Overview', style: Theme.of(context).textTheme.titleLarge),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Events', totalEvents.toString(), Icons.event, AppTheme.primaryColor)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Total Venues', totalVenues.toString(), Icons.location_on, AppTheme.accentColor)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Equipment', totalEquipment.toString(), Icons.inventory_2, AppTheme.warningColor)),
            ],
          ),
          const SizedBox(height: 32),
          Text('Event Status', style: Theme.of(context).textTheme.titleLarge),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(child: _buildPendingCard(pendingEvents)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Approved', approvedEvents.toString(), Icons.check_circle, AppTheme.successColor)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Rejected', rejectedEvents.toString(), Icons.cancel, AppTheme.errorColor)),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingCard(int pendingEvents) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // App Bar for Pending Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.warningColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.pending_actions,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pending Events',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$pendingEvents',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content Area
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(Icons.pending_actions, size: 32, color: AppTheme.warningColor),
                const SizedBox(height: 8),
                Text(
                  pendingEvents.toString(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.warningColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Awaiting Review',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to event management screen with pending filter
                    setState(() {
                      _selectedIndex = 2; // Switch to Events tab
                    });
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.warningColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
