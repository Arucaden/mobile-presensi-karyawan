import 'package:flutter/material.dart';
import 'package:presensi_karyawan/services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _authService = AuthService();
  bool _isLoading = true;
  List<dynamic> _attendanceHistory = [];
  Map<String, dynamic>? _employeeData;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceHistory();
  }

  void _fetchAttendanceHistory() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _authService.getAttendanceHistory();

    setState(() {
      _isLoading = false;

      if (result['success']) {
        _attendanceHistory = result['data']['history'];
        _employeeData = result['data']['karyawan'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance History'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _employeeData == null
              ? Center(child: Text('No employee data found'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Employee: ${_employeeData!['nama']}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      // Text('Position: ${_employeeData!['jabatan']}'),
                      Divider(),
                      Expanded(
                        child: _attendanceHistory.isEmpty
                            ? Center(child: Text('No attendance records found'))
                            : ListView.builder(
                                itemCount: _attendanceHistory.length,
                                itemBuilder: (context, index) {
                                  final attendance = _attendanceHistory[index];
                                  return Card(
                                    child: ListTile(
                                      title: Text('Date: ${attendance['tanggal']}'),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Check-in: ${attendance['absen_masuk'] ?? '-'}'),
                                          Text('Check-out: ${attendance['absen_keluar'] ?? '-'}'),
                                          Text('Present: ${attendance['hadir'] ?? '-'}'),
                                          Text('Note: ${attendance['keterangan'] ?? 'No notes available'}'),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
