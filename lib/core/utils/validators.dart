class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    
    return null;
  }

  // Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  // Employee code validation
  static String? validateEmployeeCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Employee code is required';
    }
    
    if (value.length < 3) {
      return 'Employee code must be at least 3 characters long';
    }
    
    return null;
  }

  // Age validation
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }
    
    if (age < 18 || age > 100) {
      return 'Age must be between 18 and 100';
    }
    
    return null;
  }

  // Salary validation
  static String? validateSalary(String? value) {
    if (value == null || value.isEmpty) {
      return 'Salary is required';
    }
    
    final salary = double.tryParse(value);
    if (salary == null) {
      return 'Please enter a valid salary amount';
    }
    
    if (salary <= 0) {
      return 'Salary must be greater than zero';
    }
    
    return null;
  }

  // Department validation
  static String? validateDepartment(String? value) {
    if (value == null || value.isEmpty) {
      return 'Department is required';
    }
    
    return null;
  }

  // Position validation
  static String? validatePosition(String? value) {
    if (value == null || value.isEmpty) {
      return 'Position is required';
    }
    
    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    return null;
  }

  // Numeric validation
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number for $fieldName';
    }
    
    return null;
  }

  // Positive number validation
  static String? validatePositiveNumber(String? value, String fieldName) {
    final numericValidation = validateNumeric(value, fieldName);
    if (numericValidation != null) {
      return numericValidation;
    }
    
    final number = double.parse(value!);
    if (number <= 0) {
      return '$fieldName must be greater than zero';
    }
    
    return null;
  }

  // Time validation (HH:MM format)
  static String? validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Time is required';
    }
    
    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    
    if (!timeRegex.hasMatch(value)) {
      return 'Please enter time in HH:MM format';
    }
    
    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/[^\s/$.?#].[^\s]*$',
      caseSensitive: false,
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }

  // Notes validation
  static String? validateNotes(String? value) {
    if (value != null && value.length > 500) {
      return 'Notes must be less than 500 characters';
    }
    
    return null;
  }

  // Working days validation
  static String? validateWorkingDays(List<String>? value) {
    if (value == null || value.isEmpty) {
      return 'At least one working day must be selected';
    }
    
    if (value.length > 7) {
      return 'Cannot select more than 7 days';
    }
    
    return null;
  }

  // Date range validation
  static String? validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return 'Both start and end dates are required';
    }
    
    if (startDate.isAfter(endDate)) {
      return 'Start date cannot be after end date';
    }
    
    return null;
  }

  // Shift time validation
  static String? validateShiftTimes(String? startTime, String? endTime) {
    if (startTime == null || startTime.isEmpty) {
      return 'Start time is required';
    }
    
    if (endTime == null || endTime.isEmpty) {
      return 'End time is required';
    }
    
    final startTimeValidation = validateTime(startTime);
    if (startTimeValidation != null) {
      return startTimeValidation;
    }
    
    final endTimeValidation = validateTime(endTime);
    if (endTimeValidation != null) {
      return endTimeValidation;
    }
    
    // Parse times and compare
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');
    
    final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
    
    if (startMinutes >= endMinutes) {
      return 'End time must be after start time';
    }
    
    return null;
  }
}
