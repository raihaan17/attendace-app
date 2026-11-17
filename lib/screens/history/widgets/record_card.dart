import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/attendance_record.dart';
import '../../home/widgets/photo_viewer.dart';

class RecordCard extends StatelessWidget {
  const RecordCard({super.key, required this.record});

  final AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('EEEE, d MMMM y', 'id_ID');
    final checkOut = record.checkOutTime;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatter.format(record.date),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text('Masuk: ${DateFormat('HH:mm').format(record.checkInTime)}'),
            Text(
              checkOut == null
                  ? 'Pulang: Belum pulang'
                  : 'Pulang: ${DateFormat('HH:mm').format(checkOut)}',
            ),
            if (record.totalHours case final duration?)
              Text('Durasi: ${_formatDuration(duration)}'),
            const SizedBox(height: 12),
            Row(
              children: [
                _RecordPhoto(
                  label: 'Foto masuk',
                  photoPath: record.checkInPhotoPath,
                ),
                if (record.checkOutTime != null) ...[
                  const SizedBox(width: 12),
                  _RecordPhoto(
                    label: 'Foto pulang',
                    photoPath: record.checkOutPhotoPath,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordPhoto extends StatelessWidget {
  const _RecordPhoto({required this.label, required this.photoPath});

  final String label;
  final String? photoPath;

  @override
  Widget build(BuildContext context) {
    final file = photoPath == null ? null : File(photoPath!);
    return Column(
      children: [
        InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => PhotoViewer(photoPath: photoPath),
            ),
          ),
          child: SizedBox(
            width: 76,
            height: 76,
            child: file != null && file.existsSync()
                ? Image.file(
                    file,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.image_not_supported_outlined),
                  )
                : const Icon(Icons.image_not_supported_outlined),
          ),
        ),
        Text(label),
      ],
    );
  }
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  return minutes == 0 ? '$hours jam' : '$hours jam $minutes menit';
}
