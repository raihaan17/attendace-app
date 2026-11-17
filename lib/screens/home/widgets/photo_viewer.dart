import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class PhotoViewer extends StatelessWidget {
  const PhotoViewer({super.key, required this.photoPath});

  final String? photoPath;

  @override
  Widget build(BuildContext context) {
    final source = photoPath;
    final localFile = source == null || source.isEmpty ? null : File(source);
    if (localFile != null && localFile.existsSync()) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: InteractiveViewer(
            child: Image.file(
              localFile,
              errorBuilder: (_, _, _) => const _UnavailablePhoto(),
            ),
          ),
        ),
      );
    }

    final base64Data = _decodeBase64(source);
    if (base64Data != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: InteractiveViewer(
            child: Image.memory(
              base64Data,
              errorBuilder: (_, _, _) => const _UnavailablePhoto(),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: _UnavailablePhoto()),
    );
  }

  Uint8List? _decodeBase64(String? value) {
    if (value == null || value.isEmpty) return null;
    final data = value.startsWith('data:')
        ? value.substring(value.indexOf(',') + 1)
        : value;
    try {
      return base64Decode(data);
    } on FormatException {
      return null;
    }
  }
}

class _UnavailablePhoto extends StatelessWidget {
  const _UnavailablePhoto();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.image_not_supported_outlined, size: 56),
        SizedBox(height: 8),
        Text('Foto tidak tersedia'),
      ],
    );
  }
}
