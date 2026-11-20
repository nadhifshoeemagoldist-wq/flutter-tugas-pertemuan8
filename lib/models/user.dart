// lib/models/user.dart
// Model data untuk User

class User {
  final int id;
  final String name;
  final String email;
  final String city;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.city,
  });

  /// Factory constructor untuk mengubah JSON Map menjadi objek User (aman terhadap null)
  factory User.fromJson(Map<String, dynamic> json) {
    String parsedCity = '';
    
    // Mengecek apakah city ada di dalam nested map address atau langsung pada root JSON
    if (json['address'] != null && json['address'] is Map) {
      parsedCity = json['address']['city']?.toString() ?? '';
    } else if (json['city'] != null) {
      parsedCity = json['city'].toString();
    }

    return User(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      city: parsedCity.isNotEmpty ? parsedCity : 'Indonesia',
    );
  }

  /// Mengubah objek User menjadi JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'city': city,
      'address': {
        'city': city,
      },
    };
  }
}
