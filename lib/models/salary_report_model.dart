import 'package:cloud_firestore/cloud_firestore.dart';

class SalaryReportModel {
  final String id;
  final String employeeId;
  final String employeeCode;
  final String month; // YYYY-MM format
  final int year;
  final double baseSalary;
  final double totalHours;
  final double expectedHours;
  final double overtimeHours;
  final double deductions;
  final double bonuses;
  final double finalSalary;
  final String currency;
  final String status; // draft, approved, paid
  final String generatedBy;
  final String approvedBy;
  final DateTime createdAt;
  final DateTime? approvedAt;

  SalaryReportModel({
    required this.id,
    required this.employeeId,
    required this.employeeCode,
    required this.month,
    required this.year,
    required this.baseSalary,
    required this.totalHours,
    required this.expectedHours,
    required this.overtimeHours,
    required this.deductions,
    required this.bonuses,
    required this.finalSalary,
    required this.currency,
    required this.status,
    required this.generatedBy,
    required this.approvedBy,
    required this.createdAt,
    this.approvedAt,
  });

  // Factory constructor to create SalaryReportModel from Firestore document
  factory SalaryReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return SalaryReportModel(
      id: doc.id,
      employeeId: data['employeeId'] ?? '',
      employeeCode: data['employeeCode'] ?? '',
      month: data['month'] ?? '',
      year: data['year'] ?? DateTime.now().year,
      baseSalary: (data['baseSalary'] ?? 0).toDouble(),
      totalHours: (data['totalHours'] ?? 0).toDouble(),
      expectedHours: (data['expectedHours'] ?? 0).toDouble(),
      overtimeHours: (data['overtimeHours'] ?? 0).toDouble(),
      deductions: (data['deductions'] ?? 0).toDouble(),
      bonuses: (data['bonuses'] ?? 0).toDouble(),
      finalSalary: (data['finalSalary'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'USD',
      status: data['status'] ?? 'draft',
      generatedBy: data['generatedBy'] ?? '',
      approvedBy: data['approvedBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      approvedAt: (data['approvedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Factory constructor to create SalaryReportModel from Map
  factory SalaryReportModel.fromMap(Map<String, dynamic> map) {
    return SalaryReportModel(
      id: map['id'] ?? '',
      employeeId: map['employeeId'] ?? '',
      employeeCode: map['employeeCode'] ?? '',
      month: map['month'] ?? '',
      year: map['year'] ?? DateTime.now().year,
      baseSalary: (map['baseSalary'] ?? 0).toDouble(),
      totalHours: (map['totalHours'] ?? 0).toDouble(),
      expectedHours: (map['expectedHours'] ?? 0).toDouble(),
      overtimeHours: (map['overtimeHours'] ?? 0).toDouble(),
      deductions: (map['deductions'] ?? 0).toDouble(),
      bonuses: (map['bonuses'] ?? 0).toDouble(),
      finalSalary: (map['finalSalary'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'USD',
      status: map['status'] ?? 'draft',
      generatedBy: map['generatedBy'] ?? '',
      approvedBy: map['approvedBy'] ?? '',
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      approvedAt: map['approvedAt'] is Timestamp 
          ? (map['approvedAt'] as Timestamp).toDate()
          : map['approvedAt'] != null 
              ? DateTime.parse(map['approvedAt'])
              : null,
    );
  }

  // Convert SalaryReportModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'employeeCode': employeeCode,
      'month': month,
      'year': year,
      'baseSalary': baseSalary,
      'totalHours': totalHours,
      'expectedHours': expectedHours,
      'overtimeHours': overtimeHours,
      'deductions': deductions,
      'bonuses': bonuses,
      'finalSalary': finalSalary,
      'currency': currency,
      'status': status,
      'generatedBy': generatedBy,
      'approvedBy': approvedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
    };
  }

  // Convert SalaryReportModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeCode': employeeCode,
      'month': month,
      'year': year,
      'baseSalary': baseSalary,
      'totalHours': totalHours,
      'expectedHours': expectedHours,
      'overtimeHours': overtimeHours,
      'deductions': deductions,
      'bonuses': bonuses,
      'finalSalary': finalSalary,
      'currency': currency,
      'status': status,
      'generatedBy': generatedBy,
      'approvedBy': approvedBy,
      'createdAt': createdAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
    };
  }

  // Create a copy of SalaryReportModel with updated fields
  SalaryReportModel copyWith({
    String? id,
    String? employeeId,
    String? employeeCode,
    String? month,
    int? year,
    double? baseSalary,
    double? totalHours,
    double? expectedHours,
    double? overtimeHours,
    double? deductions,
    double? bonuses,
    double? finalSalary,
    String? currency,
    String? status,
    String? generatedBy,
    String? approvedBy,
    DateTime? createdAt,
    DateTime? approvedAt,
  }) {
    return SalaryReportModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeCode: employeeCode ?? this.employeeCode,
      month: month ?? this.month,
      year: year ?? this.year,
      baseSalary: baseSalary ?? this.baseSalary,
      totalHours: totalHours ?? this.totalHours,
      expectedHours: expectedHours ?? this.expectedHours,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      deductions: deductions ?? this.deductions,
      bonuses: bonuses ?? this.bonuses,
      finalSalary: finalSalary ?? this.finalSalary,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      generatedBy: generatedBy ?? this.generatedBy,
      approvedBy: approvedBy ?? this.approvedBy,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }

  // Status checks
  bool get isDraft => status == 'draft';
  bool get isApproved => status == 'approved';
  bool get isPaid => status == 'paid';

  // Calculate hourly rate
  double get hourlyRate {
    if (expectedHours == 0) return 0;
    return baseSalary / expectedHours;
  }

  // Calculate overtime pay
  double get overtimePay {
    return overtimeHours * hourlyRate * 1.5; // 1.5x overtime rate
  }

  // Calculate percentage of expected hours worked
  double get attendancePercentage {
    if (expectedHours == 0) return 0;
    return (totalHours / expectedHours) * 100;
  }

  // Calculate shortage hours
  double get shortageHours {
    return expectedHours > totalHours ? expectedHours - totalHours : 0;
  }

  // Get formatted month name
  String get monthName {
    if (month.isEmpty) return '';
    final parts = month.split('-');
    if (parts.length != 2) return month;
    
    final monthNum = int.tryParse(parts[1]);
    if (monthNum == null) return month;
    
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return monthNum > 0 && monthNum <= 12 ? months[monthNum] : month;
  }

  // Get formatted salary with currency
  String get formattedFinalSalary {
    return '$currency ${finalSalary.toStringAsFixed(2)}';
  }

  // Get formatted base salary with currency
  String get formattedBaseSalary {
    return '$currency ${baseSalary.toStringAsFixed(2)}';
  }

  // Get formatted deductions with currency
  String get formattedDeductions {
    return '$currency ${deductions.toStringAsFixed(2)}';
  }

  // Get formatted bonuses with currency
  String get formattedBonuses {
    return '$currency ${bonuses.toStringAsFixed(2)}';
  }

  // Get status color based on status
  String get statusDisplayText {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'approved':
        return 'Approved';
      case 'paid':
        return 'Paid';
      default:
        return status.toUpperCase();
    }
  }

  @override
  String toString() {
    return 'SalaryReportModel(id: $id, employeeCode: $employeeCode, month: $month, finalSalary: $finalSalary, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is SalaryReportModel &&
        other.id == id &&
        other.employeeId == employeeId &&
        other.month == month &&
        other.year == year;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        employeeId.hashCode ^
        month.hashCode ^
        year.hashCode;
  }
}
