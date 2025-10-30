# Event Manager 📅

[![Flutter](https://img.shields.io/badge/Flutter-3.7.2-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-lightgrey.svg)](https://flutter.dev/)

A comprehensive, cross-platform Flutter application for managing events, venues, and equipment bookings. Built with Firebase for real-time data synchronization, authentication, and cloud storage. Features role-based access for users and administrators, automatic conflict prevention, and background processing for seamless event management.

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

Booking()`: User cancellation


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


