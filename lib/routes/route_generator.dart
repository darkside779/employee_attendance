import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../screens/common/splash_screen.dart';
import '../screens/common/error_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/manage_employees.dart';
import '../screens/admin/add_employee.dart';
import '../screens/admin/edit_employee.dart';
import '../screens/admin/admin_reports.dart';
import '../screens/accounting/accounting_dashboard.dart';
import '../screens/accounting/attendance_reports.dart';
import '../screens/accounting/salary_calculation.dart';
import '../screens/accounting/payroll_export.dart';
import '../screens/face_checkin_screen.dart';
import '../screens/face_checkout_screen.dart';
import '../screens/attendance/checkin_checkout_screen.dart';
import '../screens/employee/attendance_history.dart';
import '../screens/employee/employee_profile.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Common routes
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
        
      case AppRoutes.error:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ErrorScreen(
            error: args?['error'] ?? 'An unexpected error occurred',
            onRetry: args?['onRetry'],
          ),
          settings: settings,
        );

      // Authentication routes
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
        
      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );
        
      case AppRoutes.roleSelection:
        return MaterialPageRoute(
          builder: (_) => const RoleSelectionScreen(),
          settings: settings,
        );

      // Admin routes
      case AppRoutes.adminDashboard:
        return MaterialPageRoute(
          builder: (_) => const AdminDashboard(),
          settings: settings,
        );
        
      case AppRoutes.manageEmployees:
        return MaterialPageRoute(
          builder: (_) => const ManageEmployees(),
          settings: settings,
        );
        
      case AppRoutes.addEmployee:
        return MaterialPageRoute(
          builder: (_) => const AddEmployee(),
          settings: settings,
        );
        
      case AppRoutes.editEmployee:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => EditEmployee(
            employeeId: args[AppRoutes.employeeIdParam],
          ),
          settings: settings,
        );
        
      case AppRoutes.adminReports:
        return MaterialPageRoute(
          builder: (_) => const AdminReports(),
          settings: settings,
        );

      // Accounting routes
      case AppRoutes.accountingDashboard:
        return MaterialPageRoute(
          builder: (_) => const AccountingDashboard(),
          settings: settings,
        );
        
      case AppRoutes.attendanceReports:
        return MaterialPageRoute(
          builder: (_) => const AttendanceReports(),
          settings: settings,
        );
        
      case AppRoutes.salaryCalculation:
        return MaterialPageRoute(
          builder: (_) => const SalaryCalculation(),
          settings: settings,
        );
        
      case AppRoutes.payrollExport:
        return MaterialPageRoute(
          builder: (_) => const PayrollExport(),
          settings: settings,
        );

      // Employee routes
      case AppRoutes.faceRecognition:
        return MaterialPageRoute(
          builder: (_) => const FaceCheckinScreen(),
          settings: settings,
        );
        
      case AppRoutes.faceCheckin:
        return MaterialPageRoute(
          builder: (_) => const FaceCheckinScreen(),
          settings: settings,
        );
        
      case AppRoutes.faceCheckout:
        return MaterialPageRoute(
          builder: (_) => const FaceCheckoutScreen(),
          settings: settings,
        );
        
      case AppRoutes.checkinCheckout:
        return MaterialPageRoute(
          builder: (_) => const CheckinCheckoutScreen(),
          settings: settings,
        );
        
      case AppRoutes.attendanceHistory:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AttendanceHistory(
            employeeId: args?[AppRoutes.employeeIdParam],
          ),
          settings: settings,
        );
        
      case AppRoutes.employeeProfile:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => EmployeeProfile(
            employeeId: args?[AppRoutes.employeeIdParam],
          ),
          settings: settings,
        );

      // Default route
      default:
        return MaterialPageRoute(
          builder: (_) => const ErrorScreen(
            error: 'Page not found',
          ),
          settings: settings,
        );
    }
  }

  // Custom page transitions
  static Route<dynamic> slideTransition(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static Route<dynamic> fadeTransition(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  static Route<dynamic> scaleTransition(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            ),
          ),
          child: child,
        );
      },
    );
  }
}
