import 'package:flutter/material.dart';
import 'package:presensi_karyawan/services/all_in_one_service.dart';

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

  try {
    // Fetch both recap and history data simultaneously
    final rekapFuture = _aioService.getRekapByLoggedInUser();
    final historyFuture = _aioService.getAttendanceHistory();
    
    final results = await Future.wait([rekapFuture, historyFuture]);
    final rekapResult = results[0];
    final historyResult = results[1];

    setState(() {
      _isLoading = false;

      // Handle recap data
      if (rekapResult['success']) {
        final data = rekapResult['data'];
        _employeeData = {
          'karyawan_id': data['karyawan_id'] ?? 0,
          'bulan': data['bulan'] ?? '',
          'total_hadir': data['total_hadir'] ?? '00:00:00',
          'total_sakit': data['total_sakit'] ?? '00:00:00',
          'total_izin': data['total_izin'] ?? '00:00:00',
          'total_alpha': data['total_alpha'] ?? '00:00:00',
        };
      } else {
        errorMessage = rekapResult['message'] ?? 'Failed to fetch recap data.';
      }

      // Handle history data
      if (historyResult['success']) {
        _attendanceHistory = historyResult['data']['history'] ?? [];
      } else {
        errorMessage = historyResult['message'] ?? 'Failed to fetch history data.';
      }

      // Show error if either call failed
      if (errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage!)),
        );
      }
    });
  } catch (e) {
    setState(() {
      _isLoading = false;
      errorMessage = 'An error occurred while fetching data.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage!)),
      );
    });
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.deepPurple[50],
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
                              'Rekap Bulan Ini',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const Divider(),
                            _buildSummaryItem(
                              'Total Hadir',
                              _employeeData?['total_hadir'] ?? '00:00:00',
                              Colors.green,
                            ),
                            _buildSummaryItem(
                              'Total Sakit',
                              _employeeData?['total_sakit'] ?? '00:00:00',
                              Colors.orange,
                            ),
                            _buildSummaryItem(
                              'Total Izin',
                              _employeeData?['total_izin'] ?? '00:00:00',
                              Colors.blue,
                            ),
                            _buildSummaryItem(
                              'Total Alpha',
                              _employeeData?['total_alpha'] ?? '00:00:00',
                              Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Presensi Terakhir',
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
                                              'Total Jam: ${history['hadir'] ?? '-'}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(Icons.arrow_forward, color: Colors.deepPurple),
                                                    SizedBox(width: 4),
                                                    Text('Masuk: ${history['jam_masuk'] ?? '-'}'),
                                                  ],
                                                ),
                                                SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Icon(Icons.arrow_back, color: Colors.red[300]),
                                                    SizedBox(width: 4),
                                                    Text('Pulang: ${history['jam_keluar'] ?? '-'}'),
                                                  ],
                                                ),
                                                SizedBox(height: 8),
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
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
  );
}

Widget _buildSummaryItem(String title, String time, Color color) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          time,
          style: TextStyle(fontSize: 16, color: color),
        ),
      ],
    ),
  );
}

// Function to parse time "HH:MM:SS" to total minutes
int _parseTimeToMinutes(String time) {
  final parts = time.split(':');
  if (parts.length == 3) {
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    final seconds = int.tryParse(parts[2]) ?? 0;

    return (hours * 60) + minutes + (seconds ~/ 60); // Convert all to minutes
  }
  return 0; // Fallback in case of an invalid format
}

}
