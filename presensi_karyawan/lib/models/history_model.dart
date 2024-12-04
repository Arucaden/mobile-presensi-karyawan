import 'dart:convert';

class AttendanceHistory {
  final int idAbsensi;
  final int karyawanId;
  final DateTime tanggal;
  final DateTime jam_masuk;
  final String jam_keluar;
  final int hadir;
  final String? keterangan;

  AttendanceHistory({
    required this.idAbsensi,
    required this.karyawanId,
    required this.tanggal,
    required this.jam_masuk,
    required this.jam_keluar,
    required this.hadir,
    this.keterangan,
  });

  // Factory untuk parsing dari JSON
  factory AttendanceHistory.fromJson(Map<String, dynamic> json) {
    return AttendanceHistory(
      idAbsensi: json['id_absensi'],
      karyawanId: json['karyawan_id'],
      tanggal: DateTime.parse(json['tanggal']),
      jam_masuk: json['jam_masuk'],
      jam_keluar: json['jam_keluar'],
      hadir: int.parse(json['total_hadir'].toString()),
      keterangan: json['keterangan'],
    );
  }

  // Method untuk mengonversi ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id_absensi': idAbsensi,
      'karyawan_id': karyawanId,
      'tanggal': tanggal.toIso8601String(),
      'absen_masuk': jam_masuk,
      'absen_keluar': jam_keluar,
      'hadir': hadir,
      'keterangan': keterangan,
    };
  }
}

// Fungsi untuk parsing list dari JSON
List<AttendanceHistory> parseAttendanceHistoryList(String responseBody) {
  final parsed = json.decode(responseBody)['history'] as List;
  return parsed.map((json) => AttendanceHistory.fromJson(json)).toList();
}