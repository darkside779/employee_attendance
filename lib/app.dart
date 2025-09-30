// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';
import 'providers/auth_provider.dart';
import 'providers/employee_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/salary_provider.dart';

class EmployeeAttendanceApp extends StatelessWidget {
  const EmployeeAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => SalaryProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,

        // Theme
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,

        // Routing
        initialRoute: AppRoutes.splash,
        onGenerateRoute: RouteGenerator.generateRoute,

        // Error handling
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
              ),
            ),
            child: child!,
          );
        },

        // Localization support (for future implementation)
        supportedLocales: const [
          Locale('en', 'US'), // English
          Locale('ar', 'UAE'), // Arabic
        ],

        // Navigator observers for analytics (if needed)
        navigatorObservers: [
          // Add analytics observers here if needed
        ],
      ),
    );
  }
}
