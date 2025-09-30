import 'package:flutter/foundation.dart';
import '../core/services/firebase_service.dart';
import '../models/salary_report_model.dart';
import '../models/attendance_model.dart';
import '../models/employee_model.dart';

class SalaryProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService.instance;
  
  List<SalaryReportModel> _salaryReports = [];
  SalaryReportModel? _selectedReport;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<SalaryReportModel> get salaryReports => _salaryReports;
  SalaryReportModel? get selectedReport => _selectedReport;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load salary reports
  Future<void> loadSalaryReports({
    String? employeeId,
    String? month,
    int? year,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      _salaryReports = await _firebaseService.getSalaryReports(
        employeeId: employeeId,
        month: month,
        year: year,
      );
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load salary reports: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Generate salary report for an employee
  Future<bool> generateSalaryReport({
    required EmployeeModel employee,
    required String month,
    required int year,
    required List<AttendanceModel> attendanceRecords,
    required String generatedBy,
    double bonuses = 0.0,
    double additionalDeductions = 0.0,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Calculate working hours and expected hours
      final totalHours = attendanceRecords.fold<double>(
        0.0, 
        (sum, attendance) => sum + attendance.workedHours,
      );
      
      final overtimeHours = attendanceRecords.fold<double>(
        0.0, 
        (sum, attendance) => sum + attendance.overtimeHours,
      );

      // Calculate expected hours based on working days
      final expectedHours = _calculateExpectedHours(employee, month, year);
      
      // Calculate deductions for missed hours
      final missedHours = expectedHours > totalHours ? expectedHours - totalHours : 0;
      final hourlyRate = employee.salary / expectedHours;
      final missedHoursDeduction = missedHours * hourlyRate;
      
      // Calculate overtime pay (1.5x rate)
      final overtimePay = overtimeHours * hourlyRate * 1.5;
      
      // Calculate final salary
      final totalDeductions = missedHoursDeduction + additionalDeductions;
      final finalSalary = employee.salary - totalDeductions + bonuses + overtimePay;

      final salaryReport = SalaryReportModel(
        id: '', // Will be set by Firestore
        employeeId: employee.id,
        employeeCode: employee.employeeCode,
        month: month,
        year: year,
        baseSalary: employee.salary,
        totalHours: totalHours,
        expectedHours: expectedHours,
        overtimeHours: overtimeHours,
        deductions: totalDeductions,
        bonuses: bonuses + overtimePay,
        finalSalary: finalSalary,
        currency: employee.currency,
        status: 'draft',
        generatedBy: generatedBy,
        approvedBy: '',
        createdAt: DateTime.now(),
        approvedAt: null,
      );

      final reportId = await _firebaseService.addSalaryReport(salaryReport);
      final newReport = salaryReport.copyWith(id: reportId);
      
      _salaryReports.insert(0, newReport);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Failed to generate salary report: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Approve salary report
  Future<bool> approveSalaryReport(String reportId, String approvedBy) async {
    try {
      _setLoading(true);
      _clearError();

      final reportIndex = _salaryReports.indexWhere((r) => r.id == reportId);
      if (reportIndex == -1) {
        _setError('Report not found');
        return false;
      }

      final updatedReport = _salaryReports[reportIndex].copyWith(
        status: 'approved',
        approvedBy: approvedBy,
        approvedAt: DateTime.now(),
      );

      await _firebaseService.updateSalaryReport(updatedReport);
      _salaryReports[reportIndex] = updatedReport;
      
      if (_selectedReport?.id == reportId) {
        _selectedReport = updatedReport;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to approve salary report: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Mark salary as paid
  Future<bool> markSalaryAsPaid(String reportId) async {
    try {
      _setLoading(true);
      _clearError();

      final reportIndex = _salaryReports.indexWhere((r) => r.id == reportId);
      if (reportIndex == -1) {
        _setError('Report not found');
        return false;
      }

      final updatedReport = _salaryReports[reportIndex].copyWith(
        status: 'paid',
      );

      await _firebaseService.updateSalaryReport(updatedReport);
      _salaryReports[reportIndex] = updatedReport;
      
      if (_selectedReport?.id == reportId) {
        _selectedReport = updatedReport;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to mark salary as paid: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update salary report
  Future<bool> updateSalaryReport(SalaryReportModel report) async {
    try {
      _setLoading(true);
      _clearError();

      await _firebaseService.updateSalaryReport(report);
      
      final index = _salaryReports.indexWhere((r) => r.id == report.id);
      if (index != -1) {
        _salaryReports[index] = report;
      }
      
      if (_selectedReport?.id == report.id) {
        _selectedReport = report;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update salary report: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Select salary report
  void selectReport(SalaryReportModel? report) {
    _selectedReport = report;
    notifyListeners();
  }

  // Get salary statistics
  Map<String, dynamic> getSalaryStats() {
    if (_salaryReports.isEmpty) {
      return {
        'totalReports': 0,
        'draftReports': 0,
        'approvedReports': 0,
        'paidReports': 0,
        'totalSalary': 0.0,
        'totalDeductions': 0.0,
        'totalBonuses': 0.0,
      };
    }

    final totalReports = _salaryReports.length;
    final draftReports = _salaryReports.where((r) => r.isDraft).length;
    final approvedReports = _salaryReports.where((r) => r.isApproved).length;
    final paidReports = _salaryReports.where((r) => r.isPaid).length;
    
    final totalSalary = _salaryReports.fold<double>(
      0.0, 
      (sum, report) => sum + report.finalSalary,
    );
    
    final totalDeductions = _salaryReports.fold<double>(
      0.0, 
      (sum, report) => sum + report.deductions,
    );
    
    final totalBonuses = _salaryReports.fold<double>(
      0.0, 
      (sum, report) => sum + report.bonuses,
    );

    return {
      'totalReports': totalReports,
      'draftReports': draftReports,
      'approvedReports': approvedReports,
      'paidReports': paidReports,
      'totalSalary': totalSalary,
      'totalDeductions': totalDeductions,
      'totalBonuses': totalBonuses,
    };
  }

  // Get reports by status
  List<SalaryReportModel> getReportsByStatus(String status) {
    return _salaryReports.where((r) => r.status == status).toList();
  }

  // Get monthly reports
  List<SalaryReportModel> getMonthlyReports(String month, int year) {
    return _salaryReports.where((r) => r.month == month && r.year == year).toList();
  }

  // Calculate expected hours for a month
  double _calculateExpectedHours(EmployeeModel employee, String month, int year) {
    // Parse month (YYYY-MM format)
    final monthParts = month.split('-');
    if (monthParts.length != 2) return 0.0;
    
    final monthNum = int.tryParse(monthParts[1]);
    if (monthNum == null) return 0.0;
    
    // Get number of days in month
    final daysInMonth = DateTime(year, monthNum + 1, 0).day;
    
    // Calculate working days based on employee's work schedule
    int workingDays = 0;
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, monthNum, day);
      final dayName = _getDayName(date.weekday);
      if (employee.workDays.contains(dayName)) {
        workingDays++;
      }
    }
    
    // Calculate expected hours per day
    final hoursPerDay = employee.shiftDurationHours;
    
    return workingDays * hoursPerDay;
  }

  // Get day name from weekday number
  String _getDayName(int weekday) {
    const dayNames = [
      '', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'
    ];
    return dayNames[weekday];
  }

  // Clear all data
  void clearAll() {
    _salaryReports.clear();
    _selectedReport = null;
    _clearError();
    notifyListeners();
  }

  // Refresh reports
  Future<void> refresh() async {
    await loadSalaryReports();
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
