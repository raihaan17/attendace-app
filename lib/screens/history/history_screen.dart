import 'package:flutter/material.dart';

import '../../models/attendance_record.dart';
import '../../services/attendance_service.dart';
import '../../utils/app_alert.dart';
import 'widgets/record_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.userId,
    this.attendanceService,
  });

  final String userId;
  final AttendanceService? attendanceService;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _hasShownErrorAlert = false;

  late final Stream<List<AttendanceRecord>> _recordsStream =
      (widget.attendanceService ?? AttendanceService()).getAttendanceRecords(
        widget.userId,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat presensi')),
      body: StreamBuilder<List<AttendanceRecord>>(
        stream: _recordsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            if (!_hasShownErrorAlert) {
              _hasShownErrorAlert = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  showErrorAlert(
                    context,
                    'Gagal memuat riwayat presensi: ${snapshot.error}',
                  );
                }
              });
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Gagal memuat riwayat presensi: ${snapshot.error}'),
              ),
            );
          }
          _hasShownErrorAlert = false;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = [...?snapshot.data]
            ..sort((first, second) {
              return second.checkInTime.compareTo(first.checkInTime);
            });
          if (records.isEmpty) {
            return const Center(child: Text('Belum ada riwayat presensi'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) => RecordCard(record: records[index]),
          );
        },
      ),
    );
  }
}
