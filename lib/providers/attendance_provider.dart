// ignore_for_file: unused_import

import 'package:flutter/foundation.dart';
import '../core/services/firebase_service.dart';
import '../models/attendance_model.dart';
import '../models/employee_model.dart';

class AttendanceProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService.instance;
  
  List<AttendanceModel> _attendanceRecords = [];
  AttendanceModel? _todayAttendance;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<AttendanceModel> get attendanceRecords => _attendanceRecords;
  AttendanceModel? get todayAttendance => _todayAttendance;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load attendance records for an employee
  Future<void> loadEmployeeAttendance(
    String employeeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      _attendanceRecords = await _firebaseService.getEmployeeAttendance(
        employeeId,
        startDate: startDate,
        endDate: endDate,
      );
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load attendance: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load today's attendance for an employee
  Future<void> loadTodayAttendance(String employeeId) async {
    try {
      _clearError();
      
      _todayAttendance = await _firebaseService.getTodayAttendance(employeeId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load today\'s attendance: $e');
    }
  }

  // Check in employee
  Future<bool> checkIn({
    required String employeeId,
    required String employeeCode,
    required bool verifiedByFace,
    required double confidence,
    Map<String, double>? location,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Check if already checked in today
      final existingAttendance = await _firebaseService.getTodayAttendance(employeeId);
      if (existingAttendance != null && existingAttendance.checkIn != null) {
        _setError('Already checked in today');
        return false;
      }

      final attendance = AttendanceModel(
        id: '', // Will be set by Firestore
        employeeId: employeeId,
        employeeCode: employeeCode,
        date: todayStr,
        checkIn: today,
        checkOut: null,
        breakStart: null,
        breakEnd: null,
        workedHours: 0.0,
        overtimeHours: 0.0,
        verifiedByFace: verifiedByFace,
        confidence: confidence,
        location: location,
        notes: notes ?? '',
        status: 'present',
      );

      final attendanceId = await _firebaseService.addAttendance(attendance);
      _todayAttendance = attendance.copyWith(id: attendanceId);
      
      // Add to records if we're viewing current employee's records
      if (_attendanceRecords.isNotEmpty && 
          _attendanceRecords.first.employeeId == employeeId) {
        _attendanceRecords.insert(0, _todayAttendance!);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to check in: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check out employee
  Future<bool> checkOut({
    required String employeeId,
    required bool verifiedByFace,
    required double confidence,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final attendance = await _firebaseService.getTodayAttendance(employeeId);
      if (attendance == null || attendance.checkIn == null) {
        _setError('No check-in record found for today');
        return false;
      }

      if (attendance.checkOut != null) {
        _setError('Already checked out today');
        return false;
      }

      final now = DateTime.now();
      final workedHours = now.difference(attendance.checkIn!).inMinutes / 60.0;
      
      // Calculate break time if any
      double breakHours = 0.0;
      if (attendance.breakStart != null && attendance.breakEnd != null) {
        breakHours = attendance.breakEnd!.difference(attendance.breakStart!).inMinutes / 60.0;
      }
      
      final actualWorkedHours = workedHours - breakHours;

      final updatedAttendance = attendance.copyWith(
        checkOut: now,
        workedHours: actualWorkedHours,
        notes: notes ?? attendance.notes,
      );

      await _firebaseService.updateAttendance(updatedAttendance);
      _todayAttendance = updatedAttendance;
      
      // Update in records list
      final index = _attendanceRecords.indexWhere((a) => a.id == attendance.id);
      if (index != -1) {
        _attendanceRecords[index] = updatedAttendance;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to check out: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Start break
  Future<bool> startBreak(String employeeId) async {
    try {
      _setLoading(true);
      _clearError();

      final attendance = await _firebaseService.getTodayAttendance(employeeId);
      if (attendance == null || attendance.checkIn == null) {
        _setError('No check-in record found for today');
        return false;
      }

      if (attendance.breakStart != null) {
        _setError('Break already started');
        return false;
      }

      final updatedAttendance = attendance.copyWith(
        breakStart: DateTime.now(),
      );

      await _firebaseService.updateAttendance(updatedAttendance);
      _todayAttendance = updatedAttendance;
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to start break: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // End break
  Future<bool> endBreak(String employeeId) async {
    try {
      _setLoading(true);
      _clearError();

      final attendance = await _firebaseService.getTodayAttendance(employeeId);
      if (attendance == null || attendance.breakStart == null) {
        _setError('No break started');
        return false;
      }

      if (attendance.breakEnd != null) {
        _setError('Break already ended');
        return false;
      }

      final updatedAttendance = attendance.copyWith(
        breakEnd: DateTime.now(),
      );

      await _firebaseService.updateAttendance(updatedAttendance);
      _todayAttendance = updatedAttendance;
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to end break: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get attendance statistics
  Map<String, dynamic> getAttendanceStats() {
    if (_attendanceRecords.isEmpty) {
      return {
        'totalDays': 0,
        'presentDays': 0,
        'absentDays': 0,
        'lateDays': 0,
        'totalHours': 0.0,
        'averageHours': 0.0,
        'attendanceRate': 0.0,
      };
    }

    final totalDays = _attendanceRecords.length;
    final presentDays = _attendanceRecords.where((a) => a.status == 'present').length;
    final absentDays = _attendanceRecords.where((a) => a.status == 'absent').length;
    final lateDays = _attendanceRecords.where((a) => a.status == 'late').length;
    final totalHours = _attendanceRecords.fold<double>(0.0, (sum, a) => sum + a.workedHours);
    final averageHours = totalHours / totalDays;
    final attendanceRate = (presentDays / totalDays) * 100;

    return {
      'totalDays': totalDays,
      'presentDays': presentDays,
      'absentDays': absentDays,
      'lateDays': lateDays,
      'totalHours': totalHours,
      'averageHours': averageHours,
      'attendanceRate': attendanceRate,
    };
  }

  // Get monthly attendance
  List<AttendanceModel> getMonthlyAttendance(int year, int month) {
    return _attendanceRecords.where((attendance) {
      final dateParts = attendance.date.split('-');
      if (dateParts.length != 3) return false;
      
      final attendanceYear = int.tryParse(dateParts[0]);
      final attendanceMonth = int.tryParse(dateParts[1]);
      
      return attendanceYear == year && attendanceMonth == month;
    }).toList();
  }

  // Clear all data
  void clearAll() {
    _attendanceRecords.clear();
    _todayAttendance = null;
    _clearError();
    notifyListeners();
  }

  // Refresh data
  Future<void> refresh(String employeeId) async {
    await Future.wait([
      loadEmployeeAttendance(employeeId),
      loadTodayAttendance(employeeId),
    ]);
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

}
