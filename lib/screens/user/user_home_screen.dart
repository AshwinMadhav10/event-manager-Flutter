import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../utils/theme.dart';
import 'add_event_screen.dart';
import 'my_events_screen.dart';
import 'profile_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _selectedIndex = 0;
  List<Event> _userEvents = [];
  String? _userPhone;

  static const List<String> _titles = ['Home', 'Add Event', 'My Events', 'Profile'];
  
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadUserEvents();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          setState(() {
            _userPhone = data['phone'] ?? user.phoneNumber ?? 'Not provided';
          });
        } else {
          setState(() {
            _userPhone = user.phoneNumber ?? 'Not provided';
          });
        }
      } catch (e) {
        // Handle any errors gracefully
        setState(() {
          _userPhone = user.phoneNumber ?? 'Not provided';
        });
      }
    }
  }

  Future<void> _loadUserEvents() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final eventsSnapshot = await FirebaseFirestore.instance
            .collection('events')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();

        if (mounted) {
          setState(() {
            _userEvents = eventsSnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
          });
        }
      }
    } catch (e) {
      // Handle error silently
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
      stream: Rx.combineLatest2(
        FirebaseFirestore.instance
            .collection('events')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        (QuerySnapshot events, QuerySnapshot notifications) => [events, notifications],
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_titles[_selectedIndex]),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
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
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle_outlined),
                  activeIcon: Icon(Icons.add_circle),
                  label: 'Add Event',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.event_note_outlined),
                  activeIcon: Icon(Icons.event_note),
                  label: 'My Events',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
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

        final notifSnapshot = snapshot.data![1] as QuerySnapshot;

        final notifications = notifSnapshot.docs;
        final unreadCount = notifications.where((n) => !(n['read'] ?? false)).length;

        return Scaffold(
          appBar: AppBar(
            title: Text(_titles[_selectedIndex]),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            actions: [
              if (_selectedIndex == 0)
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none),
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Row(
                              children: [
                                const Icon(Icons.notifications, color: AppTheme.primaryColor),
                                const SizedBox(width: 8),
                                const Text('Notifications'),
                                const Spacer(),
                                if (unreadCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$unreadCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            content: SizedBox(
                              width: 400,
                              height: 400,
                              child: notifications.isEmpty
                                  ? const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                                          SizedBox(height: 16),
                                          Text('No notifications yet', style: TextStyle(fontSize: 16, color: Colors.grey)),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: notifications.length,
                                      itemBuilder: (context, index) {
                                        final notification = notifications[index];
                                        final isRead = notification['read'] ?? false;
                                        return Card(
                                          elevation: isRead ? 1 : 3,
                                          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(12),
                                            onTap: () async {
                                              if (!isRead) {
                                                await notification.reference.update({'read': true});
                                              }
                                              if (context.mounted) {
                                                Navigator.pop(context);
                                                setState(() => _selectedIndex = 1);
                                              }
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: isRead ? Colors.grey.shade200 : AppTheme.primaryColor.withAlpha(25),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Icon(
                                                      Icons.notifications,
                                                      color: isRead ? Colors.grey : AppTheme.primaryColor,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          notification['title'] ?? 'No Title',
                                                          style: TextStyle(
                                                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                                            fontSize: 14,
                                                            color: isRead ? Colors.grey.shade700 : Colors.black87,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          notification['message'] ?? '',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey.shade600,
                                                            height: 1.3,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        const SizedBox(height: 6),
                                                        Text(
                                                          _formatNotificationTime(notification['createdAt']),
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.grey.shade500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (!isRead)
                                                    Container(
                                                      width: 8,
                                                      height: 8,
                                                      decoration: const BoxDecoration(
                                                        color: Colors.red,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                              if (unreadCount > 0)
                                TextButton(
                                  onPressed: () async {
                                    for (final n in notifications.where((n) => !(n['read'] ?? false))) {
                                      await n.reference.update({'read': true});
                                    }
                                    if (context.mounted) Navigator.pop(context);
                                  },
                                  child: const Text('Mark All Read'),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              _buildHomeTab(),
              const AddEventScreen(),
              MyEventsScreen(statusFilter: 'pending'),
              _buildProfileTab(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outlined),
                activeIcon: Icon(Icons.add_circle),
                label: 'Add Event',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event_note_outlined),
                activeIcon: Icon(Icons.event_note),
                label: 'My Events',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHomeTab() {
    final pendingEvents = _userEvents.where((e) => e.status == 'pending').length;
    final approvedEvents = _userEvents.where((e) => e.status == 'approved').length;

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
                colors: [AppTheme.primaryColor, AppTheme.primaryColor.withAlpha(128)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withAlpha(64),
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
                    'Welcome User!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ready to create your next event?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text('Your Event Stats', style: Theme.of(context).textTheme.titleLarge),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyEventsScreen(statusFilter: 'pending')),
                    );
                  },
                  child: _buildStatCard('Pending', pendingEvents.toString(), Icons.pending_actions, AppTheme.warningColor.withAlpha(25)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyEventsScreen(statusFilter: 'approved')),
                    );
                  },
                  child: _buildStatCard('Approved', approvedEvents.toString(), Icons.check_circle, AppTheme.successColor.withAlpha(25)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text('Recent Events', style: Theme.of(context).textTheme.titleLarge),
          const Divider(height: 24),
          if (_userEvents.isEmpty)
            Column(
              children: [
                const SizedBox(height: 32),
                Icon(Icons.event_busy, size: 64, color: AppTheme.textTertiary),
                const SizedBox(height: 16),
                Text('No events yet.', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                Text('Create your first event to get started!', style: Theme.of(context).textTheme.bodyMedium),
              ],
            )
          else
            ..._userEvents.take(3).map((event) => _buildEventCard(event)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(event.status),
          child: Icon(Icons.event_note, color: Colors.white),
        ),
        title: Text(event.eventName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year}'),
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
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppTheme.warningColor.withAlpha(25);
      case 'approved':
        return AppTheme.successColor.withAlpha(25);
      case 'rejected':
        return AppTheme.errorColor.withAlpha(25);
      default:
        return AppTheme.textTertiary.withAlpha(25);
    }
  }

  Widget _buildProfileTab() {
    final user = FirebaseAuth.instance.currentUser;
    final approvedEvents = _userEvents.where((e) => e.status == 'approved').length;

    return ProfileCard(
      name: user?.displayName ?? 'User',
      role: 'Student',
      email: user?.email ?? '',
      phone: _userPhone ?? 'Not provided',
      stat1: _userEvents.length,
      stat1Label: 'Total Events',
      stat2: approvedEvents,
      stat2Label: 'Approved',
      onEdit: () => _showEditProfileDialog(),
      onMyEventsTap: () {
        setState(() {
          _selectedIndex = 2; // Navigate to My Events tab
        });
      },
      isAdmin: false,
    );
  }

  void _showEditProfileDialog() {
    final user = FirebaseAuth.instance.currentUser;
    final nameController = TextEditingController(text: user?.displayName ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final phoneController = TextEditingController(text: _userPhone ?? user?.phoneNumber ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                enabled: false, // Email cannot be changed
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Update user profile
              await user?.updateDisplayName(nameController.text);
              final newPhone = phoneController.text.trim();
              if (!mounted) return;
              setState(() {
                _userPhone = newPhone;
              });
              // Store phone in Firestore
              await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
                'phone': newPhone,
                'name': nameController.text,
                'email': user?.email,
              }, SetOptions(merge: true));
              if (!mounted) return;
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _formatNotificationTime(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'No time';
    }
    final date = timestamp.toDate().toLocal();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}