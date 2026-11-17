import 'dart:async';

import 'package:attendance_app/models/attendance_record.dart';
import 'package:attendance_app/services/attendance_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('streams live updates, serializes writes, and isolates users', () async {
    SharedPreferences.setMockInitialValues({});
    final service = AttendanceService();
    final date = DateTime.now();
    final checkIn = DateTime(date.year, date.month, date.day, 8);
    final firstRecord = AttendanceRecord(
      id: '',
      userId: 'user-a',
      checkInTime: checkIn,
      date: DateTime(date.year, date.month, date.day),
    );

    final update = Completer<AttendanceRecord?>();
    final subscription = service.getTodayRecordStream('user-a').listen((
      record,
    ) {
      if (record != null && !update.isCompleted) update.complete(record);
    });

    final firstWrite = service.createAttendanceRecord(firstRecord);
    final duplicateWrite = service.createAttendanceRecord(firstRecord);
    final firstId = await firstWrite;
    await expectLater(duplicateWrite, throwsA(isA<StateError>()));
    expect((await update.future)?.id, firstId);

    await service.createAttendanceRecord(
      firstRecord.copyWith(userId: 'user-b'),
    );
    expect(
      (await service.getAttendanceRecords('user-a').first).map((r) => r.userId),
      ['user-a'],
    );
    expect(
      (await service.getAttendanceRecords('user-b').first).map((r) => r.userId),
      ['user-b'],
    );
    await subscription.cancel();
  });
}
