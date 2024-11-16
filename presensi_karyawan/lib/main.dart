import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/attendance_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Recognition Attendance',
      initialRoute: '/',
      routes: {
        '/': (context) => AttendanceScreen(),
      },
    );
  }
}
