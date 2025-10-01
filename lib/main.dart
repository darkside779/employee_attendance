import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/services/face_recognition_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with proper options for all platforms
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    // If Firebase fails, continue without it for development
    debugPrint('Firebase initialization failed: $e');
  }

  // Initialize Face Recognition Service (skip on web as camera access is different)
  if (!kIsWeb) {
    FaceRecognitionService().initialize();
  }

  runApp(const EmployeeAttendanceApp());
}
