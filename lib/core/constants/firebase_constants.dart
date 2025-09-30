class FirebaseConstants {
  // Collection Names
  static const String usersCollection = 'users';
  static const String employeesCollection = 'employees';
  static const String attendanceCollection = 'attendance';
  static const String salaryReportsCollection = 'salaryReports';
  static const String departmentsCollection = 'departments';
  static const String settingsCollection = 'settings';
  
  // Storage Paths
  static const String employeeImagesPath = 'employee_images';
  static const String companyAssetsPath = 'company_assets';
  static const String reportsPath = 'reports';
  
  // Document IDs
  static const String configDocId = 'config';
  
  // Field Names
  // User Fields
  static const String userRole = 'role';
  static const String userEmail = 'email';
  static const String userName = 'name';
  static const String userPermissions = 'permissions';
  static const String userLastLogin = 'lastLogin';
  static const String userIsActive = 'isActive';
  static const String userCreatedAt = 'createdAt';
  static const String userDepartment = 'department';
  
  // Employee Fields
  static const String employeeCode = 'employeeCode';
  static const String employeeFullName = 'fullName';
  static const String employeeEmail = 'email';
  static const String employeePhone = 'phone';
  static const String employeeAge = 'age';
  static const String employeeDepartment = 'department';
  static const String employeePosition = 'position';
  static const String employeeSalary = 'salary';
  static const String employeeCurrency = 'currency';
  static const String employeeShiftStart = 'shiftStart';
  static const String employeeShiftEnd = 'shiftEnd';
  static const String employeeWorkDays = 'workDays';
  static const String employeeImageUrl = 'imageUrl';
  static const String employeeFaceEmbedding = 'faceEmbedding';
  static const String employeeIsActive = 'isActive';
  static const String employeeJoinDate = 'joinDate';
  static const String employeeCreatedAt = 'createdAt';
  static const String employeeUpdatedAt = 'updatedAt';
  static const String employeeCreatedBy = 'createdBy';
  
  // Attendance Fields
  static const String attendanceEmployeeId = 'employeeId';
  static const String attendanceEmployeeCode = 'employeeCode';
  static const String attendanceDate = 'date';
  static const String attendanceCheckIn = 'checkIn';
  static const String attendanceCheckOut = 'checkOut';
  static const String attendanceBreakStart = 'breakStart';
  static const String attendanceBreakEnd = 'breakEnd';
  static const String attendanceWorkedHours = 'workedHours';
  static const String attendanceOvertimeHours = 'overtimeHours';
  static const String attendanceVerifiedByFace = 'verifiedByFace';
  static const String attendanceConfidence = 'confidence';
  static const String attendanceLocation = 'location';
  static const String attendanceNotes = 'notes';
  static const String attendanceStatus = 'status';
  
  // Salary Report Fields
  static const String salaryEmployeeId = 'employeeId';
  static const String salaryEmployeeCode = 'employeeCode';
  static const String salaryMonth = 'month';
  static const String salaryYear = 'year';
  static const String salaryBaseSalary = 'baseSalary';
  static const String salaryTotalHours = 'totalHours';
  static const String salaryExpectedHours = 'expectedHours';
  static const String salaryOvertimeHours = 'overtimeHours';
  static const String salaryDeductions = 'deductions';
  static const String salaryBonuses = 'bonuses';
  static const String salaryFinalSalary = 'finalSalary';
  static const String salaryCurrency = 'currency';
  static const String salaryStatus = 'status';
  static const String salaryGeneratedBy = 'generatedBy';
  static const String salaryApprovedBy = 'approvedBy';
  static const String salaryCreatedAt = 'createdAt';
  static const String salaryApprovedAt = 'approvedAt';
  
  // Department Fields
  static const String departmentName = 'name';
  static const String departmentDescription = 'description';
  static const String departmentManagerId = 'managerId';
  static const String departmentEmployeeCount = 'employeeCount';
  static const String departmentIsActive = 'isActive';
  static const String departmentCreatedAt = 'createdAt';
  
  // Settings Fields
  static const String settingsFaceThreshold = 'faceRecognitionThreshold';
  static const String settingsCheckInRadius = 'allowedCheckInRadius';
  static const String settingsWorkingDays = 'workingDaysPerWeek';
  static const String settingsOvertimeRate = 'overtimeRate';
  static const String settingsCurrency = 'currency';
  static const String settingsTimezone = 'timezone';
  static const String settingsCompanyName = 'companyName';
  static const String settingsCompanyLogo = 'companyLogo';
  
  // Role Values
  static const String roleAdmin = 'admin';
  static const String roleAccounting = 'accounting';
  
  // Attendance Status Values
  static const String statusPresent = 'present';
  static const String statusLate = 'late';
  static const String statusAbsent = 'absent';
  static const String statusHalfDay = 'half-day';
  
  // Salary Status Values
  static const String salaryStatusDraft = 'draft';
  static const String salaryStatusApproved = 'approved';
  static const String salaryStatusPaid = 'paid';
  
  // Work Days
  static const List<String> workDays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];
  
  // Default Values
  static const double defaultFaceThreshold = 0.6;
  static const double defaultCheckInRadius = 100.0; // meters
  static const int defaultWorkingDaysPerWeek = 5;
  static const double defaultOvertimeRate = 1.5;
  static const String defaultCurrency = 'AED';
  static const String defaultTimezone = 'UTC';
}
