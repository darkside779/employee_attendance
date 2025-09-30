# Employee Attendance System

A Flutter-based employee attendance system with face recognition capabilities.

## Features

- **Face Recognition Attendance**: Employees can check in/out using face recognition
- **Role-Based Access**: Admin, Accounting, and Employee roles with different permissions
- **Real-time Data**: Firebase Firestore for real-time data synchronization
- **Salary Calculation**: Automatic salary calculation based on attendance
- **Reports & Analytics**: Comprehensive reporting system for attendance and payroll
- **Multi-language Support**: English and Arabic language support

## Architecture

### Tech Stack
- **Frontend**: Flutter with Material Design 3
- **Backend**: Firebase (Firestore, Authentication, Storage, Cloud Messaging)
- **State Management**: Provider pattern
- **Face Recognition**: Google ML Kit + TensorFlow Lite
- **Database**: Cloud Firestore (NoSQL)
- **Storage**: Firebase Cloud Storage

### Project Structure
```
lib/
├── core/                   # Core utilities and services
│   ├── constants/         # App constants (colors, strings, Firebase)
│   ├── services/          # Firebase and face recognition services
│   ├── theme/            # App theming
│   └── utils/            # Validators and formatters
├── models/               # Data models
├── providers/           # State management providers
├── screens/            # UI screens organized by role
│   ├── admin/         # Admin functionality
│   ├── accounting/    # Accounting functionality
│   ├── employee/      # Employee functionality
│   ├── auth/         # Authentication screens
│   └── common/       # Shared screens
├── widgets/          # Reusable UI components
└── routes/          # Navigation and routing
```

## Getting Started

### Prerequisites
- Flutter SDK (>=3.9.2)
- Firebase project
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd employee_attendance
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication, Firestore, and Storage
   - Add your Firebase configuration files:
     - `android/app/google-services.json` (for Android)
     - `web/firebase-config.js` (for Web)

4. **Configure Firestore Rules**
   - Copy the rules from `firebase_config/firestore.rules` to your Firestore Security Rules
   - Copy the rules from `firebase_config/storage.rules` to your Storage Security Rules

5. **Run the app**
   ```bash
   flutter run
   ```

## Firebase Setup Guide

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Follow the setup wizard

### 2. Enable Services
- **Authentication**: Enable Email/Password provider
- **Firestore Database**: Create database in production mode
- **Storage**: Enable Cloud Storage
- **Cloud Messaging**: Enable for notifications (optional)

### 3. Add Firebase to Flutter
```bash
flutter pub add firebase_core firebase_auth cloud_firestore firebase_storage
```

### 4. Configure Platform-specific Settings

#### Android
1. Add `google-services.json` to `android/app/`
2. Update `android/build.gradle` and `android/app/build.gradle`

#### Web
1. Add Firebase SDK scripts to `web/index.html`
2. Initialize Firebase in `web/main.dart`

## User Roles & Permissions

### Admin
- Full system access
- Manage employees (add, edit, delete)
- View all reports and analytics
- System configuration
- User management

### Accounting
- View attendance reports
- Calculate salaries
- Generate payroll reports
- Export data to CSV/PDF

### Employee
- Face recognition check-in/out
- View personal attendance history
- View personal profile (read-only)

## Face Recognition Setup

The app uses Google ML Kit for face detection and custom algorithms for face recognition:

1. **Face Registration**: Admin uploads employee photos
2. **Face Detection**: ML Kit detects faces in real-time
3. **Face Matching**: Custom algorithm compares face embeddings
4. **Attendance Recording**: Successful matches record attendance

### Face Recognition Flow
1. Employee opens attendance screen
2. Camera captures live video feed
3. System detects face using ML Kit
4. Generates face embedding
5. Compares with stored employee faces
6. Records attendance if match found

## Development

### Running Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/
```

### Building for Production
```bash
# Android
flutter build apk --release

# Web
flutter build web --release
```

### Code Style
- Follow Dart/Flutter conventions
- Use meaningful variable names
- Document complex functions
- Use proper error handling

## Demo Accounts

For testing purposes, create these accounts in Firebase Authentication:

- **Admin**: `admin@company.com` / `password`
- **Accounting**: `accounting@company.com` / `password`

## API Documentation

### Firebase Collections

#### Users Collection (`/users/{userId}`)
```json
{
  "role": "admin|accounting",
  "email": "string",
  "name": "string",
  "permissions": ["array"],
  "lastLogin": "timestamp",
  "isActive": "boolean",
  "createdAt": "timestamp",
  "department": "string"
}
```

#### Employees Collection (`/employees/{employeeId}`)
```json
{
  "employeeCode": "string",
  "fullName": "string",
  "email": "string",
  "phone": "string",
  "salary": "number",
  "shiftStart": "timestamp",
  "shiftEnd": "timestamp",
  "imageUrl": "string",
  "faceEmbedding": ["array of numbers"],
  "isActive": "boolean"
}
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, email support@company.com or create an issue in the repository.

## Changelog

### Version 1.0.0
- Initial release
- Face recognition attendance system
- Role-based access control
- Basic reporting functionality

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
