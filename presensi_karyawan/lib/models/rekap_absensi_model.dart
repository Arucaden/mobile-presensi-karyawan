class RekapAbsensi {
  final int karyawanId;
  final String bulan;
  final String totalHadir;
  final String totalSakit;
  final String totalIzin;
  final String totalAlpha;

  RekapAbsensi({
    required this.karyawanId,
    required this.bulan,
    required this.totalHadir,
    required this.totalSakit,
    required this.totalIzin,
    required this.totalAlpha,
  });

  // Factory method to parse from JSON
  factory RekapAbsensi.fromJson(Map<String, dynamic> json) {
    return RekapAbsensi(
      karyawanId: json['karyawan_id'] ?? 0,
      bulan: json['bulan'] ?? '',
      totalHadir: json['total_hadir'] ?? '00:00:00',
      totalSakit: json['total_sakit'] ?? '00:00:00',
      totalIzin: json['total_izin'] ?? '00:00:00',
      totalAlpha: json['total_alpha'] ?? '00:00:00',
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'karyawan_id': karyawanId,
      'bulan': bulan,
      'total_hadir': totalHadir,
      'total_sakit': totalSakit,
      'total_izin': totalIzin,
      'total_alpha': totalAlpha,
    };
  }
}