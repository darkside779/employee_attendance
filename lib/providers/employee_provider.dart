import 'package:flutter/foundation.dart';
import '../core/services/firebase_service.dart';
import '../models/employee_model.dart';

class EmployeeProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService.instance;
  
  List<EmployeeModel> _employees = [];
  EmployeeModel? _selectedEmployee;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<EmployeeModel> get employees => _employees;
  EmployeeModel? get selectedEmployee => _selectedEmployee;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get employeeCount => _employees.length;

  // Load all employees
  Future<void> loadEmployees() async {
    try {
      _setLoading(true);
      _clearError();
      
      _employees = await _firebaseService.getAllEmployees();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load employees: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get employee by ID
  Future<EmployeeModel?> getEmployeeById(String employeeId) async {
    try {
      return await _firebaseService.getEmployeeById(employeeId);
    } catch (e) {
      _setError('Failed to get employee: $e');
      return null;
    }
  }

  // Get employee by code
  Future<EmployeeModel?> getEmployeeByCode(String employeeCode) async {
    try {
      return await _firebaseService.getEmployeeByCode(employeeCode);
    } catch (e) {
      _setError('Failed to get employee: $e');
      return null;
    }
  }

  // Add new employee
  Future<bool> addEmployee(EmployeeModel employee) async {
    try {
      _setLoading(true);
      _clearError();

      final employeeId = await _firebaseService.addEmployee(employee);
      final newEmployee = employee.copyWith(id: employeeId);
      
      _employees.add(newEmployee);
      _employees.sort((a, b) => a.fullName.compareTo(b.fullName));
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add employee: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update employee
  Future<bool> updateEmployee(EmployeeModel employee) async {
    try {
      _setLoading(true);
      _clearError();

      await _firebaseService.updateEmployee(employee);
      
      final index = _employees.indexWhere((e) => e.id == employee.id);
      if (index != -1) {
        _employees[index] = employee;
        _employees.sort((a, b) => a.fullName.compareTo(b.fullName));
      }
      
      if (_selectedEmployee?.id == employee.id) {
        _selectedEmployee = employee;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update employee: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete employee (soft delete)
  Future<bool> deleteEmployee(String employeeId) async {
    try {
      _setLoading(true);
      _clearError();

      await _firebaseService.deleteEmployee(employeeId);
      
      _employees.removeWhere((e) => e.id == employeeId);
      
      if (_selectedEmployee?.id == employeeId) {
        _selectedEmployee = null;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete employee: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Select employee
  void selectEmployee(EmployeeModel? employee) {
    _selectedEmployee = employee;
    notifyListeners();
  }

  // Search employees
  List<EmployeeModel> searchEmployees(String query) {
    if (query.isEmpty) return _employees;
    
    final lowerQuery = query.toLowerCase();
    return _employees.where((employee) {
      return employee.fullName.toLowerCase().contains(lowerQuery) ||
             employee.employeeCode.toLowerCase().contains(lowerQuery) ||
             employee.department.toLowerCase().contains(lowerQuery) ||
             employee.position.toLowerCase().contains(lowerQuery) ||
             employee.email.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Filter employees by department
  List<EmployeeModel> filterByDepartment(String department) {
    if (department.isEmpty) return _employees;
    return _employees.where((e) => e.department == department).toList();
  }

  // Filter employees by status
  List<EmployeeModel> filterByStatus(bool isActive) {
    return _employees.where((e) => e.isActive == isActive).toList();
  }

  // Get unique departments
  List<String> getDepartments() {
    final departments = _employees.map((e) => e.department).toSet().toList();
    departments.sort();
    return departments;
  }

  // Get unique positions
  List<String> getPositions() {
    final positions = _employees.map((e) => e.position).toSet().toList();
    positions.sort();
    return positions;
  }

  // Get employees count by department
  Map<String, int> getEmployeeCountByDepartment() {
    final countMap = <String, int>{};
    for (final employee in _employees) {
      countMap[employee.department] = (countMap[employee.department] ?? 0) + 1;
    }
    return countMap;
  }

  // Get active employees count
  int get activeEmployeesCount => _employees.where((e) => e.isActive).length;

  // Get inactive employees count
  int get inactiveEmployeesCount => _employees.where((e) => !e.isActive).length;

  // Check if employee code exists
  bool isEmployeeCodeExists(String code, [String? excludeId]) {
    return _employees.any((e) => 
      e.employeeCode.toLowerCase() == code.toLowerCase() && 
      e.id != excludeId
    );
  }

  // Check if employee email exists
  bool isEmployeeEmailExists(String email, [String? excludeId]) {
    return _employees.any((e) => 
      e.email.toLowerCase() == email.toLowerCase() && 
      e.id != excludeId
    );
  }

  // Refresh employees list
  Future<void> refresh() async {
    await loadEmployees();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

}
