// lib/screens/detail_screen.dart
// Halaman Detail untuk memuat dan menampilkan informasi lengkap User atau Admin

import 'package:flutter/material.dart';

import '../models/admin.dart';
import '../models/user.dart';
import '../services/admin_service.dart';
import '../services/user_service.dart';

enum DetailType { user, admin }

class DetailScreen extends StatefulWidget {
  final int id;
  final DetailType type;
  final User? initialUser;
  final Admin? initialAdmin;

  const DetailScreen({
    super.key,
    required this.id,
    required this.type,
    this.initialUser,
    this.initialAdmin,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<dynamic> _futureDetail;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (widget.type == DetailType.user) {
      if (widget.initialUser != null) {
        _futureDetail = Future.value(widget.initialUser);
      } else {
        _futureDetail = UserService.getUser(widget.id);
      }
    } else {
      if (widget.initialAdmin != null) {
        _futureDetail = Future.value(widget.initialAdmin);
      } else {
        _futureDetail = AdminService.getAdmin(widget.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.type == DetailType.user;
    final titleText = isUser ? 'Detail User (ID: ${widget.id})' : 'Detail Admin (ID: ${widget.id})';

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        backgroundColor: isUser ? Colors.indigo : Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<dynamic>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal memuat detail data:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _loadData();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    )
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('Data tidak ditemukan.'));
          }

          User? user;
          Admin? admin;

          if (isUser && data is User) {
            user = data;
          } else if (!isUser && data is Admin) {
            admin = data;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: isUser
                            ? Colors.indigo.shade100
                            : Colors.deepPurple.shade100,
                        child: Text(
                          isUser
                              ? (user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U')
                              : (admin?.name.isNotEmpty == true ? admin!.name[0].toUpperCase() : 'A'),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isUser ? Colors.indigo : Colors.deepPurple,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        isUser ? (user?.name ?? '') : (admin?.name ?? ''),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Center(
                      child: Chip(
                        label: Text(
                          isUser ? 'Role: User' : 'Role: Admin',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: isUser ? Colors.indigo : Colors.deepPurple,
                      ),
                    ),
                    const Divider(height: 32),

                    // Detail items
                    _buildDetailRow(
                      icon: Icons.numbers,
                      label: 'ID',
                      value: '${isUser ? user?.id : admin?.id}',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.person,
                      label: 'Nama Lengkap',
                      value: isUser ? (user?.name ?? '-') : (admin?.name ?? '-'),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.email,
                      label: 'Email',
                      value: isUser ? (user?.email ?? '-') : (admin?.email ?? '-'),
                    ),
                    const SizedBox(height: 12),
                    if (isUser)
                      _buildDetailRow(
                        icon: Icons.location_city,
                        label: 'Kota / Alamat',
                        value: user?.city ?? '-',
                      )
                    else
                      _buildDetailRow(
                        icon: Icons.business,
                        label: 'Departemen',
                        value: admin?.department ?? '-',
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade700, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              SelectableText(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
