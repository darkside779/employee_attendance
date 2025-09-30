import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;
  final String employeeId;
  final String employeeCode;
  final String date; // YYYY-MM-DD format
  final DateTime? checkIn;
  final DateTime? checkOut;
  final DateTime? breakStart;
  final DateTime? breakEnd;
  final double workedHours;
  final double overtimeHours;
  final bool verifiedByFace;
  final double confidence;
  final Map<String, double>? location;
  final String notes;
  final String status; // present, late, absent, half-day

  AttendanceModel({
    required this.id,
    required this.employeeId,
    required this.employeeCode,
    required this.date,
    this.checkIn,
    this.checkOut,
    this.breakStart,
    this.breakEnd,
    required this.workedHours,
    required this.overtimeHours,
    required this.verifiedByFace,
    required this.confidence,
    this.location,
    required this.notes,
    required this.status,
  });

  // Factory constructor to create AttendanceModel from Firestore document
  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AttendanceModel(
      id: doc.id,
      employeeId: data['employeeId'] ?? '',
      employeeCode: data['employeeCode'] ?? '',
      date: data['date'] ?? '',
      checkIn: (data['checkIn'] as Timestamp?)?.toDate(),
      checkOut: (data['checkOut'] as Timestamp?)?.toDate(),
      breakStart: (data['breakStart'] as Timestamp?)?.toDate(),
      breakEnd: (data['breakEnd'] as Timestamp?)?.toDate(),
      workedHours: (data['workedHours'] ?? 0).toDouble(),
      overtimeHours: (data['overtimeHours'] ?? 0).toDouble(),
      verifiedByFace: data['verifiedByFace'] ?? false,
      confidence: (data['confidence'] ?? 0).toDouble(),
      location: data['location'] != null 
          ? Map<String, double>.from(data['location'])
          : null,
      notes: data['notes'] ?? '',
      status: data['status'] ?? 'absent',
    );
  }

  // Factory constructor to create AttendanceModel from Map
  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'] ?? '',
      employeeId: map['employeeId'] ?? '',
      employeeCode: map['employeeCode'] ?? '',
      date: map['date'] ?? '',
      checkIn: map['checkIn'] is Timestamp 
          ? (map['checkIn'] as Timestamp).toDate()
          : map['checkIn'] != null 
              ? DateTime.parse(map['checkIn'])
              : null,
      checkOut: map['checkOut'] is Timestamp 
          ? (map['checkOut'] as Timestamp).toDate()
          : map['checkOut'] != null 
              ? DateTime.parse(map['checkOut'])
              : null,
      breakStart: map['breakStart'] is Timestamp 
          ? (map['breakStart'] as Timestamp).toDate()
          : map['breakStart'] != null 
              ? DateTime.parse(map['breakStart'])
              : null,
      breakEnd: map['breakEnd'] is Timestamp 
          ? (map['breakEnd'] as Timestamp).toDate()
          : map['breakEnd'] != null 
              ? DateTime.parse(map['breakEnd'])
              : null,
      workedHours: (map['workedHours'] ?? 0).toDouble(),
      overtimeHours: (map['overtimeHours'] ?? 0).toDouble(),
      verifiedByFace: map['verifiedByFace'] ?? false,
      confidence: (map['confidence'] ?? 0).toDouble(),
      location: map['location'] != null 
          ? Map<String, double>.from(map['location'])
          : null,
      notes: map['notes'] ?? '',
      status: map['status'] ?? 'absent',
    );
  }

  // Convert AttendanceModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'employeeCode': employeeCode,
      'date': date,
      'checkIn': checkIn != null ? Timestamp.fromDate(checkIn!) : null,
      'checkOut': checkOut != null ? Timestamp.fromDate(checkOut!) : null,
      'breakStart': breakStart != null ? Timestamp.fromDate(breakStart!) : null,
      'breakEnd': breakEnd != null ? Timestamp.fromDate(breakEnd!) : null,
      'workedHours': workedHours,
      'overtimeHours': overtimeHours,
      'verifiedByFace': verifiedByFace,
      'confidence': confidence,
      'location': location,
      'notes': notes,
      'status': status,
    };
  }

  // Convert AttendanceModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeCode': employeeCode,
      'date': date,
      'checkIn': checkIn?.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
      'breakStart': breakStart?.toIso8601String(),
      'breakEnd': breakEnd?.toIso8601String(),
      'workedHours': workedHours,
      'overtimeHours': overtimeHours,
      'verifiedByFace': verifiedByFace,
      'confidence': confidence,
      'location': location,
      'notes': notes,
      'status': status,
    };
  }

  // Create a copy of AttendanceModel with updated fields
  AttendanceModel copyWith({
    String? id,
    String? employeeId,
    String? employeeCode,
    String? date,
    DateTime? checkIn,
    DateTime? checkOut,
    DateTime? breakStart,
    DateTime? breakEnd,
    double? workedHours,
    double? overtimeHours,
    bool? verifiedByFace,
    double? confidence,
    Map<String, double>? location,
    String? notes,
    String? status,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeCode: employeeCode ?? this.employeeCode,
      date: date ?? this.date,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      breakStart: breakStart ?? this.breakStart,
      breakEnd: breakEnd ?? this.breakEnd,
      workedHours: workedHours ?? this.workedHours,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      verifiedByFace: verifiedByFace ?? this.verifiedByFace,
      confidence: confidence ?? this.confidence,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }

  // Check if employee is checked in
  bool get isCheckedIn => checkIn != null && checkOut == null;

  // Check if employee is checked out
  bool get isCheckedOut => checkIn != null && checkOut != null;

  // Check if employee is on break
  bool get isOnBreak => breakStart != null && breakEnd == null;

  // Get total break duration in hours
  double get breakDurationHours {
    if (breakStart != null && breakEnd != null) {
      final duration = breakEnd!.difference(breakStart!);
      return duration.inMinutes / 60.0;
    }
    return 0.0;
  }

  // Get formatted check-in time
  String get checkInFormatted {
    if (checkIn == null) return '--:--';
    return '${checkIn!.hour.toString().padLeft(2, '0')}:${checkIn!.minute.toString().padLeft(2, '0')}';
  }

  // Get formatted check-out time
  String get checkOutFormatted {
    if (checkOut == null) return '--:--';
    return '${checkOut!.hour.toString().padLeft(2, '0')}:${checkOut!.minute.toString().padLeft(2, '0')}';
  }

  // Get formatted worked hours
  String get workedHoursFormatted {
    final hours = workedHours.floor();
    final minutes = ((workedHours - hours) * 60).round();
    return '${hours}h ${minutes}m';
  }

  // Check if attendance is late
  bool isLate(DateTime expectedCheckIn) {
    if (checkIn == null) return false;
    return checkIn!.isAfter(expectedCheckIn);
  }

  // Check if attendance is early checkout
  bool isEarlyCheckout(DateTime expectedCheckOut) {
    if (checkOut == null) return false;
    return checkOut!.isBefore(expectedCheckOut);
  }

  @override
  String toString() {
    return 'AttendanceModel(id: $id, employeeCode: $employeeCode, date: $date, status: $status, workedHours: $workedHours)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is AttendanceModel &&
        other.id == id &&
        other.employeeId == employeeId &&
        other.date == date;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        employeeId.hashCode ^
        date.hashCode;
  }
}
