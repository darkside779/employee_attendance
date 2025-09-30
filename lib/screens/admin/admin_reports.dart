import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AdminReports extends StatelessWidget {
  const AdminReports({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Reports'),
        backgroundColor: AppColors.adminColor,
      ),
      body: const Center(
        child: Text('Admin Reports - Coming Soon'),
      ),
    );
  }
}
