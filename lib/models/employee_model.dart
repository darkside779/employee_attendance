import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeModel {
  final String id;
  final String employeeCode;
  final String fullName;
  final String email;
  final String phone;
  final int age;
  final String department;
  final String position;
  final double salary;
  final String currency;
  final DateTime shiftStart;
  final DateTime shiftEnd;
  final List<String> workDays;
  final String imageUrl;
  final List<double> faceEmbedding;
  final Map<String, List<double>> faceLandmarks;  // Facial landmarks for precise verification
  final Map<String, double> faceGeometry;         // Face geometric measurements
  final List<String> faceCheckinImages;    // URLs of captured check-in images
  final List<String> faceCheckoutImages;   // URLs of captured check-out images
  final DateTime? lastFaceCapture;         // Last time face image was captured
  final bool isActive;
  final DateTime joinDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  EmployeeModel({
    required this.id,
    required this.employeeCode,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.age,
    required this.department,
    required this.position,
    required this.salary,
    required this.currency,
    required this.shiftStart,
    required this.shiftEnd,
    required this.workDays,
    required this.imageUrl,
    required this.faceEmbedding,
    this.faceLandmarks = const {},
    this.faceGeometry = const {},
    this.faceCheckinImages = const [],
    this.faceCheckoutImages = const [],
    this.lastFaceCapture,
    required this.isActive,
    required this.joinDate,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  // Factory constructor to create EmployeeModel from Firestore document
  factory EmployeeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return EmployeeModel(
      id: doc.id,
      employeeCode: data['employeeCode'] ?? '',
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      age: data['age'] ?? 0,
      department: data['department'] ?? '',
      position: data['position'] ?? '',
      salary: (data['salary'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'USD',
      shiftStart: (data['shiftStart'] as Timestamp?)?.toDate() ?? DateTime.now(),
      shiftEnd: (data['shiftEnd'] as Timestamp?)?.toDate() ?? DateTime.now(),
      workDays: List<String>.from(data['workDays'] ?? []),
      imageUrl: data['imageUrl'] ?? '',
      faceEmbedding: List<double>.from(data['faceEmbedding'] ?? []),
      faceLandmarks: data['faceLandmarks'] != null 
          ? Map<String, List<double>>.from(
              (data['faceLandmarks'] as Map).map((key, value) => 
                MapEntry(key.toString(), List<double>.from(value ?? []))
              )
            )
          : {},
      faceGeometry: data['faceGeometry'] != null 
          ? Map<String, double>.from(data['faceGeometry'])
          : {},
      faceCheckinImages: List<String>.from(data['faceCheckinImages'] ?? []),
      faceCheckoutImages: List<String>.from(data['faceCheckoutImages'] ?? []),
      lastFaceCapture: data['lastFaceCapture'] != null 
          ? (data['lastFaceCapture'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
      joinDate: (data['joinDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  // Factory constructor to create EmployeeModel from Map
  factory EmployeeModel.fromMap(Map<String, dynamic> map) {
    return EmployeeModel(
      id: map['id'] ?? '',
      employeeCode: map['employeeCode'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      age: map['age'] ?? 0,
      department: map['department'] ?? '',
      position: map['position'] ?? '',
      salary: (map['salary'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'USD',
      shiftStart: map['shiftStart'] is Timestamp 
          ? (map['shiftStart'] as Timestamp).toDate()
          : DateTime.parse(map['shiftStart'] ?? DateTime.now().toIso8601String()),
      shiftEnd: map['shiftEnd'] is Timestamp 
          ? (map['shiftEnd'] as Timestamp).toDate()
          : DateTime.parse(map['shiftEnd'] ?? DateTime.now().toIso8601String()),
      workDays: List<String>.from(map['workDays'] ?? []),
      imageUrl: map['imageUrl'] ?? '',
      faceEmbedding: List<double>.from(map['faceEmbedding'] ?? []),
      faceCheckinImages: List<String>.from(map['faceCheckinImages'] ?? []),
      faceCheckoutImages: List<String>.from(map['faceCheckoutImages'] ?? []),
      lastFaceCapture: map['lastFaceCapture'] != null 
          ? (map['lastFaceCapture'] is Timestamp 
              ? (map['lastFaceCapture'] as Timestamp).toDate()
              : DateTime.parse(map['lastFaceCapture']))
          : null,
      isActive: map['isActive'] ?? true,
      joinDate: map['joinDate'] is Timestamp 
          ? (map['joinDate'] as Timestamp).toDate()
          : DateTime.parse(map['joinDate'] ?? DateTime.now().toIso8601String()),
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] is Timestamp 
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      createdBy: map['createdBy'] ?? '',
    );
  }

  // Convert EmployeeModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'employeeCode': employeeCode,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'age': age,
      'department': department,
      'position': position,
      'salary': salary,
      'currency': currency,
      'shiftStart': Timestamp.fromDate(shiftStart),
      'shiftEnd': Timestamp.fromDate(shiftEnd),
      'workDays': workDays,
      'imageUrl': imageUrl,
      'faceEmbedding': faceEmbedding,
      'faceLandmarks': faceLandmarks,
      'faceGeometry': faceGeometry,
      'faceCheckinImages': faceCheckinImages,
      'faceCheckoutImages': faceCheckoutImages,
      'lastFaceCapture': lastFaceCapture != null ? Timestamp.fromDate(lastFaceCapture!) : null,
      'isActive': isActive,
      'joinDate': Timestamp.fromDate(joinDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
    };
  }

  // Convert EmployeeModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeCode': employeeCode,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'age': age,
      'department': department,
      'position': position,
      'salary': salary,
      'currency': currency,
      'shiftStart': shiftStart.toIso8601String(),
      'shiftEnd': shiftEnd.toIso8601String(),
      'workDays': workDays,
      'imageUrl': imageUrl,
      'faceEmbedding': faceEmbedding,
      'isActive': isActive,
      'joinDate': joinDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }


  // Get shift duration in hours (handles overnight shifts)
  double get shiftDurationHours {
    var duration = shiftEnd.difference(shiftStart);
    
    // Handle overnight shifts (e.g., 4:00 PM - 12:00 AM)
    if (duration.isNegative) {
      // Add 24 hours for next-day calculation
      final nextDayEnd = DateTime(
        shiftEnd.year,
        shiftEnd.month,
        shiftEnd.day + 1,
        shiftEnd.hour,
        shiftEnd.minute,
      );
      duration = nextDayEnd.difference(shiftStart);
    }
    
    return duration.inMinutes / 60.0;
  }

  // Check if employee works today
  bool get worksToday {
    final today = DateTime.now().weekday;
    final dayNames = ['', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return workDays.contains(dayNames[today]);
  }

  // Get formatted shift time
  String get shiftTimeFormatted {
    final startTime = '${shiftStart.hour.toString().padLeft(2, '0')}:${shiftStart.minute.toString().padLeft(2, '0')}';
    final endTime = '${shiftEnd.hour.toString().padLeft(2, '0')}:${shiftEnd.minute.toString().padLeft(2, '0')}';
    return '$startTime - $endTime';
  }

  // Convenience getter for face data availability
  bool get hasFaceData => faceEmbedding.isNotEmpty;

  // Create a copy with updated fields
  EmployeeModel copyWith({
    String? id,
    String? employeeCode,
    String? fullName,
    String? email,
    String? phone,
    int? age,
    String? department,
    String? position,
    double? salary,
    String? currency,
    DateTime? shiftStart,
    DateTime? shiftEnd,
    List<String>? workDays,
    String? imageUrl,
    List<double>? faceEmbedding,
    Map<String, List<double>>? faceLandmarks,
    Map<String, double>? faceGeometry,
    List<String>? faceCheckinImages,
    List<String>? faceCheckoutImages,
    DateTime? lastFaceCapture,
    bool? isActive,
    DateTime? joinDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      employeeCode: employeeCode ?? this.employeeCode,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      department: department ?? this.department,
      position: position ?? this.position,
      salary: salary ?? this.salary,
      currency: currency ?? this.currency,
      shiftStart: shiftStart ?? this.shiftStart,
      shiftEnd: shiftEnd ?? this.shiftEnd,
      workDays: workDays ?? this.workDays,
      imageUrl: imageUrl ?? this.imageUrl,
      faceEmbedding: faceEmbedding ?? this.faceEmbedding,
      faceLandmarks: faceLandmarks ?? this.faceLandmarks,
      faceGeometry: faceGeometry ?? this.faceGeometry,
      faceCheckinImages: faceCheckinImages ?? this.faceCheckinImages,
      faceCheckoutImages: faceCheckoutImages ?? this.faceCheckoutImages,
      lastFaceCapture: lastFaceCapture ?? this.lastFaceCapture,
      isActive: isActive ?? this.isActive,
      joinDate: joinDate ?? this.joinDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  String toString() {
    return 'EmployeeModel(id: $id, employeeCode: $employeeCode, fullName: $fullName, department: $department, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is EmployeeModel &&
        other.id == id &&
        other.employeeCode == employeeCode &&
        other.fullName == fullName &&
        other.email == email;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        employeeCode.hashCode ^
        fullName.hashCode ^
        email.hashCode;
  }
}
