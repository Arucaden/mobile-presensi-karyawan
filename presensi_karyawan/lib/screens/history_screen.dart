import 'package:flutter/material.dart';
import 'package:presensi_karyawan/services/all_in_one_service.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _aioService = AllInOneService();
  bool _isLoading = true;
  List<dynamic> _attendanceHistory = [];
  Map<String, dynamic>? _employeeData;

  // State untuk filter
  String _selectedMonth = '01'; // Default Januari
  String _selectedYear = DateTime.now().year.toString(); // Default tahun sekarang

  final List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

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
      backgroundColor: Colors.deepPurple[50],
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _employeeData == null
              ? Center(child: Text('No employee data found'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dropdown untuk memilih bulan dan tahun
                      Row(
                        children: [
                          // Dropdown untuk bulan
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _months[int.parse(_selectedMonth) - 1],
                              decoration: InputDecoration(
                                labelText: 'Pilih Bulan',
                                border: OutlineInputBorder(),
                              ),
                              items: _months.map((month) {
                                return DropdownMenuItem(
                                  value: month,
                                  child: Text(
                                    month,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedMonth =
                                      (_months.indexOf(value!) + 1).toString().padLeft(2, '0');
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Dropdown untuk tahun
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedYear,
                              decoration: InputDecoration(
                                labelText: 'Pilih Tahun',
                                border: OutlineInputBorder(),
                              ),
                              items: List.generate(5, (index) {
                                final year = (DateTime.now().year - index).toString();
                                return DropdownMenuItem(
                                  value: year,
                                  child: Text(
                                    year,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                );
                              }),
                              onChanged: (value) {
                                setState(() {
                                  _selectedYear = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Divider
                      Divider(),
                      // Menampilkan data absensi yang difilter
                      Expanded(
                        child: _attendanceHistory.isEmpty
                            ? Center(child: Text('Tidak ada data presensi'))
                            : _buildFilteredAttendanceList(),
                      ),
                    ],
                  ),
                ),
    );
  }

  // Fungsi untuk memfilter data berdasarkan bulan dan tahun yang dipilih
  Widget _buildFilteredAttendanceList() {
    final filteredData = _attendanceHistory.where((attendance) {
      final dateParts = attendance['tanggal'].split('-');
      final year = dateParts[0];
      final month = dateParts[1];
      return year == _selectedYear && month == _selectedMonth;
    }).toList();

    if (filteredData.isEmpty) {
      return Center(child: Text('Tidak ada data di bulan dan tahun yang dipilih.'));
    }

    return ListView.builder(
      itemCount: filteredData.length,
      itemBuilder: (context, index) {
        final attendance = filteredData[index];
        final date = attendance['tanggal'];
        final totalHours = attendance['jam'] ?? 0;
        final aisData = totalHours > 0 ? attendance['AIS'] : '-';

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
                        'Tanggal: $date',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Total Jam: $totalHours',
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
                              Text('Masuk: ${attendance['absen_masuk'] ?? '-'}'),
                            ],
                          ),
                          SizedBox(height: 8),
                          // Check-out row
                          Row(
                            children: [
                              Icon(Icons.arrow_back, color: Colors.red[300]),
                              SizedBox(width: 4),
                              Text('Pulang: ${attendance['absen_keluar'] ?? '-'}'),
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
                              'Keterangan: ${attendance['keterangan'] ?? 'tidak ada keterangan'}',
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
    );
  }
}
