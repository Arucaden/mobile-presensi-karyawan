import 'package:flutter/material.dart';
import 'package:presensi_karyawan/services/auth_service.dart';

class SettingsPage extends StatelessWidget {
  final AuthService _authService = AuthService();

  SettingsPage({super.key});

  // Fungsi untuk mendapatkan inisial dari nama
  String getInitials(String name) {
    if (name.isEmpty) return "?";
    return name.trim()[0].toUpperCase(); // Ambil huruf pertama dan kapitalisasi
  }

  // Fungsi untuk menampilkan dialog konfirmasi logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog
                try {
                  await _authService.logout(); // Panggil fungsi logout
                  Navigator.pushReplacementNamed(context, '/login'); // Redirect ke halaman login
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout gagal: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple, // Warna tombol "Keluar"
              ),
              child: const Text('Keluar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String namaKaryawan = "Daffa Maulana"; // Contoh nama karyawan
    final String jabatanKaryawan = "UI/UX Designer"; // Contoh jabatan karyawan

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Foto profil, nama, dan jabatan
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.purple, // Warna latar belakang avatar
                  child: Text(
                    getInitials(namaKaryawan), // Inisial diambil dari nama
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      namaKaryawan,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      jabatanKaryawan,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            // Tombol Logout
            ElevatedButton(
              onPressed: () {
                _showLogoutDialog(context); // Tampilkan dialog konfirmasi
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}