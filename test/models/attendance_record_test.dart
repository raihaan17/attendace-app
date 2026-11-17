import 'package:attendance_app/models/attendance_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final checkIn = DateTime(2026, 11, 12, 8);

  test('serializes and deserializes records with the required date format', () {
    final record = AttendanceRecord(
      id: '1',
      userId: 'user-1',
      checkInTime: checkIn,
      date: DateTime(2026, 11, 12),
    );

    final json = record.toJson();
    final restored = AttendanceRecord.fromJson(json);

    expect(json['date'], '2026-11-12');
    expect(restored.id, record.id);
    expect(restored.userId, record.userId);
    expect(restored.checkInTime, record.checkInTime);
  });

  test('copyWith adds checkout and calculates duration', () {
    final record = AttendanceRecord(
      id: '1',
      userId: 'user-1',
      checkInTime: checkIn,
      date: DateTime(2026, 11, 12),
    );

    expect(record.totalHours, isNull);
    expect(
      record.copyWith(checkOutTime: DateTime(2026, 11, 12, 16)).totalHours,
      const Duration(hours: 8),
    );
    expect(
      record.copyWith(checkOutTime: DateTime(2026, 11, 12, 16, 45)).totalHours,
      const Duration(hours: 8, minutes: 45),
    );
  });

  test('calculates an 8 hour 30 minute duration', () {
    final record = AttendanceRecord(
      id: '1',
      userId: 'user-1',
      checkInTime: DateTime(2026, 11, 12, 8, 15),
      checkOutTime: DateTime(2026, 11, 12, 16, 45),
      date: DateTime(2026, 11, 12),
    );

    expect(record.totalHours, const Duration(hours: 8, minutes: 30));
  });
}
