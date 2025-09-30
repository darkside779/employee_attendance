import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTextStyles {
  // Headings
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle heading4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle heading5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  // Subtitles
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  static const TextStyle subtitle2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  // Body Text
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  // Button Text
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );
  
  // Caption
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.3,
  );
  
  // Overline
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.6,
    letterSpacing: 1.5,
  );
  
  // Custom Styles for Specific Use Cases
  
  // Role-based text styles
  static const TextStyle adminText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.adminColor,
  );
  
  static const TextStyle accountingText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.accountingColor,
  );
  
  static const TextStyle employeeText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.employeeColor,
  );
  
  // Status text styles
  static const TextStyle successText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.success,
  );
  
  static const TextStyle errorText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.error,
  );
  
  static const TextStyle warningText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.warning,
  );
  
  static const TextStyle infoText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.info,
  );
  
  // Face recognition specific styles
  static const TextStyle faceDetectedText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.faceDetected,
  );
  
  static const TextStyle faceNotDetectedText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.faceNotDetected,
  );
  
  static const TextStyle faceProcessingText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.faceProcessing,
  );
  
  // Card title and content styles
  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  // Form field styles
  static const TextStyle fieldLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle fieldInput = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle fieldError = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.error,
  );
  
  // Navigation styles
  static const TextStyle navigationLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle navigationLabelSelected = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );
  
  // Time and date styles
  static const TextStyle timeText = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: 'monospace',
  );
  
  static const TextStyle dateText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  
  // Salary and numbers styles
  static const TextStyle salaryText = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.success,
    fontFamily: 'monospace',
  );
  
  static const TextStyle numberText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: 'monospace',
  );
}
