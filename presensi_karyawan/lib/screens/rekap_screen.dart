import 'package:flutter/material.dart';
import 'package:presensi_karyawan/services/api_service.dart';

class RekapScreen extends StatefulWidget {
  @override
  _RekapScreenState createState() => _RekapScreenState();
}

class _RekapScreenState extends State<RekapScreen> {
  final _authService = AuthService();
  String token = 'your-jwt-token'; // Replace with actual token
  bool isLoading = true;
  Map<String, dynamic>? rekapData;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchRekapData();
  }

  Future<void> fetchRekapData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await _authService.getAttendanceHistory();

    if (result['success'] == true) {
      setState(() {
        rekapData = result['data'];
        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = result['message'];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Recap'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : rekapData != null
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attendance Recap',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Employee ID: ${rekapData!['karyawan_id']}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Name: ${rekapData!['nama']}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Total Days: ${rekapData!['total_hari']}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Present Days: ${rekapData!['hadir']}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Absent Days: ${rekapData!['absen']}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : Center(child: Text('No data available')),
    );
  }
}