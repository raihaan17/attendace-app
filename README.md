# Presensi Digital

Aplikasi Android untuk mencatat presensi masuk dan pulang dengan foto serta
melihat riwayat presensi milik akun yang sedang masuk. Data dan foto disimpan
secara lokal di perangkat.

## Menjalankan aplikasi

1. Pastikan Flutter dan perangkat/emulator Android siap dengan `flutter doctor`.
2. Ambil dependensi menggunakan `flutter pub get`.
3. Periksa perangkat menggunakan `flutter devices`.
4. Jalankan aplikasi menggunakan `flutter run`.

Sebelum Firebase disiapkan, aplikasi menampilkan layar **Firebase belum
dikonfigurasi** beserta langkah setup. Daftarkan aplikasi Android di Firebase
dengan applicationId `com.example.attendance_app`, lalu jalankan
`flutterfire configure --project=ID_PROJECT_ANDA`. Perintah tersebut akan
mengganti placeholder `lib/firebase_options.dart`. Jangan memasukkan kredensial
atau project ID ke dalam repositori.

## Peta struktur

```text
lib/
  main.dart
  firebase_options.dart
  models/
    attendance_record.dart
    user_profile.dart
  services/
    auth_services.dart
    attendance_service.dart
    firestore_service.dart
    storage_services.dart
    permission_service.dart
  wrapper/
    auth_wrapper.dart
  screens/
    config_error/
    auth/
    home/
    history/
test/
  models/
  widgets/
```

## Batasan versi ini

- Hanya mendukung alur akun, presensi masuk/pulang, foto, dan riwayat pribadi.
- Data presensi dan foto disimpan lokal; belum ada sinkronisasi Firestore.
- Tidak mencakup GPS, QR, dashboard/admin, verifikasi wajah, penggajian,
  ekspor laporan, shift, persetujuan izin, atau sinkronisasi cloud.
- Foto akan hilang jika data aplikasi dihapus.
- Uji kamera dan izin memerlukan perangkat Android nyata.
