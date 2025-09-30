import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AttendanceHistory extends StatelessWidget {
  final String? employeeId;
  
  const AttendanceHistory({super.key, this.employeeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        backgroundColor: AppColors.employeeColor,
      ),
      body: Center(
        child: Text('Attendance History ${employeeId ?? ''} - Coming Soon'),
      ),
    );
  }
}
