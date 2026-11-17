import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/attendance_record.dart';
import 'photo_viewer.dart';

class AttendanceCard extends StatelessWidget {
  const AttendanceCard({super.key, required this.record});

  final AttendanceRecord? record;

  @override
  Widget build(BuildContext context) {
    final current = record;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: current == null
            ? const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Presensi hari ini'),
                  SizedBox(height: 8),
                  Text('Belum ada presensi hari ini'),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Presensi hari ini',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _AttendanceTime(
                    label: 'Jam masuk',
                    time: current.checkInTime,
                    photoPath: current.checkInPhotoPath,
                  ),
                  if (current.checkOutTime case final checkOut?) ...[
                    const Divider(height: 28),
                    _AttendanceTime(
                      label: 'Jam pulang',
                      time: checkOut,
                      photoPath: current.checkOutPhotoPath,
                    ),
                    const SizedBox(height: 12),
                    Text('Durasi: ${_formatDuration(current.totalHours!)}'),
                    const SizedBox(height: 8),
                    const Text('Presensi hari ini selesai.'),
                  ],
                ],
              ),
      ),
    );
  }
}

class _AttendanceTime extends StatelessWidget {
  const _AttendanceTime({
    required this.label,
    required this.time,
    required this.photoPath,
  });

  final String label;
  final DateTime time;
  final String? photoPath;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(label), Text(DateFormat('HH:mm').format(time))],
          ),
        ),
        _PhotoThumbnail(photoPath: photoPath),
      ],
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  const _PhotoThumbnail({required this.photoPath});

  final String? photoPath;

  @override
  Widget build(BuildContext context) {
    final file = photoPath == null ? null : File(photoPath!);
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PhotoViewer(photoPath: photoPath),
        ),
      ),
      child: SizedBox(
        width: 56,
        height: 56,
        child: file != null && file.existsSync()
            ? Image.file(
                file,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.image_not_supported_outlined),
              )
            : const Icon(Icons.image_not_supported_outlined),
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  return minutes == 0 ? '$hours jam' : '$hours jam $minutes menit';
}
