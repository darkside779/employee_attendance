class AppRoutes {
  // Authentication routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String roleSelection = '/role-selection';
  
  // Admin routes
  static const String adminDashboard = '/admin/dashboard';
  static const String manageEmployees = '/admin/employees';
  static const String addEmployee = '/admin/employees/add';
  static const String editEmployee = '/admin/employees/edit';
  static const String adminReports = '/admin/reports';
  static const String adminSettings = '/admin/settings';
  
  // Accounting routes
  static const String accountingDashboard = '/accounting/dashboard';
  static const String attendanceReports = '/accounting/attendance-reports';
  static const String salaryCalculation = '/accounting/salary-calculation';
  static const String payrollExport = '/accounting/payroll-export';
  static const String accountingSettings = '/accounting/settings';
  
  // Employee routes
  static const String faceRecognition = '/employee/face-recognition';
  static const String faceCheckin = '/employee/face-checkin';
  static const String faceCheckout = '/employee/face-checkout';
  static const String checkinCheckout = '/employee/checkin-checkout';
  static const String attendanceHistory = '/employee/attendance-history';
  static const String employeeProfile = '/employee/profile';
  
  // Common routes
  static const String error = '/error';
  static const String noPermission = '/no-permission';
  
  // Route parameters
  static const String employeeIdParam = 'employeeId';
  static const String dateParam = 'date';
  static const String monthParam = 'month';
  static const String yearParam = 'year';
}
