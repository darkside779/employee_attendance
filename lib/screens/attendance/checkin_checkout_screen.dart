// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/attendance_model.dart';
import '../../models/employee_model.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/employee_provider.dart';
import '../face_checkin_screen.dart';

class CheckinCheckoutScreen extends StatefulWidget {
  const CheckinCheckoutScreen({super.key});

  @override
  State<CheckinCheckoutScreen> createState() => _CheckinCheckoutScreenState();
}

class _CheckinCheckoutScreenState extends State<CheckinCheckoutScreen> {
  Timer? _clockTimer;
  DateTime _currentTime = DateTime.now();
  AttendanceModel? _todayAttendance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startClock();
    // Defer loading attendance to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTodayAttendance();
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  Future<void> _loadTodayAttendance() async {
    // For now, get any employee's attendance to demonstrate
    // In a real app, you'd get this from authentication or employee selection
    final employeeProvider = context.read<EmployeeProvider>();
    if (employeeProvider.employees.isNotEmpty) {
      final firstEmployee = employeeProvider.employees.first;
      final attendanceProvider = context.read<AttendanceProvider>();
      await attendanceProvider.loadTodayAttendance(firstEmployee.id);
      if (mounted) {
        setState(() {
          _todayAttendance = attendanceProvider.todayAttendance;
        });
      }
    }
  }

  Future<void> _handleFaceRecognitionCheckIn() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const FaceCheckinScreen(),
      ),
    );

    if (result != null && result['success'] == true) {
      final employee = result['employee'] as EmployeeModel;
      final confidence = result['confidence'] as double;
      
      await _performCheckIn(employee, true, confidence);
    }
  }

  Future<void> _performCheckIn(
    EmployeeModel employee, 
    bool verifiedByFace, 
    double confidence,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final attendanceProvider = context.read<AttendanceProvider>();
      
      final success = await attendanceProvider.checkIn(
        employeeId: employee.id,
        employeeCode: employee.employeeCode,
        verifiedByFace: verifiedByFace,
        confidence: confidence,
        notes: 'Check-in via ${verifiedByFace ? 'face recognition' : 'manual entry'}',
      );

      if (success) {
        await _loadTodayAttendance();
        _showSuccessDialog('Check-in Successful', 
          'Welcome ${employee.fullName}!\nCheck-in time: ${_formatTime(_currentTime)}');
      } else {
        _showErrorDialog('Check-in Failed', 
          attendanceProvider.errorMessage ?? 'Unknown error occurred');
      }
    } catch (e) {
      _showErrorDialog('Check-in Error', 'Failed to check in: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _performCheckOut() async {
    if (_todayAttendance == null) {
      _showErrorDialog('Check-out Error', 'No check-in record found for today');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final attendanceProvider = context.read<AttendanceProvider>();
      
      final success = await attendanceProvider.checkOut(
        employeeId: _todayAttendance!.employeeId,
        verifiedByFace: false,
        confidence: 0.0,
        notes: 'Check-out via manual entry',
      );

      if (success) {
        await _loadTodayAttendance();
        final workedHours = _calculateWorkedHours();
        _showSuccessDialog('Check-out Successful', 
          'Thank you for your work today!\nWorked Hours: ${_formatDuration(workedHours)}');
      } else {
        _showErrorDialog('Check-out Failed', 
          attendanceProvider.errorMessage ?? 'Unknown error occurred');
      }
    } catch (e) {
      _showErrorDialog('Check-out Error', 'Failed to check out: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Duration _calculateWorkedHours() {
    if (_todayAttendance?.checkIn == null) return Duration.zero;
    final checkOut = _todayAttendance?.checkOut ?? DateTime.now();
    return checkOut.difference(_todayAttendance!.checkIn!);
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: AppColors.error),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              _buildHeader(),
              
              const SizedBox(height: 32),
              
              // Time Display
              _buildTimeDisplay(),
              
              const SizedBox(height: 32),
              
              // Today's Status
              _buildTodayStatus(),
              
              const SizedBox(height: 40),
              
              // Action Buttons
              _buildActionButtons(),
              
              const SizedBox(height: 32),
              
              // Quick Stats
              _buildQuickStats(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.access_time,
          size: 64,
          color: AppColors.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Employee Attendance',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _formatDate(_currentTime),
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeDisplay() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Current Time',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatTime(_currentTime),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStatus() {
    return Consumer<AttendanceProvider>(
      builder: (context, attendanceProvider, child) {
        final attendance = attendanceProvider.todayAttendance;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today\'s Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              if (attendance == null) ...[
                Row(
                  children: [
                    Icon(Icons.radio_button_unchecked, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Text(
                      'Not checked in yet',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ] else ...[
                _buildStatusRow(
                  'Check-in',
                  attendance.checkInFormatted,
                  Icons.login,
                  AppColors.success,
                ),
                if (attendance.checkOut != null) ...[
                  const SizedBox(height: 12),
                  _buildStatusRow(
                    'Check-out',
                    attendance.checkOutFormatted,
                    Icons.logout,
                    AppColors.error,
                  ),
                  const SizedBox(height: 12),
                  _buildStatusRow(
                    'Worked',
                    _formatDuration(_calculateWorkedHours()),
                    Icons.schedule,
                    AppColors.info,
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Consumer<AttendanceProvider>(
      builder: (context, attendanceProvider, child) {
        final attendance = attendanceProvider.todayAttendance;
        final isCheckedIn = attendance?.isCheckedIn ?? false;
        final isCheckedOut = attendance?.isCheckedOut ?? false;
        
        return Column(
          children: [
            // Face Recognition Check-in
            if (!isCheckedIn && !isCheckedOut) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleFaceRecognitionCheckIn,
                  icon: _isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.face, size: 24),
                  label: Text(
                    _isLoading ? 'Processing...' : 'Check-in with Face Recognition',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'OR',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 16),
            ],
            
            // Manual Check-out
            if (isCheckedIn && !isCheckedOut) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _performCheckOut,
                  icon: _isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.logout, size: 24),
                  label: Text(
                    _isLoading ? 'Processing...' : 'Check-out',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
            
            // Already checked out message
            if (isCheckedOut) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You have completed your shift for today!',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Days Present', '22', Icons.calendar_today, AppColors.success),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem('Hours Worked', '176', Icons.schedule, AppColors.info),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Late Days', '2', Icons.warning, AppColors.warning),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem('Absent Days', '1', Icons.close, AppColors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
