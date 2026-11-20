// lib/models/admin.dart
// Model data untuk Admin

class Admin {
  final int id;
  final String name;
  final String email;
  final String department;

  Admin({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
  });

  /// Factory constructor untuk mengonversi JSON Map menjadi objek Admin (aman terhadap null)
  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      department: json['department']?.toString() ?? 'General Administration',
    );
  }

  /// Mengonversi objek Admin menjadi JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'department': department,
    };
  }
}
