import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PayrollExport extends StatelessWidget {
  const PayrollExport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payroll Export'),
        backgroundColor: AppColors.accountingColor,
      ),
      body: const Center(
        child: Text('Payroll Export - Coming Soon'),
      ),
    );
  }
}
