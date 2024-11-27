class Karyawan {
  final int idKaryawan;
  final String nik;
  final String nama;
  final String alamat;
  final String tanggalLahir;
  final String agama;
  final String jenisKelamin;
  final String noTelepon;
  final String email;
  final String tanggalMasuk;
  final Posisi? posisi; // Posisi tetap menjadi objek Posisi

  Karyawan({
    required this.idKaryawan,
    required this.nik,
    required this.nama,
    required this.alamat,
    required this.tanggalLahir,
    required this.agama,
    required this.jenisKelamin,
    required this.noTelepon,
    required this.email,
    required this.tanggalMasuk,
    this.posisi,
  });

  factory Karyawan.fromJson(Map<String, dynamic> json) {
    return Karyawan(
      idKaryawan: json['id_karyawan'],
      nik: json['nik'],
      nama: json['nama'],
      alamat: json['alamat'],
      tanggalLahir: json['tanggal_lahir'],
      agama: json['agama'],
      jenisKelamin: json['jenis_kelamin'],
      noTelepon: json['no_telepon'],
      email: json['email'],
      tanggalMasuk: json['tanggal_masuk'],
      posisi: json['posisi'] != null ? Posisi.fromJson(json['posisi']) : null,
    );
  }
}

class Posisi {
  final int idPosisi;
  final String namaPosisi; // Ubah dari 'namaPosisi' menjadi 'namaPosisi' sesuai JSON
  final int jamKerjaPerHari;
  final int hariKerjaPerMinggu;
  final String jamMasuk;
  final String jamKeluar;

  Posisi({
    required this.idPosisi,
    required this.namaPosisi,
    required this.jamKerjaPerHari,
    required this.hariKerjaPerMinggu,
    required this.jamMasuk,
    required this.jamKeluar,
  });

  factory Posisi.fromJson(Map<String, dynamic> json) {
    return Posisi(
      idPosisi: json['id_posisi'],
      namaPosisi: json['posisi'], // Perhatikan atribut JSON
      jamKerjaPerHari: json['jam_kerja_per_hari'],
      hariKerjaPerMinggu: json['hari_kerja_per_minggu'],
      jamMasuk: json['jam_masuk'],
      jamKeluar: json['jam_keluar'],
    );
  }
}
