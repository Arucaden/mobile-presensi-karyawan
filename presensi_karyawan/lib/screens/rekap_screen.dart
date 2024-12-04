import 'package:flutter/material.dart';
import 'package:presensi_karyawan/services/all_in_one_service.dart';
import 'package:presensi_karyawan/models/karyawan_model.dart';

class RekapScreen extends StatefulWidget {
  @override
  _RekapScreenState createState() => _RekapScreenState();
}

class _RekapScreenState extends State<RekapScreen> {
  final _aioService = AllInOneService(); // Replace with actual token
  bool isLoading = true;
  List<dynamic> _attendanceHistory = [];
  Map<String, dynamic>? _employeeData;
  bool _isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceHistory();
  }

  void _fetchAttendanceHistory() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _aioService.getAttendanceHistory();

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Summary',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const Divider(),
                              _buildSummaryItem(
                                'Total Hadir',
                                _employeeData?['total_hadir'] ?? 0,
                                Colors.green,
                              ),
                              _buildSummaryItem(
                                'Total Sakit',
                                _employeeData?['total_sakit'] ?? 0,
                                Colors.orange,
                              ),
                              _buildSummaryItem(
                                'Total Izin',
                                _employeeData?['total_izin'] ?? 0,
                                Colors.blue,
                              ),
                              _buildSummaryItem(
                                'Total Alpa',
                                _employeeData?['total_alpha'] ?? 0,
                                Colors.red,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Last Attendance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const Divider(),
                      _attendanceHistory.isEmpty
                          ? const Center(
                              child: Text('No history available.'),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _attendanceHistory.length,
                              itemBuilder: (context, index) {
                                final history = _attendanceHistory[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header tanggal dan AIS data
                                        Container(
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            color: Colors.deepPurple,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Tanggal: ${history['tanggal'] ?? '-'}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'Total Jam: ${history['total_jam'] ?? '-'}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Detail absensi
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // Check-in row
                                                  Row(
                                                    children: [
                                                      Icon(Icons.arrow_forward, color: Colors.deepPurple),
                                                      SizedBox(width: 4),
                                                      Text('Masuk: ${history['jam_masuk'] ?? '-'}'),
                                                    ],
                                                  ),
                                                  SizedBox(height: 8),
                                                  // Check-out row
                                                  Row(
                                                    children: [
                                                      Icon(Icons.arrow_back, color: Colors.red[300]),
                                                      SizedBox(width: 4),
                                                      Text('Pulang: ${history['jam_keluar'] ?? '-'}'),
                                                    ],
                                                  ),
                                                  SizedBox(height: 8),
                                                  // Notes container
                                                  Container(
                                                    width: double.infinity,
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.deepPurple[50],
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      'Keterangan: ${history['keterangan'] ?? 'tidak ada keterangan'}',
                                                      style: TextStyle(
                                                        fontStyle: FontStyle.italic,
                                                        color: Colors.deepPurple[400],
                                                      ),
                                                      softWrap: true,
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 3,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                );
                              },
                            ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryItem(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
