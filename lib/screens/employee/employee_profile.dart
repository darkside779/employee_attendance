import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class EmployeeProfile extends StatelessWidget {
  final String? employeeId;
  
  const EmployeeProfile({super.key, this.employeeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Profile'),
        backgroundColor: AppColors.employeeColor,
      ),
      body: Center(
        child: Text('Employee Profile ${employeeId ?? ''} - Coming Soon'),
      ),
    );
  }
}
