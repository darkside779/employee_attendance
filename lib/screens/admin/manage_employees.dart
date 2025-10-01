// ignore_for_file: use_build_context_synchronously, unused_element_parameter


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/employee_model.dart';
import '../../providers/employee_provider.dart';
import '../../routes/app_routes.dart';
import 'face_registration_screen.dart';

class ManageEmployees extends StatefulWidget {
  const ManageEmployees({super.key});

  @override
  State<ManageEmployees> createState() => _ManageEmployeesState();
}

class _ManageEmployeesState extends State<ManageEmployees> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedDepartment = 'All';
  bool _showActiveOnly = true;

  final List<String> _departments = [
    'All',
    'IT',
    'HR',
    'Finance',
    'Operations',
    'Marketing',
    'Sales',
    'Worker',
  ];

  @override
  void initState() {
    super.initState();
    // Load employees when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().loadEmployees();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EmployeeModel> _getFilteredEmployees(List<EmployeeModel> employees) {
    return employees.where((employee) {
      final matchesSearch =
          employee.fullName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          employee.employeeCode.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          employee.email.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesDepartment =
          _selectedDepartment == 'All' ||
          employee.department == _selectedDepartment;

      final matchesStatus = !_showActiveOnly || employee.isActive;

      return matchesSearch && matchesDepartment && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Manage Employees',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                AppRoutes.addEmployee,
              );
              // Refresh employee list if new employee was added
              if (result == true && mounted) {
                context.read<EmployeeProvider>().loadEmployees();
              }
            },
            icon: const Icon(Icons.person_add, color: Colors.white),
            tooltip: 'Add Employee',
          ),
          IconButton(
            onPressed: () => context.read<EmployeeProvider>().loadEmployees(),
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<EmployeeProvider>(
        builder: (context, employeeProvider, child) {
          if (employeeProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading employees...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          if (employeeProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading employees',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    employeeProvider.errorMessage!,
                    style: const TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => employeeProvider.loadEmployees(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          final filteredEmployees = _getFilteredEmployees(
            employeeProvider.employees,
          );

          return Column(
            children: [
              // Search and Filter Section
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search employees...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Filters
                    Row(
                      children: [
                        // Department Filter
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedDepartment,
                            onChanged: (value) {
                              setState(() {
                                _selectedDepartment = value!;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Department',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: _departments.map((dept) {
                              return DropdownMenuItem(
                                value: dept,
                                child: Text(dept),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Active Filter
                        Expanded(
                          flex: 1,
                          child: FilterChip(
                            label: const Text('Active Only'),
                            selected: _showActiveOnly,
                            onSelected: (selected) {
                              setState(() {
                                _showActiveOnly = selected;
                              });
                            },
                            selectedColor: AppColors.primary.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Employee List
              Expanded(
                child: filteredEmployees.isEmpty
                    ? _buildEmptyState(employeeProvider.employees.isEmpty)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredEmployees.length,
                        itemBuilder: (context, index) {
                          final employee = filteredEmployees[index];
                          return _buildEmployeeCard(employee);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            AppRoutes.addEmployee,
          );
          // Refresh employee list if new employee was added
          if (result == true && mounted) {
            context.read<EmployeeProvider>().loadEmployees();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmployeeCard(EmployeeModel employee) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showEmployeeDetails(employee),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: employee.imageUrl.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              employee.imageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint('Image load error: $error');
                                debugPrint('Image URL: ${employee.imageUrl}');
                                // Show a camera icon instead of initials for failed image loads
                                return Icon(
                                  Icons.photo_camera,
                                  color: AppColors.primary,
                                  size: 20,
                                );
                              },
                            ),
                          )
                        : Text(
                            employee.fullName
                                .split(' ')
                                .map((n) => n[0])
                                .take(2)
                                .join(),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),

                  const SizedBox(width: 16),

                  // Employee Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              employee.fullName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: employee.isActive
                                    ? AppColors.success.withValues(alpha: 0.1)
                                    : AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                employee.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: employee.isActive
                                      ? AppColors.success
                                      : AppColors.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${employee.employeeCode} • ${employee.position}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${employee.department} • ${employee.email}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  PopupMenuButton<String>(
                    onSelected: (action) =>
                        _handleEmployeeAction(action, employee),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: employee.isActive ? 'deactivate' : 'activate',
                        child: Row(
                          children: [
                            Icon(
                              employee.isActive
                                  ? Icons.block
                                  : Icons.check_circle,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(employee.isActive ? 'Deactivate' : 'Activate'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: employee.hasFaceData ? 'update_face' : 'register_face',
                        child: Row(
                          children: [
                            Icon(
                              Icons.face_retouching_natural,
                              size: 16,
                              color: employee.hasFaceData ? AppColors.success : AppColors.warning,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              employee.hasFaceData ? 'Update Face' : 'Register Face',
                              style: TextStyle(
                                color: employee.hasFaceData ? AppColors.success : AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              size: 16,
                              color: AppColors.error,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Additional Info
              Row(
                children: [
                  _buildInfoChip(Icons.schedule, employee.shiftTimeFormatted),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.attach_money,
                    '\$${employee.salary.toInt()}',
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.face,
                    employee.hasFaceData ? 'Face Registered' : 'No Face Data',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isNoData) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            isNoData ? 'No employees found' : 'No employees match your filters',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isNoData
                ? 'Start by adding your first employee'
                : 'Try adjusting your search or filters',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.addEmployee),
            icon: const Icon(Icons.add),
            label: const Text('Add Employee'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showEmployeeDetails(EmployeeModel employee) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EmployeeDetailsSheet(employee: employee),
    );
  }

  void _handleEmployeeAction(String action, EmployeeModel employee) {
    switch (action) {
      case 'edit':
        Navigator.pushNamed(
          context,
          AppRoutes.editEmployee,
          arguments: {AppRoutes.employeeIdParam: employee.id},
        );
        break;
      case 'activate':
      case 'deactivate':
        _toggleEmployeeStatus(employee);
        break;
      case 'register_face':
      case 'update_face':
        _handleFaceRegistration(employee);
        break;
      case 'delete':
        _showDeleteConfirmation(employee);
        break;
    }
  }

  void _toggleEmployeeStatus(EmployeeModel employee) async {
    final employeeProvider = context.read<EmployeeProvider>();

    // Create updated employee with toggled status
    final updatedEmployee = employee.copyWith(
      isActive: !employee.isActive,
      updatedAt: DateTime.now(),
    );

    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${employee.isActive ? 'Deactivating' : 'Activating'} employee...',
              ),
            ],
          ),
          backgroundColor: AppColors.info,
        ),
      );

      // Update employee in database
      final success = await employeeProvider.updateEmployee(updatedEmployee);

      if (success && mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Employee ${employee.isActive ? 'deactivated' : 'activated'} successfully',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${employee.isActive ? 'deactivate' : 'activate'} employee: ${employeeProvider.errorMessage ?? 'Unknown error'}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating employee: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // 🆕 UPDATED METHOD: Handle face registration with camera
  void _handleFaceRegistration(EmployeeModel employee) async {
    // Navigate to camera-based face registration screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FaceRegistrationScreen(employee: employee),
      ),
    );
  }

  void _showDeleteConfirmation(EmployeeModel employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text(
          'Are you sure you want to delete ${employee.fullName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deleteEmployee(employee),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteEmployee(EmployeeModel employee) async {
    Navigator.of(context).pop(); // Close dialog first

    final employeeProvider = context.read<EmployeeProvider>();

    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text('Deleting employee...'),
            ],
          ),
          backgroundColor: AppColors.info,
        ),
      );

      // Delete employee from database
      final success = await employeeProvider.deleteEmployee(employee.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${employee.fullName} deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete employee: ${employeeProvider.errorMessage ?? 'Unknown error'}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting employee: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

}

class _EmployeeDetailsSheet extends StatefulWidget {
  final EmployeeModel employee;
  final VoidCallback? onFaceRegistered;

  const _EmployeeDetailsSheet({required this.employee, this.onFaceRegistered});

  @override
  State<_EmployeeDetailsSheet> createState() => _EmployeeDetailsSheetState();
}

class _EmployeeDetailsSheetState extends State<_EmployeeDetailsSheet> {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: widget.employee.imageUrl.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            widget.employee.imageUrl,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const CircularProgressIndicator(
                                strokeWidth: 2,
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Detail image load error: $error');
                              debugPrint(
                                'Detail image URL: ${widget.employee.imageUrl}',
                              );
                              return Text(
                                widget.employee.fullName
                                    .split(' ')
                                    .map((n) => n[0])
                                    .take(2)
                                    .join(),
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              );
                            },
                          ),
                        )
                      : Text(
                          widget.employee.fullName
                              .split(' ')
                              .map((n) => n[0])
                              .take(2)
                              .join(),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.employee.fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.employee.employeeCode} • ${widget.employee.position}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Details
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailSection('Contact Information', [
                    _buildDetailRow('Email', widget.employee.email),
                    _buildDetailRow('Phone', widget.employee.phone),
                  ]),

                  _buildDetailSection('Employment Details', [
                    _buildDetailRow('Department', widget.employee.department),
                    _buildDetailRow('Position', widget.employee.position),
                    _buildDetailRow('Employee Code', widget.employee.employeeCode),
                    _buildDetailRow(
                      'Join Date',
                      _formatDate(widget.employee.joinDate),
                    ),
                    _buildDetailRow(
                      'Status',
                      widget.employee.isActive ? 'Active' : 'Inactive',
                    ),
                  ]),

                  _buildDetailSection('Compensation', [
                    _buildDetailRow(
                      'Salary',
                      '\$${widget.employee.salary.toInt()} ${widget.employee.currency}',
                    ),
                  ]),
                  _buildDetailSection('Work Schedule', [
                    _buildDetailRow('Shift Hours', widget.employee.shiftTimeFormatted),
                    _buildDetailRow('Work Days', widget.employee.workDays.join(', ')),
                    _buildDetailRow(
                      'Daily Hours',
                      '${widget.employee.shiftDurationHours.toStringAsFixed(1)} hours',
                    ),
                  ]),

                  _buildDetailSection('System Information', [
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailRow(
                            'Face Recognition',
                            widget.employee.faceEmbedding.isEmpty
                                ? 'Not Registered'
                                : 'Registered',
                          ),
                        ),
                        if (widget.employee.faceEmbedding.isEmpty &&
                            widget.employee.imageUrl.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _showFaceRegistrationDialog(context, widget.employee),
                            icon: const Icon(Icons.face, size: 16),
                            label: const Text('Register Face'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ],
                    ),
                    _buildDetailRow('Created', _formatDate(widget.employee.createdAt)),
                    _buildDetailRow(
                      'Last Updated',
                      _formatDate(widget.employee.updatedAt),
                    ),
                  ]),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showFaceRegistrationDialog(
    BuildContext context,
    EmployeeModel employee,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.face, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Register Face Recognition'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Register face recognition for ${employee.fullName}?',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: AppColors.info),
                      const SizedBox(width: 8),
                      const Text(
                        'How it works:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Face features will be extracted from the uploaded photo',
                  ),
                  const Text('• Encrypted data will be stored securely'),
                  const Text(
                    '• Employee can then use face recognition for check-in/out',
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FaceRegistrationScreen(employee: employee),
                ),
              );
            },
            icon: const Icon(Icons.face, size: 18),
            label: const Text('Register Face'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }


}
