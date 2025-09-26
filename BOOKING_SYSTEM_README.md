# Equipment Booking System

A comprehensive Flutter application that allows users to book equipment with specific time slots, featuring automatic availability management and conflict prevention.

## Features

### For Users
- **Book Equipment**: Select equipment, date, and time slots
- **Real-time Availability**: See available equipment and quantities
- **Conflict Prevention**: Automatic detection of overlapping bookings
- **Booking Management**: View, cancel, and track booking status
- **Professional UI**: Modern, user-friendly interface

### For Admins
- **Booking Approval**: Approve or reject booking requests
- **Status Management**: Update booking statuses (pending, confirmed, completed)
- **Equipment Management**: Monitor equipment availability
- **Conflict Resolution**: Handle booking conflicts with rejection reasons

### System Features
- **Automatic Availability**: Equipment automatically becomes unavailable during bookings
- **Time-based Completion**: Bookings automatically complete after end time
- **Background Processing**: Periodic checks for expired bookings
- **Real-time Updates**: Live updates using Firestore streams

## Firestore Data Structure

### Collections

#### 1. `equipment`
```json
{
  "id": "equipment_id",
  "name": "Projector",
  "category": "Audio/Visual",
  "totalQuantity": 5,
  "availableQuantity": 3,
  "isEnabled": true,
  "createdAt": "timestamp",
  "description": "HD Projector for presentations"
}
```

#### 2. `bookings`
```json
{
  "id": "booking_id",
  "userId": "user_uid",
  "userName": "John Doe",
  "userEmail": "john@example.com",
  "eventName": "Team Meeting",
  "eventDescription": "Weekly team meeting",
  "eventDate": "timestamp",
  "startTime": "timestamp",
  "endTime": "timestamp",
  "equipmentIds": ["equipment_id_1", "equipment_id_2"],
  "equipment": [
    {
      "equipmentId": "equipment_id_1",
      "equipmentName": "Projector",
      "quantity": 1,
      "category": "Audio/Visual"
    }
  ],
  "status": "pending", // pending, confirmed, cancelled, completed, rejected
  "createdAt": "timestamp",
  "rejectionReason": "Equipment under maintenance",
  "venue": "Conference Room A"
}
```

## Implementation Details

### 1. Booking Model (`lib/models/booking.dart`)
- Comprehensive booking data structure
- Built-in overlap detection methods
- Status management and time-based properties

### 2. Booking Service (`lib/services/booking_service.dart`)
- **createBooking()**: Creates new bookings with conflict checking
- **updateBookingStatus()**: Updates booking status and equipment availability
- **getUserBookings()**: Stream of user's bookings
- **getAllBookings()**: Stream of all bookings (admin)
- **autoCompleteExpiredBookings()**: Automatic completion of expired bookings

### 3. Background Service (`lib/services/background_service.dart`)
- Periodic checking for expired bookings
- Automatic equipment availability updates
- Runs every 5 minutes in the background

### 4. UI Screens
- **BookEquipmentScreen**: Professional booking interface
- **MyBookingsScreen**: User booking management
- **BookingManagementScreen**: Admin booking management

## Key Functions

### Overlap Detection
```dart
// Check if two bookings overlap
bool overlapsWith(Booking other) {
  // Same date check
  if (eventDate.year != other.eventDate.year ||
      eventDate.month != other.eventDate.month ||
      eventDate.day != other.eventDate.day) {
    return false;
  }
  
  // Time overlap check
  return startTime.isBefore(other.endTime) && endTime.isAfter(other.startTime);
}
```

### Equipment Availability Check
```dart
// Check equipment availability for a time slot
Future<Map<String, dynamic>> _checkEquipmentAvailability({
  required List<BookingEquipment> equipment,
  required DateTime eventDate,
  required DateTime startTime,
  required DateTime endTime,
}) async {
  // Validates equipment existence, quantity, and time conflicts
  // Returns availability status and conflict details
}
```

### Automatic Status Updates
```dart
// Auto-complete expired bookings
static Future<void> autoCompleteExpiredBookings() async {
  final now = DateTime.now();
  final expiredBookings = await _firestore
      .collection('bookings')
      .where('status', isEqualTo: 'confirmed')
      .where('endTime', isLessThan: Timestamp.fromDate(now))
      .get();
  
  // Mark as completed and restore equipment availability
}
```

## Usage Instructions

### For Users

1. **Book Equipment**:
   - Navigate to "Book Equipment" screen
   - Fill in event details (name, description, venue)
   - Select date and time slots
   - Choose equipment and quantities
   - Submit booking

2. **Manage Bookings**:
   - View all bookings in "My Bookings"
   - Cancel pending bookings
   - Track booking status and updates

### For Admins

1. **Review Bookings**:
   - Access "Booking Management" screen
   - Filter by status (All, Pending, Confirmed, Completed)
   - View booking details and user information

2. **Approve/Reject**:
   - Approve pending bookings (equipment becomes unavailable)
   - Reject with reason (equipment remains available)
   - Mark confirmed bookings as completed

3. **Monitor Equipment**:
   - Track equipment availability in real-time
   - View booking conflicts and resolutions

## Setup Instructions

### 1. Dependencies
Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^latest_version
  firebase_auth: ^latest_version
  cloud_firestore: ^latest_version
```

### 2. Firebase Configuration
- Set up Firebase project
- Enable Authentication and Firestore
- Add Firebase configuration files
- Set up Firestore security rules

### 3. Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Equipment rules
    match /equipment/{equipmentId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Booking rules
    match /bookings/{bookingId} {
      allow read: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
  }
}
```

### 4. Initialize Background Service
In `main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  BackgroundService.initialize(); // Start background service
  runApp(const MyApp());
}
```

## Best Practices

### 1. Data Consistency
- Use Firestore transactions for critical operations
- Implement proper error handling and rollback mechanisms
- Validate data before saving to Firestore

### 2. Performance
- Use Firestore streams for real-time updates
- Implement pagination for large datasets
- Optimize queries with proper indexing

### 3. Security
- Implement proper authentication and authorization
- Validate user permissions for admin operations
- Sanitize user inputs to prevent injection attacks

### 4. User Experience
- Provide clear error messages for conflicts
- Show loading states during operations
- Implement offline support where possible

## Troubleshooting

### Common Issues

1. **Booking Conflicts Not Detected**:
   - Ensure Firestore indexes are properly set up
   - Check that time comparisons use the same timezone
   - Verify equipment availability calculations

2. **Background Service Not Working**:
   - Check if the service is properly initialized
   - Verify Firebase configuration
   - Monitor debug logs for errors

3. **Equipment Availability Not Updated**:
   - Check Firestore security rules
   - Verify batch operations are completing
   - Ensure proper error handling in availability updates

### Debug Tips
- Enable Firestore debug logging
- Monitor background service logs
- Use Firestore console to verify data consistency
- Test with different time zones and edge cases

## Future Enhancements

1. **Advanced Features**:
   - Recurring bookings
   - Equipment maintenance scheduling
   - Integration with calendar systems
   - Email notifications

2. **Analytics**:
   - Booking statistics and reports
   - Equipment utilization tracking
   - User behavior analytics

3. **Mobile Features**:
   - Push notifications
   - Offline booking capabilities
   - QR code scanning for equipment

4. **Admin Features**:
   - Bulk booking management
   - Advanced reporting tools
   - Equipment maintenance tracking

This booking system provides a robust foundation for equipment management with automatic availability tracking and conflict prevention, ensuring efficient resource utilization and user satisfaction. 