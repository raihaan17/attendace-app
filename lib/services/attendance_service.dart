import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/attendance_record.dart';

class AttendanceService {
  factory AttendanceService() => _instance;

  AttendanceService._internal() {
    _initialized = _initStorage();
  }

  static final AttendanceService _instance = AttendanceService._internal();
  static const _storageKey = 'local_attendance_records_v1';

  final List<AttendanceRecord> _records = [];
  final Set<void Function()> _listeners = {};
  late final Future<void> _initialized;
  Future<void> _writeQueue = Future<void>.value();

  Future<void> _initStorage() async {
    final preferences = await SharedPreferences.getInstance();
    final savedRecords = preferences.getString(_storageKey);
    if (savedRecords == null) return;

    final decoded = jsonDecode(savedRecords) as List<dynamic>;
    _records
      ..clear()
      ..addAll(
        decoded.map(
          (item) =>
              AttendanceRecord.fromJson(Map<String, dynamic>.from(item as Map)),
        ),
      );
  }

  Stream<List<AttendanceRecord>> getAttendanceRecords(String userId) {
    return Stream<List<AttendanceRecord>>.multi((controller) {
      _subscribe(controller, () => _recordsForUser(userId));
    });
  }

  Stream<AttendanceRecord?> getTodayRecordStream(String userId) {
    return Stream<AttendanceRecord?>.multi((controller) {
      _subscribe(controller, () {
        final today = DateTime.now();
        for (final record in _recordsForUser(userId)) {
          if (_sameDate(record.date, today)) return record;
        }
        return null;
      });
    });
  }

  void _subscribe<T>(
    MultiStreamController<T> controller,
    T Function() readValue,
  ) {
    void emit() => controller.add(readValue());
    _listeners.add(emit);
    controller.onCancel = () => _listeners.remove(emit);
    _initialized.then(
      (_) {
        if (_listeners.contains(emit)) emit();
      },
      onError: (Object error, StackTrace stackTrace) {
        if (_listeners.contains(emit)) controller.addError(error, stackTrace);
      },
    );
  }

  Future<String> createAttendanceRecord(AttendanceRecord record) {
    return _serialize(() async {
      await _initialized;
      if (_records.any(
        (saved) =>
            saved.userId == record.userId && _sameDate(saved.date, record.date),
      )) {
        throw StateError('Presensi hari ini sudah ada.');
      }

      final id = DateTime.now().microsecondsSinceEpoch.toString();
      final newRecord = record.copyWith(id: id);
      final updatedRecords = [..._records, newRecord];
      await _persistRecords(updatedRecords);
      _records
        ..clear()
        ..addAll(updatedRecords);
      _emitUpdates();
      return id;
    });
  }

  Future<void> updateAttendanceRecord(AttendanceRecord record) {
    return _serialize(() async {
      await _initialized;
      final index = _records.indexWhere(
        (saved) => saved.id == record.id && saved.userId == record.userId,
      );
      if (index < 0) throw StateError('Presensi tidak ditemukan.');

      final updatedRecords = [..._records]..[index] = record;
      await _persistRecords(updatedRecords);
      _records
        ..clear()
        ..addAll(updatedRecords);
      _emitUpdates();
    });
  }

  Future<T> _serialize<T>(Future<T> Function() operation) {
    final result = Completer<T>();
    _writeQueue = _writeQueue.then((_) async {
      try {
        result.complete(await operation());
      } catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      }
    });
    return result.future;
  }

  Future<void> _persistRecords(List<AttendanceRecord> records) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(records.map((record) => record.toJson()).toList()),
    );
    if (!saved) throw StateError('Catatan presensi gagal disimpan.');
  }

  List<AttendanceRecord> _recordsForUser(String userId) =>
      _records.where((record) => record.userId == userId).toList();

  void _emitUpdates() {
    for (final listener in List<void Function()>.of(_listeners)) {
      listener();
    }
  }

  static bool _sameDate(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
