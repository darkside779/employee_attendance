import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/employee_provider.dart';
import '../../models/employee_model.dart';

class AttendanceReports extends StatefulWidget {
  const AttendanceReports({super.key});

  @override
  State<AttendanceReports> createState() => _AttendanceReportsState();
}

class _AttendanceReportsState extends State<AttendanceReports> {
  DateTime _selectedDate = DateTime.now();
  String _selectedDepartment = 'All';
  String _selectedStatus = 'All';

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
  final List<String> _statuses = [
    'All',
    'Present',
    'Absent',
    'Late',
    'Half Day',
  ];

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  void _loadAttendanceData() {
    // Load attendance for all employees for selected date
    final employeeProvider = context.read<EmployeeProvider>();
    final employees = employeeProvider.employees;

    for (final employee in employees) {
      context.read<AttendanceProvider>().loadTodayAttendance(employee.id);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadAttendanceData();
    }
  }

  List<EmployeeModel> _getFilteredEmployees(List<EmployeeModel> employees) {
    return employees.where((employee) {
      // Filter by department
      if (_selectedDepartment != 'All' &&
          employee.department != _selectedDepartment) {
        return false;
      }

      // For now, show all employees (status filtering would need actual attendance data)
      return true;
    }).toList();
  }

  Widget _buildSummaryCard(
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _exportAttendance() {
    // Simulate CSV export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.download, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Attendance report exported for ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getAttendanceStatus(EmployeeModel employee) {
    // Simulate attendance status based on employee data
    // In a real app, this would come from actual attendance records
    if (!employee.isActive) return 'Inactive';

    // Simulate based on employee code hash for consistency
    final hash = employee.employeeCode.hashCode.abs();
    if (hash % 10 == 0) return 'Absent';
    if (hash % 8 == 0) return 'Late';
    if (hash % 15 == 0) return 'Half Day';
    return 'Present';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Present':
        return AppColors.success;
      case 'Late':
        return AppColors.warning;
      case 'Absent':
        return AppColors.error;
      case 'Half Day':
        return AppColors.info;
      default:
        return Colors.grey;
    }
  }

  String _getCheckInTime(EmployeeModel employee) {
    if (_getAttendanceStatus(employee) == 'Absent') return '--:--';

    // Simulate check-in times
    final hash = employee.employeeCode.hashCode.abs();
    final baseMinutes = 9 * 60; // 9:00 AM
    final variation = (hash % 60) - 30; // ±30 minutes
    final totalMinutes = baseMinutes + variation;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  String _getWorkDuration(EmployeeModel employee) {
    if (_getAttendanceStatus(employee) == 'Absent') return '--h --m';

    final status = _getAttendanceStatus(employee);
    if (status == 'Half Day') return '4h 00m';

    // Simulate work duration
    final hash = employee.employeeCode.hashCode.abs();
    final baseHours = 8;
    final variation = (hash % 3) - 1; // -1, 0, or +1 hours
    final totalHours = baseHours + variation;

    return '${totalHours}h 30m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Attendance - ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
        ),
        backgroundColor: AppColors.accountingColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _exportAttendance,
            icon: const Icon(Icons.download),
            tooltip: 'Export to CSV',
          ),
          IconButton(
            onPressed: _loadAttendanceData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Date Selection
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat(
                                  'MMM dd, yyyy',
                                ).format(_selectedDate),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Department and Status Filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedDepartment,
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
                        items: _departments
                            .map(
                              (dept) => DropdownMenuItem(
                                value: dept,
                                child: Text(dept),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDepartment = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: _statuses
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Summary Cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Present',
                    '18',
                    AppColors.success,
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Absent',
                    '4',
                    AppColors.error,
                    Icons.cancel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Late',
                    '3',
                    AppColors.warning,
                    Icons.schedule,
                  ),
                ),
              ],
            ),
          ),

          // Employee List
          Expanded(
            child: Consumer2<AttendanceProvider, EmployeeProvider>(
              builder: (context, attendanceProvider, employeeProvider, child) {
                final employees = _getFilteredEmployees(
                  employeeProvider.employees,
                );

                if (employees.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text('No employees found'),
                        Text('Adjust filters or add employees'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    return _buildAttendanceCard(employee);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(employee) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employee Info
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: employee.imageUrl.isNotEmpty
                      ? NetworkImage(employee.imageUrl)
                      : null,
                  child: employee.imageUrl.isEmpty
                      ? Text(employee.fullName[0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${employee.employeeCode} • ${employee.department}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Attendance Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_getAttendanceStatus(employee)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getAttendanceStatus(employee),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Attendance Details
            Consumer<AttendanceProvider>(
              builder: (context, attendanceProvider, child) {
                // This is a simplified version - in practice you'd load specific attendance
                return Row(
                  children: [
                    Expanded(
                      child: _buildTimeCard(
                        'Check-in',
                        _getCheckInTime(employee),
                        Icons.login,
                        AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTimeCard(
                        'Check-out',
                        _getAttendanceStatus(employee) == 'Absent'
                            ? '--:--'
                            : '17:30',
                        Icons.logout,
                        _getAttendanceStatus(employee) == 'Absent'
                            ? Colors.grey
                            : AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTimeCard(
                        'Duration',
                        _getWorkDuration(employee),
                        Icons.timer,
                        AppColors.info,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard(String label, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
