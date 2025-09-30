// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../models/employee_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/employee_provider.dart';

class AddEmployee extends StatefulWidget {
  const AddEmployee({super.key});

  @override
  State<AddEmployee> createState() => _AddEmployeeState();
}

class _AddEmployeeState extends State<AddEmployee> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form Controllers
  final _employeeCodeController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _salaryController = TextEditingController();

  // Form Values
  String _selectedDepartment = 'IT';
  String _selectedPosition = 'Software Developer';
  String _selectedCurrency = 'USD';
  TimeOfDay _shiftStart = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _shiftEnd = const TimeOfDay(hour: 17, minute: 0);
  final List<String> _selectedWorkDays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
  ];
  DateTime _joinDate = DateTime.now();
  bool _isActive = true;
  bool _isLoading = false;
  File? _selectedImage;
  Uint8List? _webImage; // For web platform
  final ImagePicker _imagePicker = ImagePicker();

  // Options
  final List<String> _departments = [
    'IT',
    'HR',
    'Finance',
    'Operations',
    'Marketing',
    'Sales',
    'Worker',
  ];
  final Map<String, List<String>> _positionsByDepartment = {
    'IT': [
      'Software Developer',
      'System Admin',
      'DevOps Engineer',
      'QA Engineer',
      'IT Manager',
    ],
    'HR': ['HR Manager', 'HR Specialist', 'Recruiter', 'Training Coordinator'],
    'Finance': [
      'Accountant',
      'Financial Analyst',
      'Finance Manager',
      'Bookkeeper',
    ],
    'Operations': [
      'Operations Manager',
      'Supervisor',
      'Coordinator',
      'Specialist',
    ],
    'Marketing': [
      'Marketing Manager',
      'Marketing Specialist',
      'Content Creator',
      'Social Media Manager',
    ],
    'Sales': [
      'Sales Manager',
      'Sales Representative',
      'Account Manager',
      'Business Development',
    ],
    'Worker': ['Worker'],
  };
  final List<String> _currencies = ['USD', 'AED'];
  final List<String> _weekDays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  @override
  void initState() {
    super.initState();
    _generateEmployeeCode();
  }

  @override
  void dispose() {
    _employeeCodeController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _salaryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _generateEmployeeCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(7);
    _employeeCodeController.text = 'EMP$timestamp';
  }

  List<String> get _availablePositions =>
      _positionsByDepartment[_selectedDepartment] ?? [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Add Employee',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.person_add, color: Colors.white, size: 32),
                    SizedBox(height: 12),
                    Text(
                      'Add New Employee',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Fill in the employee information below',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Basic Information
              _buildSectionTitle('Basic Information'),
              const SizedBox(height: 16),

              // Employee Photo Section
              _buildEmployeePhotoSection(),
              
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _employeeCodeController,
                      label: 'Employee Code',
                      icon: Icons.badge,
                      readOnly: true,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _generateEmployeeCode,
                        tooltip: 'Generate new code',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _ageController,
                      label: 'Age',
                      icon: Icons.cake,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter age';
                        }
                        final age = int.tryParse(value);
                        if (age == null || age < 18 || age > 70) {
                          return 'Age must be between 18-70';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _fullNameController,
                label: 'Full Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter full name';
                  }
                  if (value.trim().split(' ').length < 2) {
                    return 'Please enter first and last name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _emailController,
                      label: 'Email (Optional)',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        // Email is optional - only validate if not empty
                        if (value != null && value.isNotEmpty) {
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter valid email';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _phoneController,
                      label: 'Phone',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Employment Details
              _buildSectionTitle('Employment Details'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildDropdown<String>(
                      value: _selectedDepartment,
                      label: 'Department',
                      icon: Icons.business,
                      items: _departments,
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartment = value!;
                          _selectedPosition = _availablePositions.first;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown<String>(
                      value: _selectedPosition,
                      label: 'Position',
                      icon: Icons.work,
                      items: _availablePositions,
                      onChanged: (value) {
                        setState(() {
                          _selectedPosition = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _buildDatePicker(
                label: 'Join Date',
                icon: Icons.calendar_today,
                selectedDate: _joinDate,
                onDateSelected: (date) {
                  setState(() {
                    _joinDate = date;
                  });
                },
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Active Employee'),
                      subtitle: const Text('Employee can check in/out'),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value ?? true;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Compensation
              _buildSectionTitle('Compensation'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _salaryController,
                      label: 'Monthly Salary',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter salary';
                        }
                        final salary = int.tryParse(value);
                        if (salary == null || salary < 1000) {
                          return 'Salary must be at least 1000';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown<String>(
                      value: _selectedCurrency,
                      label: 'Currency',
                      icon: Icons.monetization_on,
                      items: _currencies,
                      onChanged: (value) {
                        setState(() {
                          _selectedCurrency = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Work Schedule
              _buildSectionTitle('Work Schedule'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTimePicker(
                      label: 'Shift Start',
                      icon: Icons.login,
                      selectedTime: _shiftStart,
                      onTimeSelected: (time) {
                        setState(() {
                          _shiftStart = time;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimePicker(
                      label: 'Shift End',
                      icon: Icons.logout,
                      selectedTime: _shiftEnd,
                      onTimeSelected: (time) {
                        setState(() {
                          _shiftEnd = time;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _buildWorkDaysSelector(),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.primary),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveEmployee,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save Employee'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildEmployeePhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Employee Photo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Upload employee photo for face recognition verification',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        
        Center(
          child: Column(
            children: [
              // Photo Preview/Placeholder
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: (_selectedImage != null || _webImage != null)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: kIsWeb && _webImage != null
                            ? Image.memory(
                                _webImage!,
                                fit: BoxFit.cover,
                                width: 146,
                                height: 146,
                              )
                            : !kIsWeb && _selectedImage != null
                                ? Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                    width: 146,
                                    height: 146,
                                  )
                                : Container(
                                    width: 146,
                                    height: 146,
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.photo,
                                          size: 40,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Photo Selected',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No Photo Selected',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Tap button below to add',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
              
              const SizedBox(height: 16),
              
              // Photo Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Camera Button
                  ElevatedButton.icon(
                    onPressed: () => _showImagePickerOptions(),
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: Text((_selectedImage == null && _webImage == null) ? 'Add Photo' : 'Change Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  
                  if (_selectedImage != null || _webImage != null) ...[
                    const SizedBox(width: 12),
                    // Remove Button
                    OutlinedButton.icon(
                      onPressed: _removePhoto,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Remove'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Photo Requirements
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Photo Requirements: Clear face view, good lighting, no glasses/masks',
                        style: TextStyle(
                          color: AppColors.info,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                const Text(
                  'Select Photo Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Camera Option
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text('Camera'),
                  subtitle: const Text('Take a new photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                ),
                
                // Gallery Option
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.photo_library,
                      color: AppColors.info,
                    ),
                  ),
                  title: const Text('Gallery'),
                  subtitle: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromGallery();
                  },
                ),
                
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _webImage = bytes;
            _selectedImage = null;
          });
        } else {
          setState(() {
            _selectedImage = File(image.path);
            _webImage = null;
          });
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Photo captured successfully!'),
              backgroundColor: AppColors.success,
              action: SnackBarAction(
                label: 'View',
                textColor: Colors.white,
                onPressed: () => _showImagePreview(),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture photo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _webImage = bytes;
            _selectedImage = null;
          });
        } else {
          setState(() {
            _selectedImage = File(image.path);
            _webImage = null;
          });
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Photo selected successfully!'),
              backgroundColor: AppColors.success,
              action: SnackBarAction(
                label: 'View',
                textColor: Colors.white,
                onPressed: () => _showImagePreview(),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select photo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removePhoto() {
    setState(() {
      _selectedImage = null;
      _webImage = null;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo removed'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showImagePreview() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Employee Photo Preview'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary),
              ),
              child: (_selectedImage != null || _webImage != null)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: kIsWeb && _webImage != null
                          ? Image.memory(
                              _webImage!,
                              fit: BoxFit.cover,
                            )
                          : !kIsWeb && _selectedImage != null
                              ? Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.photo,
                                        size: 40,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Photo Selected',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_circle,
                          size: 80,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Employee Photo',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _selectedImage?.path.split('/').last ?? 'No image',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              'Photo is ready for face recognition verification',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showImagePickerOptions();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Change Photo'),
          ),
        ],
      ),
    );
  }

  Future<String?> _uploadImageToFirebase(dynamic imageData, String employeeCode) async {
    try {
      debugPrint('Starting image upload for employee: $employeeCode');
      debugPrint('Image data type: ${imageData.runtimeType}');
      
      // Create a reference to Firebase Storage
      final storage = FirebaseStorage.instanceFor(
        bucket: 'gs://attendance-sys-uae.firebasestorage.app',
      );
      
      debugPrint('Firebase Storage instance created');
      
      // Create a unique filename with employee code and timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${employeeCode}_$timestamp.jpg';
      final ref = storage.ref().child('employee_photos/$fileName');
      
      // Upload the image (handle both File and Uint8List)
      final UploadTask uploadTask;
      if (kIsWeb && imageData is Uint8List) {
        uploadTask = ref.putData(
          imageData,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'employeeCode': employeeCode,
              'uploadedBy': context.read<AuthProvider>().currentUserModel?.id ?? 'system',
              'uploadedAt': DateTime.now().toIso8601String(),
            },
          ),
        );
      } else if (!kIsWeb && imageData is File) {
        uploadTask = ref.putFile(
          imageData,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'employeeCode': employeeCode,
              'uploadedBy': context.read<AuthProvider>().currentUserModel?.id ?? 'system',
              'uploadedAt': DateTime.now().toIso8601String(),
            },
          ),
        );
      } else {
        throw Exception('Invalid image data type for current platform');
      }
      
      // Wait for upload completion and get download URL
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return null;
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool readOnly = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey[100] : null,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required String label,
    required IconData icon,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(value: item, child: Text(item.toString()));
      }).toList(),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required IconData icon,
    required DateTime selectedDate,
    required void Function(DateTime) onDateSelected,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
        ),
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required IconData icon,
    required TimeOfDay selectedTime,
    required void Function(TimeOfDay) onTimeSelected,
  }) {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: selectedTime,
        );
        if (time != null) {
          onTimeSelected(time);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(selectedTime.format(context)),
      ),
    );
  }

  Widget _buildWorkDaysSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Work Days',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _weekDays.map((day) {
            final isSelected = _selectedWorkDays.contains(day);
            return FilterChip(
              label: Text(day.substring(0, 3).toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedWorkDays.add(day);
                  } else {
                    _selectedWorkDays.remove(day);
                  }
                });
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
        if (_selectedWorkDays.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Please select at least one work day',
              style: TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  void _saveEmployee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedWorkDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one work day'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user from auth provider
      final authProvider = context.read<AuthProvider>();
      final employeeProvider = context.read<EmployeeProvider>();
      
      // Debug: Check if user is authenticated
      if (authProvider.currentUserModel == null) {
        throw Exception('User not authenticated. Please login again.');
      }
      
      debugPrint('Current user: ${authProvider.currentUserModel?.email}');
      
      // Upload image to Firebase Storage first (if selected)
      String imageUrl = '';
      if (_selectedImage != null || _webImage != null) {
        // Show uploading feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Text('Uploading employee photo...'),
              ],
            ),
            backgroundColor: AppColors.info,
            duration: const Duration(seconds: 10), // Long duration for upload
          ),
        );
        
        final imageData = kIsWeb ? _webImage! : _selectedImage!;
        final downloadUrl = await _uploadImageToFirebase(
          imageData,
          _employeeCodeController.text,
        );
        
        if (downloadUrl != null) {
          imageUrl = downloadUrl;
          // Clear the uploading message
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        } else {
          // Image upload failed, but we can still create the employee without photo
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo upload failed, but employee will be created without photo'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      }
      
      // Create employee model
      final employee = EmployeeModel(
        id: '', // Will be generated by Firestore
        employeeCode: _employeeCodeController.text,
        fullName: _fullNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        age: int.parse(_ageController.text),
        department: _selectedDepartment,
        position: _selectedPosition,
        salary: double.parse(_salaryController.text),
        currency: _selectedCurrency,
        shiftStart: DateTime(2024, 1, 1, _shiftStart.hour, _shiftStart.minute),
        shiftEnd: DateTime(2024, 1, 1, _shiftEnd.hour, _shiftEnd.minute),
        workDays: _selectedWorkDays,
        imageUrl: imageUrl, // Use Firebase Storage URL or empty string
        faceEmbedding: [],
        isActive: _isActive,
        joinDate: _joinDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: authProvider.currentUserModel?.id ?? 'system',
      );

      // Save employee to Firestore via provider
      final success = await employeeProvider.addEmployee(employee);
      
      if (!success) {
        throw Exception(employeeProvider.errorMessage ?? 'Failed to save employee');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Employee ${employee.fullName} added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add employee: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
