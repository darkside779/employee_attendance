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

class EditEmployee extends StatefulWidget {
  final String employeeId;
  
  const EditEmployee({super.key, required this.employeeId});

  @override
  State<EditEmployee> createState() => _EditEmployeeState();
}

class _EditEmployeeState extends State<EditEmployee> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Controllers
  final _employeeCodeController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _salaryController = TextEditingController();

  // Form state
  String _selectedDepartment = 'IT';
  String _selectedPosition = 'Worker';
  String _selectedCurrency = 'AED';
  TimeOfDay _shiftStart = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _shiftEnd = const TimeOfDay(hour: 17, minute: 0);
  List<String> _selectedWorkDays = [
    'monday',
    'tuesday', 
    'wednesday',
    'thursday',
    'friday',
  ];
  DateTime _joinDate = DateTime.now();
  bool _isActive = true;
  bool _isLoading = false;
  bool _isInitializing = true;
  File? _selectedImage;
  Uint8List? _webImage;
  String _currentImageUrl = '';
  final ImagePicker _imagePicker = ImagePicker();
  
  EmployeeModel? _originalEmployee;

  // Options
  final List<String> _departments = [
    'IT',
    'HR',
    'Finance',
    'Operations',
    'Marketing',
    'Sales',
    'Worker'
  ];

  final List<String> _positions = [
    'Manager',
    'Developer',
    'Designer',
    'Analyst',
    'Worker',
    'Accountant',
    'HR Specialist',
    'Marketing Specialist',
    'Sales Representative',
  ];

  final List<String> _currencies = [
    'AED',
    'USD',
    'EUR',
    'GBP',
  ];

  final List<Map<String, dynamic>> _workDayOptions = [
    {'key': 'monday', 'label': 'MON'},
    {'key': 'tuesday', 'label': 'TUE'},
    {'key': 'wednesday', 'label': 'WED'},
    {'key': 'thursday', 'label': 'THU'},
    {'key': 'friday', 'label': 'FRI'},
    {'key': 'saturday', 'label': 'SAT'},
    {'key': 'sunday', 'label': 'SUN'},
  ];

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  void _loadEmployeeData() async {
    try {
      final employeeProvider = context.read<EmployeeProvider>();
      final employee = await employeeProvider.getEmployeeById(widget.employeeId);
      
      if (employee != null && mounted) {
        _originalEmployee = employee;
        setState(() {
          // Populate form with existing data
          _employeeCodeController.text = employee.employeeCode;
          _fullNameController.text = employee.fullName;
          _emailController.text = employee.email;
          _phoneController.text = employee.phone;
          _ageController.text = employee.age.toString();
          _salaryController.text = employee.salary.toString();
          
          _selectedDepartment = employee.department;
          _selectedPosition = employee.position;
          _selectedCurrency = employee.currency;
          _shiftStart = TimeOfDay.fromDateTime(employee.shiftStart);
          _shiftEnd = TimeOfDay.fromDateTime(employee.shiftEnd);
          _selectedWorkDays = List.from(employee.workDays);
          _joinDate = employee.joinDate;
          _isActive = employee.isActive;
          _currentImageUrl = employee.imageUrl;
          
          _isInitializing = false;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee not found'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading employee: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.of(context).pop();
      }
    }
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

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Edit Employee',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading employee data...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Edit Employee',
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
                child: Column(
                  children: [
                    Icon(
                      Icons.edit,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Edit Employee Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Update employee details and information',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Personal Information Section
              _buildSectionTitle('Personal Information'),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _employeeCodeController,
                label: 'Employee Code',
                icon: Icons.badge,
                readOnly: true, // Employee code cannot be changed
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter employee code';
                  }
                  return null;
                },
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

              const SizedBox(height: 16),

              _buildTextField(
                controller: _ageController,
                label: 'Age',
                icon: Icons.cake,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter age';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 16 || age > 100) {
                    return 'Please enter valid age (16-100)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Employment Details Section
              _buildSectionTitle('Employment Details'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      value: _selectedDepartment,
                      label: 'Department',
                      icon: Icons.business,
                      items: _departments,
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartment = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
                      value: _selectedPosition,
                      label: 'Position',
                      icon: Icons.work,
                      items: _positions,
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

              _buildDateField(),

              const SizedBox(height: 16),

              // Active Status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isActive 
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _isActive ? Icons.check_circle : Icons.cancel,
                        color: _isActive ? AppColors.success : AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isActive ? 'Active Employee' : 'Inactive Employee',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            _isActive ? 'Employee can check in/out' : 'Employee cannot check in/out',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                      activeThumbColor: AppColors.success,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Compensation Section
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
                      suffixIcon: Icon(Icons.monetization_on, color: AppColors.success),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter salary';
                        }
                        final salary = double.tryParse(value);
                        if (salary == null || salary < 0) {
                          return 'Please enter valid salary';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
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

              const SizedBox(height: 24),

              // Work Schedule Section
              _buildSectionTitle('Work Schedule'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTimeField(
                      label: 'Shift Start',
                      icon: Icons.login,
                      time: _shiftStart,
                      onTap: () => _selectTime(context, true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimeField(
                      label: 'Shift End',
                      icon: Icons.logout,
                      time: _shiftEnd,
                      onTap: () => _selectTime(context, false),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Work Days
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Work Days',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _workDayOptions.map((day) {
                      final isSelected = _selectedWorkDays.contains(day['key']);
                      return FilterChip(
                        label: Text(day['label']),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedWorkDays.add(day['key']);
                            } else {
                              _selectedWorkDays.remove(day['key']);
                            }
                          });
                        },
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primary,
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Employee Photo Section
              _buildSectionTitle('Employee Photo'),
              const SizedBox(height: 16),
              _buildEmployeePhotoSection(),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateEmployee,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Update Employee',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
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
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: readOnly ? AppColors.background : AppColors.surface,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.surface,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Join Date',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${_joinDate.day}/${_joinDate.month}/${_joinDate.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _joinDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _joinDate) {
      setState(() {
        _joinDate = picked;
      });
    }
  }

  Widget _buildTimeField({
    required String label,
    required IconData icon,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.surface,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  time.format(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _shiftStart : _shiftEnd,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _shiftStart = picked;
        } else {
          _shiftEnd = picked;
        }
      });
    }
  }

  Widget _buildEmployeePhotoSection() {
    return Column(
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
              : _currentImageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        _currentImageUrl,
                        fit: BoxFit.cover,
                        width: 146,
                        height: 146,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add Employee\nPhoto',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        },
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
                          'Add Employee\nPhoto',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
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
              label: Text((_selectedImage == null && _webImage == null && _currentImageUrl.isEmpty) ? 'Add Photo' : 'Change Photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            
            if (_selectedImage != null || _webImage != null || _currentImageUrl.isNotEmpty) ...[
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

        const SizedBox(height: 12),

        // Photo Guidelines
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
                size: 16,
                color: AppColors.info,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'For best results, use a clear front-facing photo with good lighting',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.info,
                  ),
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
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Photo Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _pickImageFromCamera();
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _pickImageFromGallery();
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
            _currentImageUrl = ''; // Clear existing image
          });
        } else {
          setState(() {
            _selectedImage = File(image.path);
            _webImage = null;
            _currentImageUrl = ''; // Clear existing image
          });
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Photo captured successfully!'),
              backgroundColor: AppColors.success,
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
            _currentImageUrl = ''; // Clear existing image
          });
        } else {
          setState(() {
            _selectedImage = File(image.path);
            _webImage = null;
            _currentImageUrl = ''; // Clear existing image
          });
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Photo selected successfully!'),
              backgroundColor: AppColors.success,
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
      _currentImageUrl = '';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo removed'),
        backgroundColor: AppColors.info,
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

  void _updateEmployee() async {
    if (!_formKey.currentState!.validate()) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
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
      
      // Handle image upload if a new image was selected
      String finalImageUrl = _currentImageUrl;
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
            duration: const Duration(seconds: 10),
          ),
        );
        
        final imageData = kIsWeb ? _webImage! : _selectedImage!;
        final downloadUrl = await _uploadImageToFirebase(
          imageData,
          _employeeCodeController.text,
        );
        
        if (downloadUrl != null) {
          finalImageUrl = downloadUrl;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo upload failed, but employee will be updated without new photo'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      }
      
      // Create updated employee model
      final updatedEmployee = EmployeeModel(
        id: widget.employeeId,
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
        imageUrl: finalImageUrl,
        faceEmbedding: _originalEmployee?.faceEmbedding ?? [],
        isActive: _isActive,
        joinDate: _joinDate,
        createdAt: _originalEmployee?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: _originalEmployee?.createdBy ?? authProvider.currentUserModel!.id,
      );

      // Update employee in Firestore via provider
      final success = await employeeProvider.updateEmployee(updatedEmployee);
      
      if (!success) {
        throw Exception(employeeProvider.errorMessage ?? 'Failed to update employee');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Employee ${updatedEmployee.fullName} updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update employee: $e'),
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
