# ClubVerse - Your College's Universe of Clubs

ClubVerse is a comprehensive Flutter web and Android application that connects colleges, clubs, and students through a unified platform. Built with Firebase backend, it provides role-based dashboards, real-time chat, event management, and seamless club discovery.

## 🌟 Features

### Core Functionality
- **Role-Based Authentication**: Super Admin, College Admin, Club Admin, and Student roles
- **Cross-Platform**: Flutter web and Android support
- **Real-Time Chat**: Club-specific chat rooms with live messaging
- **Event Management**: Create, manage, and discover events
- **Image Upload**: Profile, background, and event images via Firebase Storage
- **Responsive Design**: Optimized for mobile, tablet, and desktop

### User Roles & Permissions

#### 🔑 Super Admin
- Create and manage colleges
- Create College Admin accounts
- View all users across the platform
- Full system oversight and control

#### 🏫 College Admin
- Manage their college's profile and information
- Create and manage clubs within their college
- Create Club Admin accounts
- View and manage students from their college

#### 👥 Club Admin
- Manage their club's profile and information
- Create and manage events
- Manage club members
- Moderate club chat rooms

#### 🎓 Student
- Browse all clubs across colleges
- Join clubs from their own college only
- View events from all clubs
- Participate in chat rooms of joined clubs
- Manage personal profile

## 🏗️ Architecture

### Frontend (Flutter)
```
lib/
├── auth/                 # Authentication services
├── models/              # Data models (User, College, Club, Event, Chat)
├── providers/           # State management (Provider pattern)
├── screens/             # UI screens for all user roles
├── services/            # Business logic and API calls
├── widgets/             # Reusable UI components
└── main.dart           # App entry point
```

### Backend (Firebase)
- **Authentication**: Firebase Auth with role-based access
- **Database**: Cloud Firestore with real-time synchronization
- **Storage**: Firebase Storage for images
- **Security**: Comprehensive Firestore and Storage rules

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Firebase project setup
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd uniclub
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication (Email/Password)
   - Enable Cloud Firestore
   - Enable Firebase Storage
   - Download and replace `firebase_options.dart` with your project configuration

4. **Configure Firebase**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Initialize Firebase in your project
   firebase init
   ```

5. **Deploy Security Rules**
   ```bash
   # Deploy Firestore rules
   firebase deploy --only firestore:rules
   
   # Deploy Storage rules
   firebase deploy --only storage
   ```

6. **Run the application**
   ```bash
   # For web
   flutter run -d chrome
   
   # For Android
   flutter run
   ```

## 🔧 Configuration

### Firebase Configuration
Update `lib/firebase_options.dart` with your Firebase project credentials:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'your-api-key',
  appId: 'your-app-id',
  messagingSenderId: 'your-sender-id',
  projectId: 'your-project-id',
  authDomain: 'your-project.firebaseapp.com',
  storageBucket: 'your-project.appspot.com',
);
```

### Environment Setup
1. Enable required Firebase services:
   - Authentication (Email/Password)
   - Cloud Firestore
   - Firebase Storage

2. Set up Firestore indexes (auto-generated on first query)

3. Configure authentication settings in Firebase Console

## 📱 Usage

### Initial Setup
1. **Super Admin Access**: Use the hardcoded super admin credentials in the app
2. **Create Colleges**: Add colleges through the Super Admin dashboard
3. **Add College Admins**: Create College Admin accounts for each college
4. **Club Creation**: College Admins can create clubs and Club Admins
5. **Student Registration**: Students can self-register and select their college

### Key Workflows

#### Student Journey
1. Register with email and select college
2. Browse available clubs
3. Join clubs from their college
4. Participate in club chats
5. View and attend events

#### Club Admin Journey
1. Receive login credentials from College Admin
2. Set up club profile and images
3. Create and manage events
4. Manage club members
5. Moderate club chat

#### College Admin Journey
1. Receive login credentials from Super Admin
2. Set up college profile
3. Create and manage clubs
4. Create Club Admin accounts
5. Oversee college's club ecosystem

## 🔒 Security

### Authentication
- Firebase Authentication with email/password
- Role-based access control
- Secure password reset functionality

### Data Security
- Comprehensive Firestore security rules
- Role-based data access restrictions
- Input validation and sanitization

### Storage Security
- File type and size restrictions
- User-specific upload permissions
- Secure image URL generation

## 🎨 UI/UX Features

### Design System
- Material Design 3 components
- Consistent color scheme and typography
- Responsive layouts for all screen sizes
- ClubVerse branding and theming

### User Experience
- Intuitive navigation with bottom tabs
- Pull-to-refresh functionality
- Real-time updates across the app
- Smooth animations and transitions

### Accessibility
- Screen reader support
- High contrast mode compatibility
- Keyboard navigation support
- Semantic UI elements

## 🔄 Real-Time Features

### Chat System
- Club-specific chat rooms
- Real-time message delivery
- Message history and persistence
- User presence indicators

### Live Updates
- Real-time club member updates
- Live event notifications
- Dynamic content refresh
- Instant UI state synchronization

## 📊 Data Models

### User Model
```dart
class UserModel {
  final String uid;
  final String email;
  final UserRole role;
  final String name;
  final String? collegeId;
  final String? clubId;
  final List<String> enrolledClubs;
  final String? profileImageUrl;
  final String? backgroundImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### College Model
```dart
class CollegeModel {
  final String collegeId;
  final String name;
  final String location;
  final String description;
  final String? profileImageUrl;
  final String? backgroundImageUrl;
  final String adminId;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Club Model
```dart
class ClubModel {
  final String clubId;
  final String collegeId;
  final String name;
  final String description;
  final String? profileImageUrl;
  final String? backgroundImageUrl;
  final String adminId;
  final List<String> memberUids;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

## 🚀 Deployment

### Web Deployment
```bash
# Build for web
flutter build web

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

### Android Deployment
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the documentation
- Review Firebase console for backend issues

## 🔮 Future Enhancements

- [ ] Push notifications for events and messages
- [ ] Advanced search and filtering
- [ ] Club categories and tags
- [ ] Event RSVP functionality
- [ ] Student feedback and rating system
- [ ] Analytics dashboard for admins
- [ ] Multi-language support
- [ ] Social media integration

## 📈 Performance

### Optimization Features
- Lazy loading for large lists
- Image caching and optimization
- Efficient state management
- Minimal rebuild strategies
- Network request optimization

### Monitoring
- Firebase Performance Monitoring
- Crashlytics integration
- Analytics tracking
- Error reporting and logging

---

**ClubVerse** - Connecting colleges, clubs, and students in one unified platform. 🎓✨
