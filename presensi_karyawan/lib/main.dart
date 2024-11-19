import 'package:flutter/material.dart';
import 'package:presensi_karyawan/screens/login_screen.dart';
import 'package:presensi_karyawan/screens/history_screen.dart';
import 'package:presensi_karyawan/screens/rekap_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/history': (context) => HistoryScreen(),
        '/rekap' : (context) => RekapScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/history');
              },
              child: Text('View Attendance'),
            ),
            SizedBox(height: 16), // Spacer between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/rekap');
              },
              child: Text('Rekap Attendance'),
            ),
          ],
        ),
      ),
    );
  }
}
