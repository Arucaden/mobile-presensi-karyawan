import 'dart:convert';

class AttendanceHistory {
  final int idAbsensi;
  final int karyawanId;
  final DateTime tanggal;
  final String absenMasuk;
  final String absenKeluar;
  final String hadir;
  final String sakit;
  final String izin;
  final String alpha;
  final String? keterangan;

  AttendanceHistory({
    required this.idAbsensi,
    required this.karyawanId,
    required this.tanggal,
    required this.absenMasuk,
    required this.absenKeluar,
    required this.hadir,
    required this.sakit,
    required this.izin,
    required this.alpha,
    this.keterangan,
  });

  // Factory untuk parsing dari JSON
  factory AttendanceHistory.fromJson(Map<String, dynamic> json) {
    return AttendanceHistory(
      idAbsensi: json['id_absensi'],
      karyawanId: json['karyawan_id'],
      tanggal: DateTime.parse(json['tanggal']),
      absenMasuk: json['absen_masuk'],
      absenKeluar: json['absen_keluar'],
      hadir: json['hadir'],
      sakit: json['sakit'],
      izin: json['izin'],
      alpha: json['alpha'],
      keterangan: json['keterangan'],
    );
  }

  // Method untuk mengonversi ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id_absensi': idAbsensi,
      'karyawan_id': karyawanId,
      'tanggal': tanggal.toIso8601String(),
      'absen_masuk': absenMasuk,
      'absen_keluar': absenKeluar,
      'hadir': hadir,
      'sakit': sakit,
      'izin': izin,
      'alpha': alpha,
      'keterangan': keterangan,
    };
  }
}

// Fungsi untuk parsing list dari JSON
List<AttendanceHistory> parseAttendanceHistoryList(String responseBody) {
  final parsed = json.decode(responseBody)['history'] as List;
  return parsed.map((json) => AttendanceHistory.fromJson(json)).toList();
}