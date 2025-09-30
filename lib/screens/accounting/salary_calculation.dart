import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SalaryCalculation extends StatelessWidget {
  const SalaryCalculation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salary Calculation'),
        backgroundColor: AppColors.accountingColor,
      ),
      body: const Center(
        child: Text('Salary Calculation - Coming Soon'),
      ),
    );
  }
}
