// lib/services/admin_service.dart
// Service untuk menangani operasi data Admin

import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/admin.dart';

class AdminService {
  static const String fileName = 'admins.json';
  static const String webStorageKey = 'admins_json';

  // Mendapatkan path file JSON lokal Admin
  static Future<String> getJsonFilePath() async {
    if (kIsWeb) {
      return 'Browser LocalStorage (Web Chrome)\nKey: "$webStorageKey"';
    }
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  // Mendapatkan File objek untuk penyimpanan lokal Admin
  static Future<io.File?> _getLocalFile() async {
    if (kIsWeb) return null;
    final directory = await getApplicationDocumentsDirectory();
    return io.File('${directory.path}/$fileName');
  }

  // Data default Admin (termasuk Admin ID 850 sesuai NIM 20240801085)
  static final List<Map<String, dynamic>> _defaultAdmins = [
    {
      'id': adminId, // 850
      'name': 'Admin Utama (NIM 850)',
      'email': 'admin850@system.ac.id',
      'department': 'IT Infrastructure & Security',
    },
    {
      'id': 101,
      'name': 'Budi Santoso',
      'email': 'budi.admin@system.ac.id',
      'department': 'Human Resources',
    },
    {
      'id': 102,
      'name': 'Siti Rahmawati',
      'email': 'siti.admin@system.ac.id',
      'department': 'Finance & Accounting',
    },
    {
      'id': 103,
      'name': 'Ahmad Fauzi',
      'email': 'ahmad.fauzi@system.ac.id',
      'department': 'Academic Support',
    },
  ];

  // Membaca data JSON lokal Admin
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
      await prefs.setString(webStorageKey, jsonEncode(_defaultAdmins));
      return List<Map<String, dynamic>>.from(_defaultAdmins);
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

      if (file != null) {
        await file.writeAsString(
          const JsonEncoder.withIndent('  ').convert(_defaultAdmins),
        );
      }
      return List<Map<String, dynamic>>.from(_defaultAdmins);
    } catch (_) {
      final cached = prefs.getString(webStorageKey);
      if (cached != null && cached.isNotEmpty) {
        final decoded = jsonDecode(cached) as List<dynamic>;
        return decoded.cast<Map<String, dynamic>>();
      }
      return List<Map<String, dynamic>>.from(_defaultAdmins);
    }
  }

  // Menyimpan data JSON lokal Admin
  static Future<void> _writeJsonData(List<Map<String, dynamic>> admins) async {
    final jsonString = const JsonEncoder.withIndent('  ').convert(admins);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(webStorageKey, jsonString);

    if (!kIsWeb) {
      try {
        final file = await _getLocalFile();
        if (file != null) {
          await file.writeAsString(jsonString);
        }
      } catch (e) {
        debugPrint('Gagal menyimpan file lokal admin: $e');
      }
    }
  }

  // 1. Future<List<Admin>> getAdmins()
  // Memuat daftar seluruh Admin dengan HTTP GET ke endpoint /admins dan fallback mock data
  static Future<List<Admin>> getAdmins() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/admins'))
          .timeout(const Duration(seconds: 3));

      // Cek statusCode
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded.map((json) => Admin.fromJson(json)).toList();
        }
      } else {
        // Jika endpoint /admins tidak tersedia (misal status 404 pada jsonplaceholder)
        debugPrint('GET /admins returned HTTP status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching GET /admins: $e');
    }

    // Fallback ke penyimpanan JSON lokal persisten
    final localData = await _readJsonData();
    return localData.map((json) => Admin.fromJson(json)).toList();
  }

  // 2. Future<Admin> getAdmin(int id)
  // Memuat satu Admin berdasarkan ID dengan HTTP GET ke endpoint /admins/$id dan fallback
  static Future<Admin> getAdmin(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/admins/$id'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return Admin.fromJson(decoded);
      } else {
        debugPrint('GET /admins/$id returned HTTP status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching GET /admins/$id: $e');
    }

    // Fallback ke penyimpanan data lokal
    final admins = await _readJsonData();
    final item = admins.firstWhere(
      (element) => element['id'] == id,
      orElse: () => throw Exception('Admin dengan ID $id tidak ditemukan'),
    );
    return Admin.fromJson(item);
  }

  // 3. Future<bool> deleteAdmin(int id)
  // Menghapus Admin berdasarkan ID dengan HTTP DELETE ke endpoint /admins/$id dan update data lokal
  static Future<bool> deleteAdmin(int id) async {
    bool httpSuccess = false;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admins/$id'),
      ).timeout(const Duration(seconds: 3));

      // Memeriksa respon status code
      if (response.statusCode == 200 || response.statusCode == 204) {
        httpSuccess = true;
      } else {
        debugPrint('DELETE /admins/$id status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error DELETE /admins/$id: $e');
    }

    // Lakukan penghapusan pada data lokal persisten
    final admins = await _readJsonData();
    final index = admins.indexWhere((element) => element['id'] == id);

    if (index == -1) {
      return httpSuccess;
    }

    admins.removeAt(index);
    await _writeJsonData(admins);
    return true;
  }

  // Reset data Admin ke nilai awal
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

    await _writeJsonData(List<Map<String, dynamic>>.from(_defaultAdmins));
  }
}
