// lib/screens/admin_tab_screen.dart
// Halaman Tab Admin untuk menampilkan daftar Admin dan pengujian operasi DELETE (termasuk Admin ID 850)

import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/admin.dart';
import '../services/admin_service.dart';
import 'detail_screen.dart';

class AdminTabScreen extends StatefulWidget {
  const AdminTabScreen({super.key});

  @override
  State<AdminTabScreen> createState() => _AdminTabScreenState();
}

class _AdminTabScreenState extends State<AdminTabScreen> {
  late Future<List<Admin>> _futureAdmins;

  @override
  void initState() {
    super.initState();
    _refreshAdmins();
  }

  void _refreshAdmins() {
    setState(() {
      _futureAdmins = AdminService.getAdmins();
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.deepPurple.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Action DELETE: Hapus Admin berdasarkan ID
  Future<void> _handleDeleteAdmin(int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus Admin ID $id?'),
        content: Text('Apakah Anda yakin ingin menghapus Admin "$name" (ID: $id)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus (DELETE)'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await AdminService.deleteAdmin(id);
        _refreshAdmins();
        if (success) {
          _showSnackBar('BERHASIL DELETE: Admin ID $id telah dihapus.');
        } else {
          _showSnackBar('Gagal menghapus Admin ID $id', isError: true);
        }
      } catch (e) {
        _showSnackBar('Gagal DELETE Admin: $e', isError: true);
      }
    }
  }

  // Action khusus "Hapus Admin ID 850"
  Future<void> _handleDeleteAdmin850() async {
    await _handleDeleteAdmin(adminId, 'Admin Utama NIM 850');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header Aksi Khusus Admin ID 850
          Container(
            color: Colors.deepPurple.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _handleDeleteAdmin850,
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('Hapus Admin ID 850'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DetailScreen(
                                id: adminId,
                                type: DetailType.admin,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.info),
                        label: const Text('Detail ID 850'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Daftar Admin dari getAdmins()
          Expanded(
            child: FutureBuilder<List<Admin>>(
              future: _futureAdmins,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 50, color: Colors.red),
                        const SizedBox(height: 12),
                        Text('Terjadi kesalahan: ${snapshot.error}'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _refreshAdmins,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                final admins = snapshot.data ?? [];

                if (admins.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Daftar Admin kosong.'),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await AdminService.resetToDefault();
                            _refreshAdmins();
                          },
                          icon: const Icon(Icons.restore),
                          label: const Text('Reset Data Admin Default'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _refreshAdmins();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: admins.length,
                    itemBuilder: (context, index) {
                      final admin = admins[index];
                      final isMyAdminId = admin.id == adminId;

                      return Card(
                        elevation: isMyAdminId ? 3 : 1,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isMyAdminId
                              ? BorderSide(color: Colors.deepPurple.shade400, width: 2)
                              : BorderSide.none,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: isMyAdminId ? Colors.deepPurple : Colors.deepPurple.shade100,
                            foregroundColor: isMyAdminId ? Colors.white : Colors.deepPurple,
                            child: Text(
                              admin.name.isNotEmpty ? admin.name[0].toUpperCase() : 'A',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  admin.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (isMyAdminId)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'NIM 850',
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ID: ${admin.id} | Email: ${admin.email}'),
                              Text('Dept: ${admin.department}', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailScreen(
                                  id: admin.id,
                                  type: DetailType.admin,
                                  initialAdmin: admin,
                                ),
                              ),
                            );
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Hapus Admin',
                            onPressed: () => _handleDeleteAdmin(admin.id, admin.name),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
