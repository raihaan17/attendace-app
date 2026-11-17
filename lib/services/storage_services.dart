import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

abstract class PhotoStorage {
  Future<String> savePhoto(String sourcePath, String photoType);
}

class StorageServices implements PhotoStorage {
  @override
  Future<String> savePhoto(String sourcePath, String photoType) async {
    if (photoType != 'checkin' && photoType != 'checkout') {
      throw ArgumentError.value(photoType, 'photoType');
    }

    final source = File(sourcePath);
    if (!await source.exists()) {
      throw FileSystemException('Foto sumber tidak ditemukan', sourcePath);
    }

    final documents = await getApplicationDocumentsDirectory();
    final photoDirectory = Directory(
      path.join(documents.path, 'attendance_photos'),
    );
    await photoDirectory.create(recursive: true);
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final destination = path.join(
      photoDirectory.path,
      '${timestamp}_$photoType.jpg',
    );

    final compressed = await FlutterImageCompress.compressWithFile(
      sourcePath,
      quality: 75,
      format: CompressFormat.jpeg,
    );
    if (compressed == null || compressed.isEmpty) {
      throw StateError('Foto gagal dikompres.');
    }

    await File(destination).writeAsBytes(compressed, flush: true);
    return destination;
  }

  // Meski bernama upload, versi ini hanya menyimpan lokal.
  Future<String> uploadAttendancePhoto(String sourcePath, String photoType) =>
      savePhoto(sourcePath, photoType);
}
