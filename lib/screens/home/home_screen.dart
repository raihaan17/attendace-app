import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/attendance_record.dart';
import '../../services/attendance_service.dart';
import '../../services/auth_services.dart';
import '../../services/storage_services.dart';
import '../../utils/app_alert.dart';
import '../auth/login_screen.dart';
import '../history/history_screen.dart';
import 'widgets/attendance_card.dart';
import 'widgets/camera_button.dart';
import 'widgets/logout_dialog.dart';
import 'widgets/profile_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.authServices,
    required this.user,
    this.attendanceService,
    this.photoStorage,
  });

  final AuthServices authServices;
  final User user;
  final AttendanceService? attendanceService;
  final PhotoStorage? photoStorage;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final AttendanceService _attendanceService =
      widget.attendanceService ?? AttendanceService();
  late final AuthServices _auth = widget.authServices;
  late final PhotoStorage _photoStorage =
      widget.photoStorage ?? StorageServices();

  StreamSubscription<AttendanceRecord?>? _recordSubscription;
  AttendanceRecord? _todayRecord;
  Object? _streamError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenForTodayRecord();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _listenForTodayRecord();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recordSubscription?.cancel();
    super.dispose();
  }

  void _listenForTodayRecord() {
    _recordSubscription?.cancel();
    final userId = _auth.currentUser?.uid ?? widget.user.uid;
    _recordSubscription = _attendanceService
        .getTodayRecordStream(userId)
        .listen(
          (record) {
            if (!mounted) return;
            setState(() {
              _todayRecord = record;
              _streamError = null;
            });
          },
          onError: (Object error) {
            if (!mounted) return;
            setState(() => _streamError = error);
            showErrorAlert(context, 'Gagal memuat presensi: $error');
          },
        );
  }

  Future<void> _saveCheckIn(String photoPath) async {
    final user = _auth.currentUser;
    if (user == null) {
      _returnToLogin();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final record = AttendanceRecord(
        id: '',
        userId: user.uid,
        checkInTime: now,
        date: DateTime(now.year, now.month, now.day),
        checkInPhotoPath: photoPath,
      );
      await _attendanceService.createAttendanceRecord(record);
      if (mounted) {
        showSuccessAlert(context, 'Presensi masuk berhasil disimpan.');
      }
    } catch (error) {
      if (mounted) _showMessage('Gagal menyimpan presensi masuk: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCheckOut(String photoPath) async {
    final user = _auth.currentUser;
    if (user == null) {
      _returnToLogin();
      return;
    }
    final record = _todayRecord;
    if (record == null || record.userId != user.uid) {
      _showMessage('Presensi masuk hari ini tidak ditemukan. Muat ulang data.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final updated = record.copyWith(
        checkOutTime: DateTime.now(),
        checkOutPhotoPath: photoPath,
      );
      await _attendanceService.updateAttendanceRecord(updated);
      if (mounted) {
        showSuccessAlert(context, 'Presensi pulang berhasil disimpan.');
      }
    } catch (error) {
      if (mounted) _showMessage('Gagal menyimpan presensi pulang: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => const LogoutDialog(),
    );
    if (shouldLogout != true || !mounted) return;

    try {
      await _auth.signOut();
    } catch (error) {
      if (mounted) _showMessage('Gagal keluar dari akun: $error');
    }
  }

  void _returnToLogin() {
    Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(builder: (_) => LoginScreen(authServices: _auth)),
      (_) => false,
    );
  }

  void _showMessage(String message) {
    showErrorAlert(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final record = _todayRecord;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presensi Digital'),
        actions: [
          IconButton(
            tooltip: 'Riwayat',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => HistoryScreen(
                  userId: widget.user.uid,
                  attendanceService: _attendanceService,
                ),
              ),
            ),
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: 'Keluar',
            onPressed: _isLoading ? null : _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                DateFormat('EEEE, d MMMM y', 'id_ID').format(DateTime.now()),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ProfileCard(email: widget.user.email ?? 'Email tidak tersedia'),
              if (_streamError != null)
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: ListTile(
                    leading: const Icon(Icons.error_outline),
                    title: Text('Gagal memuat presensi: $_streamError'),
                    subtitle: const Text('Periksa koneksi penyimpanan lokal.'),
                    trailing: IconButton(
                      tooltip: 'Coba lagi',
                      onPressed: _listenForTodayRecord,
                      icon: const Icon(Icons.refresh),
                    ),
                  ),
                ),
              AttendanceCard(record: record),
              if (record == null)
                CameraButton(
                  label: 'Masuk',
                  photoType: 'checkin',
                  photoStorage: _photoStorage,
                  isLoading: _isLoading,
                  onPhotoCaptured: _saveCheckIn,
                )
              else if (record.checkOutTime == null)
                CameraButton(
                  label: 'Pulang',
                  photoType: 'checkout',
                  photoStorage: _photoStorage,
                  isLoading: _isLoading,
                  onPhotoCaptured: _saveCheckOut,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
