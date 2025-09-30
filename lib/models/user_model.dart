import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String role;
  final String email;
  final String name;
  final List<String> permissions;
  final DateTime lastLogin;
  final bool isActive;
  final DateTime createdAt;
  final String department;

  UserModel({
    required this.id,
    required this.role,
    required this.email,
    required this.name,
    required this.permissions,
    required this.lastLogin,
    required this.isActive,
    required this.createdAt,
    required this.department,
  });

  // Factory constructor to create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      id: doc.id,
      role: data['role'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      permissions: List<String>.from(data['permissions'] ?? []),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      department: data['department'] ?? '',
    );
  }

  // Factory constructor to create UserModel from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      role: map['role'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      permissions: List<String>.from(map['permissions'] ?? []),
      lastLogin: map['lastLogin'] is Timestamp 
          ? (map['lastLogin'] as Timestamp).toDate()
          : DateTime.parse(map['lastLogin'] ?? DateTime.now().toIso8601String()),
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      department: map['department'] ?? '',
    );
  }

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'email': email,
      'name': name,
      'permissions': permissions,
      'lastLogin': Timestamp.fromDate(lastLogin),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'department': department,
    };
  }

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'email': email,
      'name': name,
      'permissions': permissions,
      'lastLogin': lastLogin.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'department': department,
    };
  }

  // Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? id,
    String? role,
    String? email,
    String? name,
    List<String>? permissions,
    DateTime? lastLogin,
    bool? isActive,
    DateTime? createdAt,
    String? department,
  }) {
    return UserModel(
      id: id ?? this.id,
      role: role ?? this.role,
      email: email ?? this.email,
      name: name ?? this.name,
      permissions: permissions ?? this.permissions,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      department: department ?? this.department,
    );
  }

  // Check if user is admin
  bool get isAdmin => role == 'admin';

  // Check if user is accounting
  bool get isAccounting => role == 'accounting';

  // Check if user has specific permission
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  @override
  String toString() {
    return 'UserModel(id: $id, role: $role, email: $email, name: $name, isActive: $isActive, department: $department)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is UserModel &&
        other.id == id &&
        other.role == role &&
        other.email == email &&
        other.name == name &&
        other.isActive == isActive &&
        other.department == department;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        role.hashCode ^
        email.hashCode ^
        name.hashCode ^
        isActive.hashCode ^
        department.hashCode;
  }
}
