class AppStrings {
  // App Info
  static const String appName = 'Employee Attendance';
  static const String appVersion = '1.0.0';
  
  // Common
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String refresh = 'Refresh';
  static const String retry = 'Retry';
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';
  
  // Authentication
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String loginFailed = 'Login failed. Please try again.';
  static const String invalidCredentials = 'Invalid email or password';
  
  // Roles
  static const String admin = 'Admin';
  static const String accounting = 'Accounting';
  static const String employee = 'Employee';
  static const String selectRole = 'Select Your Role';
  
  // Employee Management
  static const String employees = 'Employees';
  static const String addEmployee = 'Add Employee';
  static const String editEmployee = 'Edit Employee';
  static const String deleteEmployee = 'Delete Employee';
  static const String employeeName = 'Employee Name';
  static const String employeeCode = 'Employee Code';
  static const String employeeDetails = 'Employee Details';
  static const String fullName = 'Full Name';
  static const String age = 'Age';
  static const String phone = 'Phone';
  static const String department = 'Department';
  static const String position = 'Position';
  static const String salary = 'Salary';
  static const String shiftStart = 'Shift Start';
  static const String shiftEnd = 'Shift End';
  static const String joinDate = 'Join Date';
  
  // Face Recognition
  static const String faceRecognition = 'Face Recognition';
  static const String capturePhoto = 'Capture Photo';
  static const String faceDetected = 'Face Detected';
  static const String faceNotDetected = 'Face Not Detected';
  static const String faceMatched = 'Face Matched';
  static const String faceNotMatched = 'Face Not Matched';
  static const String processingFace = 'Processing Face...';
  static const String lookAtCamera = 'Please look at the camera';
  static const String holdStill = 'Hold still while processing';
  
  // Attendance
  static const String attendance = 'Attendance';
  static const String checkIn = 'Check In';
  static const String checkOut = 'Check Out';
  static const String attendanceHistory = 'Attendance History';
  static const String attendanceReport = 'Attendance Report';
  static const String checkedIn = 'Checked In Successfully';
  static const String checkedOut = 'Checked Out Successfully';
  static const String alreadyCheckedIn = 'Already checked in today';
  static const String alreadyCheckedOut = 'Already checked out today';
  static const String attendanceRecorded = 'Attendance recorded successfully';
  
  // Time & Date
  static const String today = 'Today';
  static const String yesterday = 'Yesterday';
  static const String thisWeek = 'This Week';
  static const String thisMonth = 'This Month';
  static const String workingHours = 'Working Hours';
  static const String totalHours = 'Total Hours';
  static const String overtimeHours = 'Overtime Hours';
  static const String present = 'Present';
  static const String absent = 'Absent';
  static const String late = 'Late';
  static const String halfDay = 'Half Day';
  
  // Salary & Reports
  static const String salaryCalculation = 'Salary Calculation';
  static const String salaryReport = 'Salary Report';
  static const String baseSalary = 'Base Salary';
  static const String finalSalary = 'Final Salary';
  static const String deductions = 'Deductions';
  static const String bonuses = 'Bonuses';
  static const String exportReport = 'Export Report';
  static const String generateReport = 'Generate Report';
  
  // Dashboard
  static const String dashboard = 'Dashboard';
  static const String overview = 'Overview';
  static const String statistics = 'Statistics';
  static const String recentActivity = 'Recent Activity';
  static const String quickActions = 'Quick Actions';
  
  // Settings
  static const String settings = 'Settings';
  static const String profile = 'Profile';
  static const String preferences = 'Preferences';
  static const String notifications = 'Notifications';
  static const String security = 'Security';
  static const String about = 'About';
  
  // Validation Messages
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String confirmPassword = 'Confirm Password';
  static const String passwordMismatch = 'Passwords do not match';
  
  // Error Messages
  static const String networkError = 'Network error. Please check your connection';
  static const String serverError = 'Server error. Please try again later';
  static const String unknownError = 'An unknown error occurred';
  static const String cameraPermissionDenied = 'Camera permission denied';
  static const String storagePermissionDenied = 'Storage permission denied';
  static const String locationPermissionDenied = 'Location permission denied';
  
  // Arabic Strings (for localization)
  static const Map<String, String> arabic = {
    'appName': 'حضور الموظفين',
    'login': 'تسجيل الدخول',
    'admin': 'مدير',
    'accounting': 'محاسب',
    'employee': 'موظف',
    'checkIn': 'تسجيل الحضور',
    'checkOut': 'تسجيل الانصراف',
    'attendance': 'الحضور',
    'dashboard': 'لوحة التحكم',
    'employees': 'الموظفين',
    'reports': 'التقارير',
    'settings': 'الإعدادات',
  };
}
