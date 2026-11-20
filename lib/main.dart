// lib/main.dart
// Entry point utama aplikasi Pertemuan 8: Manajemen Data User & Admin (NIM 20240801085)

import 'package:flutter/material.dart';

import 'screens/admin_tab_screen.dart';
import 'screens/user_tab_screen.dart';
import 'services/admin_service.dart';
import 'services/user_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Manajemen Data User & Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const UserTabScreen(),
    const AdminTabScreen(),
  ];

  Future<void> _resetAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Data Awal?'),
        content: const Text(
          'Apakah Anda yakin ingin mengembalikan seluruh data User dan Admin ke versi awal default?',
        ),
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
            child: const Text('Reset All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await UserService.resetToDefault();
      await AdminService.resetToDefault();
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seluruh data User dan Admin berhasil di-reset!'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? 'Manajemen User (NIM 1557)' : 'Manajemen Admin (NIM 850)',
        ),
        backgroundColor: _currentIndex == 0 ? Colors.indigo : Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Informasi File JSON',
            onPressed: () async {
              final userPath = await UserService.getJsonFilePath();
              final adminPath = await AdminService.getJsonFilePath();
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Informasi Storage Lokal'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Data User tersimpan di:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SelectableText(
                            userPath,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Colors.indigo,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Data Admin tersimpan di:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SelectableText(
                            adminPath,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Reset Data ke Awal',
            onPressed: _resetAllData,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'User',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
        ],
      ),
    );
  }
}
