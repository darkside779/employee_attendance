import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../constants/firebase_constants.dart';
import '../../models/user_model.dart';
import '../../models/employee_model.dart';
import '../../models/attendance_model.dart';
import '../../models/salary_report_model.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance {
    _instance ??= FirebaseService._internal();
    return _instance!;
  }
  
  FirebaseService._internal();
  
  bool get isInitialized {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  // Firebase instances - with null safety and fallback behavior
  FirebaseAuth get auth {
    if (!isInitialized) {
      throw Exception('Firebase not initialized - cannot access Auth');
    }
    return FirebaseAuth.instance;
  }
  
  FirebaseFirestore get firestore {
    if (!isInitialized) {
      throw Exception('Firebase not initialized - cannot access Firestore');
    }
    return FirebaseFirestore.instance;
  }
  
  FirebaseStorage get storage {
    if (!isInitialized) {
      throw Exception('Firebase not initialized - cannot access Storage');
    }
    return FirebaseStorage.instance;
  }
  
  FirebaseMessaging get messaging {
    if (!isInitialized) {
      throw Exception('Firebase not initialized - cannot access Messaging');
    }
    return FirebaseMessaging.instance;
  }

  // Current user
  User? get currentUser {
    try {
      return isInitialized ? auth.currentUser : null;
    } catch (e) {
      return null;
    }
  }
  Stream<User?> get authStateChanges {
    try {
      return auth.authStateChanges();
    } catch (e) {
      return Stream.value(null);
    }
  }

  // Authentication Methods
  Future<UserCredential?> signInWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Skip last login update for now to avoid Firestore errors
      // if (credential.user != null) {
      //   await updateUserLastLogin(credential.user!.uid);
      // }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    try {
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential?> createUserWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    try {
      return await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // User Management Methods
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      await  firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.id)
          .set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.id)
          .update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> updateUserLastLogin(String userId) async {
    try {
      await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .set({
        FirebaseConstants.userLastLogin: Timestamp.now(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update last login: $e');
    }
  }

  // Employee Management Methods
  Future<List<EmployeeModel>> getAllEmployees() async {
    try {
      // Get all employees first, then filter and sort in code to avoid index requirements
      final querySnapshot = await firestore
          .collection(FirebaseConstants.employeesCollection)
          .get();

      final employees = querySnapshot.docs
          .map((doc) => EmployeeModel.fromFirestore(doc))
          .toList();

      // Sort by full name in code
      employees.sort((a, b) => a.fullName.compareTo(b.fullName));
      
      return employees;
    } catch (e) {
      throw Exception('Failed to get employees: $e');
    }
  }

  Future<EmployeeModel?> getEmployeeById(String employeeId) async {
    try {
      final doc = await firestore
          .collection(FirebaseConstants.employeesCollection)
          .doc(employeeId)
          .get();

      if (doc.exists) {
        return EmployeeModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get employee: $e');
    }
  }

  Future<EmployeeModel?> getEmployeeByCode(String employeeCode) async {
    try {
      final querySnapshot = await firestore
          .collection(FirebaseConstants.employeesCollection)
          .where(FirebaseConstants.employeeCode, isEqualTo: employeeCode)
          .where(FirebaseConstants.employeeIsActive, isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return EmployeeModel.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get employee by code: $e');
    }
  }

  Future<String> addEmployee(EmployeeModel employee) async {
    try {
      final docRef = await firestore
          .collection(FirebaseConstants.employeesCollection)
          .add(employee.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add employee: $e');
    }
  }

  Future<void> updateEmployee(EmployeeModel employee) async {
    try {
      await firestore
          .collection(FirebaseConstants.employeesCollection)
          .doc(employee.id)
          .update(employee.toMap());
    } catch (e) {
      throw Exception('Failed to update employee: $e');
    }
  }

  Future<void> deleteEmployee(String employeeId) async {
    try {
      await firestore
          .collection(FirebaseConstants.employeesCollection)
          .doc(employeeId)
          .update({
        FirebaseConstants.employeeIsActive: false,
        FirebaseConstants.employeeUpdatedAt: Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to delete employee: $e');
    }
  }

  // Attendance Management Methods
  Future<List<AttendanceModel>> getEmployeeAttendance(
    String employeeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = firestore
          .collection(FirebaseConstants.attendanceCollection)
          .where(FirebaseConstants.attendanceEmployeeId, isEqualTo: employeeId)
          .orderBy(FirebaseConstants.attendanceDate, descending: true);

      if (startDate != null) {
        final startDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
        query = query.where(FirebaseConstants.attendanceDate, isGreaterThanOrEqualTo: startDateStr);
      }

      if (endDate != null) {
        final endDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
        query = query.where(FirebaseConstants.attendanceDate, isLessThanOrEqualTo: endDateStr);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get attendance: $e');
    }
  }

  Future<AttendanceModel?> getTodayAttendance(String employeeId) async {
    try {
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final querySnapshot = await firestore
          .collection(FirebaseConstants.attendanceCollection)
          .where(FirebaseConstants.attendanceEmployeeId, isEqualTo: employeeId)
          .where(FirebaseConstants.attendanceDate, isEqualTo: todayStr)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return AttendanceModel.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get today attendance: $e');
    }
  }

  Future<String> addAttendance(AttendanceModel attendance) async {
    try {
      final docRef = await firestore
          .collection(FirebaseConstants.attendanceCollection)
          .add(attendance.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add attendance: $e');
    }
  }

  Future<void> updateAttendance(AttendanceModel attendance) async {
    try {
      await firestore
          .collection(FirebaseConstants.attendanceCollection)
          .doc(attendance.id)
          .update(attendance.toMap());
    } catch (e) {
      throw Exception('Failed to update attendance: $e');
    }
  }

  // Salary Report Methods
  Future<List<SalaryReportModel>> getSalaryReports({
    String? employeeId,
    String? month,
    int? year,
  }) async {
    try {
      Query query = firestore
          .collection(FirebaseConstants.salaryReportsCollection)
          .orderBy(FirebaseConstants.salaryCreatedAt, descending: true);

      if (employeeId != null) {
        query = query.where(FirebaseConstants.salaryEmployeeId, isEqualTo: employeeId);
      }

      if (month != null) {
        query = query.where(FirebaseConstants.salaryMonth, isEqualTo: month);
      }

      if (year != null) {
        query = query.where(FirebaseConstants.salaryYear, isEqualTo: year);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => SalaryReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get salary reports: $e');
    }
  }

  Future<String> addSalaryReport(SalaryReportModel report) async {
    try {
      final docRef = await firestore
          .collection(FirebaseConstants.salaryReportsCollection)
          .add(report.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add salary report: $e');
    }
  }

  Future<void> updateSalaryReport(SalaryReportModel report) async {
    try {
      await firestore
          .collection(FirebaseConstants.salaryReportsCollection)
          .doc(report.id)
          .update(report.toMap());
    } catch (e) {
      throw Exception('Failed to update salary report: $e');
    }
  }

  // Storage Methods
  Future<String> uploadEmployeeImage(String employeeId, String filePath) async {
    try {
      final ref = storage
          .ref()
          .child(FirebaseConstants.employeeImagesPath)
          .child('$employeeId.jpg');

      final uploadTask = await ref.putFile(File(filePath));
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> deleteEmployeeImage(String imageUrl) async {
    try {
      final ref = storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  // Messaging Methods
  Future<String?> getFCMToken() async {
    try {
      return await messaging.getToken();
    } catch (e) {
      throw Exception('Failed to get FCM token: $e');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await messaging.subscribeToTopic(topic);
    } catch (e) {
      throw Exception('Failed to subscribe to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await messaging.unsubscribeFromTopic(topic);
    } catch (e) {
      throw Exception('Failed to unsubscribe from topic: $e');
    }
  }

  // Error Handling
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return e.message ?? 'An error occurred during authentication.';
    }
  }
}
