import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/employee_provider.dart';

class AttendanceReports extends StatefulWidget {
  const AttendanceReports({super.key});

  @override
  State<AttendanceReports> createState() => _AttendanceReportsState();
}

class _AttendanceReportsState extends State<AttendanceReports> {
  @override
  void initState() {
    super.initState();
    _loadTodayAttendance();
  }

  void _loadTodayAttendance() {
    // Load today's attendance for all employees
    final employeeProvider = context.read<EmployeeProvider>();
    final employees = employeeProvider.employees;
    
    for (final employee in employees) {
      context.read<AttendanceProvider>().loadTodayAttendance(employee.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Attendance'),
        backgroundColor: AppColors.accountingColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadTodayAttendance,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer2<AttendanceProvider, EmployeeProvider>(
        builder: (context, attendanceProvider, employeeProvider, child) {
          final employees = employeeProvider.employees;
          
          if (employees.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No employees found'),
                  Text('Add employees first to see attendance'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];
              return _buildAttendanceCard(employee);
            },
          );
        },
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: employee.hasFaceData ? AppColors.success : AppColors.warning,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    employee.hasFaceData ? 'Face ✅' : 'No Face',
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
                        '09:15 AM',
                        Icons.login,
                        AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTimeCard(
                        'Check-out',
                        '--:--',
                        Icons.logout,
                        Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTimeCard(
                        'Duration',
                        '2h 30m',
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
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
