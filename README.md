# Event Manager 📅

[![Flutter](https://img.shields.io/badge/Flutter-3.7.2-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-lightgrey.svg)](https://flutter.dev/)

A comprehensive, cross-platform Flutter application for managing events, venues, and equipment bookings. Built with Firebase for real-time data synchronization, authentication, and cloud storage. Features role-based access for users and administrators, automatic conflict prevention, and background processing for seamless event management.

## 📋 Table of Contents

- [✨ Features](#-features)
- [📸 Screenshots](#-screenshots)
- [🛠️ Tech Stack](#️-tech-stack)
- [🏗️ Architecture](#️-architecture)
- [🚀 Installation](#-installation)
- [🔧 Firebase Setup](#-firebase-setup)
- [📖 Usage](#-usage)
- [🗄️ Data Structure](#️-data-structure)
- [🔌 API & Services](#-api--services)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)
- [🙏 Acknowledgments](#-acknowledgments)

## ✨ Features

### 👤 For Users
- **🔐 Secure Authentication**: Login and signup with Firebase Auth
- **📅 Event Management**: Create, view, and manage personal events
- **🏢 Venue Booking**: Browse and book available venues for events
- **🛠️ Equipment Reservation**: Select and book equipment with time slots
- **⏰ Real-time Availability**: Live updates on venue and equipment availability
- **🚫 Conflict Prevention**: Automatic detection and prevention of booking overlaps
- **📊 Booking Tracking**: Monitor booking status (pending, confirmed, completed, rejected)
- **👤 Profile Management**: Update personal information and view booking history
- **📱 Cross-Platform**: Seamless experience on mobile, web, and desktop

### 👨‍💼 For Admins
- **📋 Booking Oversight**: Approve, reject, or manage all bookings
- **🏗️ Venue Management**: Add, edit, and monitor venue availability
- **🛠️ Equipment Control**: Manage equipment inventory and categories
- **📅 Event Supervision**: Oversee all events and user activities
- **📈 Analytics Dashboard**: View system usage and booking statistics
- **⚙️ System Configuration**: Control app settings and user roles
- **🔍 Advanced Filtering**: Filter bookings by status, date, user, etc.
- **📧 Notification Management**: Handle booking requests and updates

### ⚙️ System Features
- **🔄 Real-time Synchronization**: Live updates using Firestore streams
- **⏳ Automatic Completion**: Background service auto-completes expired bookings
- **🔔 Push Notifications**: Real-time alerts for booking status changes
- **🌐 Offline Support**: Basic offline functionality with sync on reconnect
- **🔒 Security**: Role-based access control and data validation
- **📊 Performance Optimized**: Efficient queries and caching mechanisms
- **🎨 Modern UI**: Material Design 3 with custom theming
- **🌍 Multi-platform**: Android, iOS, Web, Linux, macOS, Windows support

## 📸 Screenshots

| Login Screen | User Dashboard | Admin Panel | Booking Interface |
|--------------|----------------|-------------|-------------------|
| ![Login](screenshots/login.png) | ![Dashboard](screenshots/dashboard.png) | ![Admin](screenshots/admin.png) | ![Booking](screenshots/booking.png) |

*Note: Screenshots will be added during development. Place images in `screenshots/` directory.*

## 🛠️ Tech Stack

### Frontend
- **Flutter**: Cross-platform UI framework (SDK ^3.7.2)
- **Dart**: Programming language
- **Material Design 3**: Modern UI components
- **RxDart**: Reactive programming for streams

### Backend & Services
- **Firebase Core**: Platform initialization
- **Firebase Auth**: User authentication
- **Cloud Firestore**: NoSQL database for real-time data
- **Firebase Hosting**: Web deployment (optional)

### Development Tools
- **Flutter Lints**: Code quality and style
- **Analysis Options**: Custom linting rules

### Platform Support
- **Mobile**: Android (API 21+), iOS (12.0+)
- **Web**: Modern browsers with WebAssembly
- **Desktop**: Windows, macOS, Linux

## 🏗️ Architecture

The application follows a clean architecture pattern with separation of concerns:

```
lib/
├── main.dart                 # App entry point & initialization
├── models/                   # Data models (Event, Venue, Equipment, Booking)
├── screens/                  # UI screens (Auth, User, Admin)
│   ├── auth/                 # Authentication screens
│   ├── user/                 # User-facing screens
│   └── admin/                # Admin management screens
├── services/                 # Business logic & external APIs
│   ├── background_service.dart # Auto-completion service
│   └── venue_service.dart    # Venue-related operations
├── utils/                    # Utilities & helpers
│   └── theme.dart            # App theming
└── data/                     # Data layer & app state
    └── app_data.dart         # Global data management
```

### Key Components

- **MVVM Pattern**: Models-Views-ViewModels for clean separation
- **Service Layer**: Centralized business logic
- **Repository Pattern**: Data access abstraction
- **Stream-based State**: Reactive UI updates
- **Dependency Injection**: Modular service management

## 🚀 Installation

### Prerequisites
- **Flutter SDK**: ^3.7.2 ([Installation Guide](https://flutter.dev/docs/get-started/install))
- **Dart SDK**: Included with Flutter
- **Android Studio / Xcode**: For mobile development
- **VS Code**: Recommended IDE with Flutter extensions

### Setup Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/your-username/event-manager.git
   cd event-manager
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Platforms**

   **Android:**
   - Ensure Android SDK is installed
   - Set up Android emulator or connect device

   **iOS (macOS only):**
   - Install Xcode
   - Run `flutter doctor` to check iOS setup

   **Web:**
   - Chrome browser for development
   - Run `flutter config --enable-web`

   **Desktop:**
   - Windows: Visual Studio Build Tools
   - macOS: Xcode Command Line Tools
   - Linux: GTK development libraries

4. **Run the App**
   ```bash
   # For Android
   flutter run

   # For iOS
   flutter run --device-id=<iOS_device_id>

   # For Web
   flutter run -d chrome

   # For Desktop (Windows)
   flutter run -d windows
   ```

5. **Build for Production**
   ```bash
   # Android APK
   flutter build apk --release

   # iOS (requires Apple Developer account)
   flutter build ios --release

   # Web
   flutter build web --release
   ```

## 🔧 Firebase Setup

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or select existing
3. Enable Authentication and Firestore

### 2. Authentication Setup
1. Navigate to Authentication > Sign-in method
2. Enable Email/Password provider
3. Configure additional providers if needed

### 3. Firestore Database
1. Go to Firestore Database
2. Create database in production mode
3. Set up security rules (see below)

### 4. Platform Configuration

**Android:**
- Download `google-services.json`
- Place in `android/app/`

**iOS:**
- Download `GoogleService-Info.plist`
- Place in `ios/Runner/`

**Web:**
- Copy Firebase config from project settings
- Add to `web/index.html`

### 5. Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Events collection
    match /events/{eventId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == resource.data.userId;
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }

    // Venues collection
    match /venues/{venueId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Equipment collection
    match /equipment/{equipmentId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Bookings collection
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

### 6. Firestore Indexes
Required indexes will be automatically created, but you can monitor them in Firebase Console > Firestore > Indexes.

## 📖 Usage

### User Workflow

1. **Authentication**
   - Launch app → Login/Signup screen
   - Enter credentials or create account

2. **Dashboard**
   - View upcoming events and bookings
   - Access quick actions (Add Event, Book Venue, etc.)

3. **Event Management**
   - Tap "Add Event" → Fill details → Save
   - View "My Events" → Edit or delete events

4. **Booking Process**
   - Select "Book Equipment" or "Book Venue"
   - Choose date/time → Select items → Confirm booking
   - Monitor status in "My Bookings"

### Admin Workflow

1. **Access Admin Panel**
   - Login with admin credentials
   - Navigate to admin dashboard

2. **Manage Resources**
   - Add/edit venues and equipment
   - Monitor availability and usage

3. **Handle Bookings**
   - Review pending bookings
   - Approve/reject with reasons
   - Track completion status

### Code Examples

**Creating a Booking:**
```dart
// Example from booking service
Future<String> createBooking({
  required String userId,
  required String eventName,
  required DateTime eventDate,
  required DateTime startTime,
  required DateTime endTime,
  required List<BookingEquipment> equipment,
  String? venue,
}) async {
  // Validate availability
  final availability = await _checkEquipmentAvailability(
    equipment: equipment,
    eventDate: eventDate,
    startTime: startTime,
    endTime: endTime,
  );

  if (!availability['available']) {
    throw Exception('Equipment not available: ${availability['conflicts']}');
  }

  // Create booking document
  final bookingRef = await _firestore.collection('bookings').add({
    'userId': userId,
    'eventName': eventName,
    'eventDate': Timestamp.fromDate(eventDate),
    'startTime': Timestamp.fromDate(startTime),
    'endTime': Timestamp.fromDate(endTime),
    'equipment': equipment.map((e) => e.toMap()).toList(),
    'venue': venue,
    'status': 'pending',
    'createdAt': FieldValue.serverTimestamp(),
  });

  return bookingRef.id;
}
```

**Background Service:**
```dart
// Automatic booking completion
class BackgroundService {
  static void initialize() {
    Timer.periodic(const Duration(minutes: 5), (timer) async {
      await autoCompleteExpiredBookings();
    });
  }

  static Future<void> autoCompleteExpiredBookings() async {
    final now = DateTime.now();
    final expiredBookings = await FirebaseFirestore.instance
        .collection('bookings')
        .where('status', isEqualTo: 'confirmed')
        .where('endTime', isLessThan: Timestamp.fromDate(now))
        .get();

    for (final doc in expiredBookings.docs) {
      await doc.reference.update({
        'status': 'completed',
        // Restore equipment availability logic here
      });
    }
  }
}
```

## 🗄️ Data Structure

### Firestore Collections

#### Users Collection
```json
{
  "uid": "firebase_user_id",
  "email": "user@example.com",
  "name": "John Doe",
  "role": "user", // "user" or "admin"
  "createdAt": "timestamp",
  "phone": "+1234567890",
  "department": "Engineering"
}
```

#### Events Collection
```json
{
  "id": "event_id",
  "userId": "user_uid",
  "title": "Team Meeting",
  "description": "Weekly sync meeting",
  "date": "timestamp",
  "startTime": "timestamp",
  "endTime": "timestamp",
  "venue": "Conference Room A",
  "attendees": 10,
  "status": "active", // "active", "cancelled", "completed"
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### Venues Collection
```json
{
  "id": "venue_id",
  "name": "Conference Room A",
  "capacity": 20,
  "location": "Building 1, Floor 2",
  "amenities": ["Projector", "Whiteboard", "WiFi"],
  "isAvailable": true,
  "createdAt": "timestamp",
  "description": "Modern conference room with AV equipment"
}
```

#### Equipment Collection
```json
{
  "id": "equipment_id",
  "name": "HD Projector",
  "category": "Audio/Visual",
  "totalQuantity": 5,
  "availableQuantity": 3,
  "isEnabled": true,
  "createdAt": "timestamp",
  "description": "4K HD Projector for presentations",
  "specifications": {
    "resolution": "3840x2160",
    "brightness": "3000 lumens"
  }
}
```

#### Bookings Collection
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
      "equipmentName": "HD Projector",
      "quantity": 1,
      "category": "Audio/Visual"
    }
  ],
  "venue": "Conference Room A",
  "status": "pending", // "pending", "confirmed", "cancelled", "completed", "rejected"
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "rejectionReason": "Equipment under maintenance",
  "approvedBy": "admin_uid",
  "approvedAt": "timestamp"
}
```

## 🔌 API & Services

### Core Services

#### BackgroundService
- **Purpose**: Automatic booking management
- **Functions**:
  - `initialize()`: Start periodic checks
  - `autoCompleteExpiredBookings()`: Mark expired bookings as completed
  - `restoreEquipmentAvailability()`: Update equipment quantities

#### VenueService
- **Purpose**: Venue data management
- **Functions**:
  - `getVenues()`: Stream of all venues
  - `addVenue()`: Create new venue
  - `updateVenue()`: Modify venue details
  - `deleteVenue()`: Remove venue

#### BookingService (Inferred)
- **Purpose**: Booking operations
- **Functions**:
  - `createBooking()`: New booking with validation
  - `updateBookingStatus()`: Status changes
  - `getUserBookings()`: User's bookings stream
  - `getAllBookings()`: Admin bookings stream
  - `cancelBooking()`: User cancellation

### Data Models

#### Event Model
```dart
class Event {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String? venue;
  final int attendees;
  final String status;

  Event({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.venue,
    required this.attendees,
    required this.status,
  });

  factory Event.fromMap(Map<String, dynamic> map) => Event(...);
  Map<String, dynamic> toMap() => {...};
}
```

#### Venue Model
```dart
class Venue {
  final String id;
  final String name;
  final int capacity;
  final String location;
  final List<String> amenities;
  final bool isAvailable;
  final String description;

  Venue({
    required this.id,
    required this.name,
    required this.capacity,
    required this.location,
    required this.amenities,
    required this.isAvailable,
    required this.description,
  });

  factory Venue.fromMap(Map<String, dynamic> map) => Venue(...);
  Map<String, dynamic> toMap() => {...};
}
```

#### Equipment Model
```dart
class Equipment {
  final String id;
  final String name;
  final String category;
  final int totalQuantity;
  final int availableQuantity;
  final bool isEnabled;
  final String description;
  final Map<String, dynamic> specifications;

  Equipment({
    required this.id,
    required this.name,
    required this.category,
    required this.totalQuantity,
    required this.availableQuantity,
    required this.isEnabled,
    required this.description,
    required this.specifications,
  });

  factory Equipment.fromMap(Map<String, dynamic> map) => Equipment(...);
  Map<String, dynamic> toMap() => {...};
}
```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the Repository**
   ```bash
   git clone https://github.com/your-username/event-manager.git
   ```

2. **Create Feature Branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

3. **Make Changes**
   - Follow Flutter best practices
   - Add tests for new features
   - Update documentation

4. **Commit Changes**
   ```bash
   git commit -m 'Add amazing feature'
   ```

5. **Push to Branch**
   ```bash
   git push origin feature/amazing-feature
   ```

6. **Open Pull Request**
   - Provide detailed description
   - Reference related issues

### Development Guidelines
- **Code Style**: Follow `flutter_lints` rules
- **Testing**: Add unit and widget tests
- **Documentation**: Update README for new features
- **Commits**: Use conventional commit messages

### Branch Naming
- `feature/` - New features
- `bugfix/` - Bug fixes
- `hotfix/` - Critical fixes
- `docs/` - Documentation updates

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 Event Manager Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 🙏 Acknowledgments

- **Flutter Team**: For the amazing cross-platform framework
- **Firebase Team**: For robust backend services
- **Material Design**: For beautiful UI components
- **Open Source Community**: For inspiration and tools

### Special Thanks
- Contributors and beta testers
- Design inspiration from modern booking systems
- Flutter community for support and resources

---

**Made with ❤️ using Flutter & Firebase**

*For questions or support, please open an issue on GitHub.*
