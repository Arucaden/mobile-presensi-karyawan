import 'package:flutter/material.dart';
import 'package:presensi_karyawan/services/all_in_one_service.dart';
import 'package:presensi_karyawan/models/karyawan_model.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _aioService = AllInOneService();
  Karyawan? _karyawan;
  bool _isLoading = true;
  String _errorMessage = '';

  Future<void> _fetchKaryawanData() async {
    try {
      final data = await _aioService.fetchKaryawanData();
      setState(() {
        _karyawan = Karyawan.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Keluar'),
          content: const Text('Apakah anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _aioService.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout gagal: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: const Text('Keluar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchKaryawanData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _karyawan == null
                  ? const Center(child: Text('Data karyawan tidak ditemukan.'))
                  : Column(
                      children: [
                        // Header dengan gradien dan avatar
                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 210,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.purple, Colors.deepPurple],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                            ),
                            Center(
                              child: Column(
                                children: [
                                  const SizedBox(height: 48),
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      _karyawan!.nama.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _karyawan!.nama,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Informasi karyawan
                        ListTile(
                          leading: const Icon(Icons.cake, color: Colors.deepPurple),
                          title: Text('Tanggal Lahir: ${_karyawan!.tanggalLahir}'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.phone, color: Colors.deepPurple),
                          title: Text('No Telepon: ${_karyawan!.noTelepon}'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.email, color: Colors.deepPurple),
                          title: Text('Email: ${_karyawan!.email}'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.work, color: Colors.deepPurple),
                          title: Text('Jabatan: ${_karyawan!.posisi?.namaPosisi ?? "-"}'),
                        ),
                        const Spacer(),
                        // Padding around the Logout button
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            onPressed: () {
                              _showLogoutDialog(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[300],
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text(
                              'Keluar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}