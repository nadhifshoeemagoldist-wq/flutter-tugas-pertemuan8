// lib/services/user_service.dart
// Service untuk menangani operasi CRUD pada data User

import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart';

class UserService {
  static const String fileName = 'users.json';
  static const String webStorageKey = 'users_json';

  // Mendapatkan path file JSON lokal
  static Future<String> getJsonFilePath() async {
    if (kIsWeb) {
      return 'Browser LocalStorage (Web Chrome)\nKey: "$webStorageKey"';
    }
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  // Mendapatkan File objek untuk penyimpanan lokal
  static Future<io.File?> _getLocalFile() async {
    if (kIsWeb) return null;
    final directory = await getApplicationDocumentsDirectory();
    return io.File('${directory.path}/$fileName');
  }

  // Data default jika offline / belum ada data lokal
  static final List<Map<String, dynamic>> _defaultUsers = [
    {
      'id': 1,
      'name': 'Leanne Graham',
      'email': 'Sincere@april.biz',
      'address': {'city': 'Gwenborough'}
    },
    {
      'id': 2,
      'name': 'Ervin Howell',
      'email': 'Shanna@melissa.tv',
      'address': {'city': 'Wisokyburgh'}
    },
    {
      'id': 3,
      'name': 'Clementine Bauch',
      'email': 'Nathan@yesenia.net',
      'address': {'city': 'McKenziehaven'}
    },
    {
      'id': userId, // 1557
      'name': 'User Test NIM 1557',
      'email': 'user1557@mhs.ac.id',
      'address': {'city': 'Jakarta'}
    },
  ];

  // Membuka & membaca data JSON lokal
  static Future<List<Map<String, dynamic>>> _readJsonData() async {
    final prefs = await SharedPreferences.getInstance();

    if (kIsWeb) {
      final cached = prefs.getString(webStorageKey);
      if (cached != null && cached.isNotEmpty) {
        try {
          final decoded = jsonDecode(cached) as List<dynamic>;
          return decoded.cast<Map<String, dynamic>>();
        } catch (_) {}
      }
      final initialData = await _fetchFromApi();
      await prefs.setString(webStorageKey, jsonEncode(initialData));
      return initialData;
    }

    try {
      final file = await _getLocalFile();
      if (file != null && await file.exists()) {
        final contents = await file.readAsString();
        if (contents.trim().isNotEmpty) {
          final decoded = jsonDecode(contents) as List<dynamic>;
          return decoded.cast<Map<String, dynamic>>();
        }
      }

      final initialData = await _fetchFromApi();
      if (file != null) {
        await file.writeAsString(
          const JsonEncoder.withIndent('  ').convert(initialData),
        );
      }
      return initialData;
    } catch (_) {
      final cached = prefs.getString(webStorageKey);
      if (cached != null && cached.isNotEmpty) {
        final decoded = jsonDecode(cached) as List<dynamic>;
        return decoded.cast<Map<String, dynamic>>();
      }
      return List<Map<String, dynamic>>.from(_defaultUsers);
    }
  }

  // Mengambil data awal dari API online
  static Future<List<Map<String, dynamic>>> _fetchFromApi() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/users'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          final list = decoded.cast<Map<String, dynamic>>();
          // Pastikan User ID 1557 tersedia di daftar sampel jika belum ada
          if (!list.any((u) => u['id'] == userId)) {
            list.add({
              'id': userId,
              'name': 'User Mahasiswa (NIM 1557)',
              'email': 'nim1557@mahasiswa.ac.id',
              'address': {'city': 'Jakarta'}
            });
          }
          return list;
        }
      }
    } catch (e) {
      debugPrint('Error fetch API user: $e');
    }
    return List<Map<String, dynamic>>.from(_defaultUsers);
  }

  // Menyimpan data JSON lokal
  static Future<void> _writeJsonData(List<Map<String, dynamic>> users) async {
    final jsonString = const JsonEncoder.withIndent('  ').convert(users);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(webStorageKey, jsonString);

    if (!kIsWeb) {
      try {
        final file = await _getLocalFile();
        if (file != null) {
          await file.writeAsString(jsonString);
        }
      } catch (e) {
        debugPrint('Gagal menyimpan file lokal user: $e');
      }
    }
  }

  // GET: Ambil seluruh data User
  static Future<List<User>> getUsers() async {
    try {
      // Mengirim request GET ke API
      final response = await http
          .get(Uri.parse('$baseUrl/users'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        // Ambil data lokal untuk konsistensi update (POST/PUT/PATCH/DELETE)
        final localData = await _readJsonData();
        return localData.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil data user (Status: ${response.statusCode})');
      }
    } catch (e) {
      // Fallback ke data lokal jika koneksi terganggu/error
      final localData = await _readJsonData();
      return localData.map((json) => User.fromJson(json)).toList();
    }
  }

  // GET: Ambil detail User berdasarkan ID
  static Future<User> getUser(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/users/$id'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final localData = await _readJsonData();
        final found = localData.firstWhere(
          (u) => u['id'] == id,
          orElse: () => jsonDecode(response.body),
        );
        return User.fromJson(found);
      }
    } catch (_) {}

    // Fallback pencarian di data lokal
    final localUsers = await _readJsonData();
    final item = localUsers.firstWhere(
      (element) => element['id'] == id,
      orElse: () => throw Exception('User dengan ID $id tidak ditemukan'),
    );
    return User.fromJson(item);
  }

  // POST: Tambah User baru dengan ID (default 1557)
  static Future<User> createUser(
    String name,
    String email,
    String city, {
    int? customId,
  }) async {
    final newId = customId ?? userId;

    try {
      // Melakukan request HTTP POST
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'id': newId,
          'name': name,
          'email': email,
          'city': city,
        }),
      );

      // Cek status code (201 Created atau 200 OK)
      if (response.statusCode != 201 && response.statusCode != 200) {
        debugPrint('POST status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error POST user: $e');
    }

    // Simpan ke storage lokal agar persisten
    final users = await _readJsonData();
    
    // Hapus jika ID sudah ada sebelumnya untuk menghindari duplikasi
    users.removeWhere((u) => u['id'] == newId);

    final newUserMap = {
      'id': newId,
      'name': name,
      'email': email,
      'address': {'city': city},
      'city': city,
    };

    users.add(newUserMap);
    await _writeJsonData(users);

    return User.fromJson(newUserMap);
  }

  // PUT: Update name, email, dan city User
  static Future<User> updateUser(
    int id,
    String name,
    String email,
    String city,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$id'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'id': id,
          'name': name,
          'email': email,
          'city': city,
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('PUT status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error PUT user: $e');
    }

    final users = await _readJsonData();
    final index = users.indexWhere((u) => u['id'] == id);

    if (index == -1) {
      throw Exception('Gagal memperbarui: User dengan ID $id tidak ditemukan');
    }

    final updatedMap = {
      'id': id,
      'name': name,
      'email': email,
      'address': {'city': city},
      'city': city,
    };

    users[index] = updatedMap;
    await _writeJsonData(users);

    return User.fromJson(updatedMap);
  }

  // PATCH: Update name User dengan menambahkan " - Flutter Developer"
  static Future<User> patchUser(
    int id,
    String newName,
  ) async {
    // Menambahkan akhiran jika belum ada
    final formattedName = newName.contains(' - Flutter Developer')
        ? newName
        : '$newName - Flutter Developer';

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/users/$id'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'name': formattedName,
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('PATCH status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error PATCH user: $e');
    }

    final users = await _readJsonData();
    final index = users.indexWhere((u) => u['id'] == id);

    if (index == -1) {
      throw Exception('Gagal PATCH: User dengan ID $id tidak ditemukan');
    }

    final existing = Map<String, dynamic>.from(users[index]);
    existing['name'] = formattedName;

    users[index] = existing;
    await _writeJsonData(users);

    return User.fromJson(existing);
  }

  // DELETE: Hapus User berdasarkan ID
  static Future<bool> deleteUser(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$id'),
      );

      if (response.statusCode != 200) {
        debugPrint('DELETE status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error DELETE user: $e');
    }

    final users = await _readJsonData();
    final index = users.indexWhere((u) => u['id'] == id);

    if (index == -1) {
      return false;
    }

    users.removeAt(index);
    await _writeJsonData(users);

    return true;
  }

  // Reset data ke default awal
  static Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(webStorageKey);

    if (!kIsWeb) {
      try {
        final file = await _getLocalFile();
        if (file != null && await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }

    await _writeJsonData(List<Map<String, dynamic>>.from(_defaultUsers));
  }
}
