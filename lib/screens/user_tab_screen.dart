// lib/screens/user_tab_screen.dart
// Halaman Tab User untuk menampilkan daftar dan pengujian CRUD (GET, POST, PUT, PATCH, DELETE)

import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'detail_screen.dart';

class UserTabScreen extends StatefulWidget {
  const UserTabScreen({super.key});

  @override
  State<UserTabScreen> createState() => _UserTabScreenState();
}

class _UserTabScreenState extends State<UserTabScreen> {
  late Future<List<User>> _futureUsers;

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  void _refreshUsers() {
    setState(() {
      _futureUsers = UserService.getUsers();
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.indigo.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Action POST: Tambah User baru dengan ID 1557
  Future<void> _handlePostUser() async {
    final nameController = TextEditingController(text: 'User Mahasiswa (NIM 1557)');
    final emailController = TextEditingController(text: 'nim1557@mahasiswa.ac.id');
    final cityController = TextEditingController(text: 'Jakarta');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('POST - Tambah User Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Akan membuat User baru dengan ID khusus: $userId (1499 + 58)',
                style: const TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'Kota',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.add),
            label: const Text('Simpan (POST)'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final newUser = await UserService.createUser(
          nameController.text.trim(),
          emailController.text.trim(),
          cityController.text.trim(),
          customId: userId,
        );
        _refreshUsers();
        _showSnackBar('BERHASIL POST: User Baru (ID ${newUser.id}) telah dibuat!');
      } catch (e) {
        _showSnackBar('Gagal POST User: $e', isError: true);
      }
    }
  }

  // Action PUT: Update User (Nama & Email)
  Future<void> _handlePutUser(User user) async {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final cityController = TextEditingController(text: user.city);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('PUT - Update User ID ${user.id}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Baru',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Baru',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'Kota',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.edit),
            label: const Text('Update (PUT)'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final updated = await UserService.updateUser(
          user.id,
          nameController.text.trim(),
          emailController.text.trim(),
          cityController.text.trim(),
        );
        _refreshUsers();
        _showSnackBar('BERHASIL PUT: User ID ${updated.id} di-update menjadi "${updated.name}" (${updated.email})');
      } catch (e) {
        _showSnackBar('Gagal PUT User: $e', isError: true);
      }
    }
  }

  // Action PATCH: Update Nama dengan akhiran " - Flutter Developer"
  Future<void> _handlePatchUser(User user) async {
    try {
      final patchedUser = await UserService.patchUser(
        user.id,
        user.name,
      );
      _refreshUsers();
      _showSnackBar('BERHASIL PATCH: Nama User ID ${user.id} diperbarui menjadi "${patchedUser.name}"');
    } catch (e) {
      _showSnackBar('Gagal PATCH User: $e', isError: true);
    }
  }

  // Action DELETE: Hapus User berdasarkan ID
  Future<void> _handleDeleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus User ID ${user.id}?'),
        content: Text('Apakah Anda yakin ingin menghapus user "${user.name}"?'),
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
        final success = await UserService.deleteUser(user.id);
        _refreshUsers();
        if (success) {
          _showSnackBar('BERHASIL DELETE: User ID ${user.id} telah dihapus.');
        } else {
          _showSnackBar('Gagal menghapus User ID ${user.id}', isError: true);
        }
      } catch (e) {
        _showSnackBar('Gagal DELETE User: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header Bar khusus Aksi Cepat
          Container(
            color: Colors.indigo.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _handlePostUser,
                    icon: const Icon(Icons.person_add),
                    label: const Text('POST (ID 1557)'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.indigo,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DetailScreen(
                            id: userId,
                            type: DetailType.user,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.info),
                    label: const Text('Detail ID 1557'),
                  ),
                ),
              ],
            ),
          ),

          // ListView dari getUsers()
          Expanded(
            child: FutureBuilder<List<User>>(
              future: _futureUsers,
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
                        Text('Terjadi error: ${snapshot.error}'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _refreshUsers,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                final users = snapshot.data ?? [];

                if (users.isEmpty) {
                  return const Center(
                    child: Text('Belum ada data User.'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _refreshUsers();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final isMyId = user.id == userId;

                      return Card(
                        elevation: isMyId ? 3 : 1,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isMyId
                              ? BorderSide(color: Colors.indigo.shade400, width: 2)
                              : BorderSide.none,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: isMyId ? Colors.indigo : Colors.indigo.shade100,
                            foregroundColor: isMyId ? Colors.white : Colors.indigo,
                            child: Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (isMyId)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'NIM ID',
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ID: ${user.id} | Email: ${user.email}'),
                              Text('Kota: ${user.city}', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailScreen(
                                  id: user.id,
                                  type: DetailType.user,
                                  initialUser: user,
                                ),
                              ),
                            );
                          },
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (action) {
                              if (action == 'PUT') {
                                _handlePutUser(user);
                              } else if (action == 'PATCH') {
                                _handlePatchUser(user);
                              } else if (action == 'DELETE') {
                                _handleDeleteUser(user);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'PUT',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: Colors.blue, size: 20),
                                    SizedBox(width: 8),
                                    Text('PUT (Update All)'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'PATCH',
                                child: Row(
                                  children: [
                                    Icon(Icons.build, color: Colors.orange, size: 20),
                                    SizedBox(width: 8),
                                    Text('PATCH (+ Developer)'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'DELETE',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red, size: 20),
                                    SizedBox(width: 8),
                                    Text('DELETE (Hapus)'),
                                  ],
                                ),
                              ),
                            ],
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
