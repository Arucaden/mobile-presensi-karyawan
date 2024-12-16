import 'package:flutter/material.dart';
import 'package:presensi_karyawan/screens/face_detection_page.dart';
import 'package:presensi_karyawan/screens/login_screen.dart';
import 'package:presensi_karyawan/screens/history_screen.dart';
import 'package:presensi_karyawan/screens/rekap_screen.dart';
import 'package:presensi_karyawan/screens/settings_page.dart';
import 'package:presensi_karyawan/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Presensi',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      initialRoute: '/',
      routes: {
        '/' : (context) => const SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => const MainScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HistoryScreen(),
    RekapScreen(),
    const FaceDetectionPage(),
    const SettingsPage()
  ];

  // List judul halaman sesuai dengan tab
  final List<String> _titles = [
    'Riwayat Presensi',
    'Rekap Kehadiran',
    'Presensi Wajah',
    'Profil'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
      ),
      body: _pages[_currentIndex], // Menampilkan halaman sesuai index tab
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Mengubah tab yang aktif
          });
        },
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat Presensi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Rekap Kehadiran',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Presensi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}