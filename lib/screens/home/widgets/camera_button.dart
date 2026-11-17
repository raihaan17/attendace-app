import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../services/permission_service.dart';
import '../../../services/storage_services.dart';
import '../../../utils/app_alert.dart';
import 'action_button.dart';

class CameraButton extends StatefulWidget {
  const CameraButton({
    super.key,
    required this.label,
    required this.photoType,
    required this.photoStorage,
    required this.onPhotoCaptured,
    this.isLoading = false,
    this.permissionService,
    this.imagePicker,
  });

  final String label;
  final String photoType;
  final PhotoStorage photoStorage;
  final Future<void> Function(String photoPath) onPhotoCaptured;
  final bool isLoading;
  final PermissionService? permissionService;
  final ImagePicker? imagePicker;

  @override
  State<CameraButton> createState() => _CameraButtonState();
}

class _CameraButtonState extends State<CameraButton> {
  late final PermissionService _permissionService =
      widget.permissionService ?? PermissionService();
  late final ImagePicker _imagePicker = widget.imagePicker ?? ImagePicker();
  bool _isCapturing = false;

  Future<void> _capture() async {
    if (_isCapturing || widget.isLoading) return;
    setState(() => _isCapturing = true);
    try {
      final granted = await _ensureCameraPermission();
      if (!granted || !mounted) return;

      final photo = await _imagePicker.pickImage(source: ImageSource.camera);
      if (photo == null || !mounted) return;

      final savedPath = await widget.photoStorage.savePhoto(
        photo.path,
        widget.photoType,
      );
      await widget.onPhotoCaptured(savedPath);
    } catch (error) {
      if (mounted) {
        _showMessage('Gagal mengambil atau menyimpan foto: $error');
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<bool> _ensureCameraPermission() async {
    var status = await _permissionService.requestCameraPermission();
    if (!mounted) return false;
    while (!status.isGranted) {
      if (status.isPermanentlyDenied || status.isRestricted) {
        if (!mounted) return false;
        final openSettings = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Izin kamera diperlukan'),
            content: const Text(
              'Aktifkan izin kamera melalui pengaturan aplikasi untuk '
              'mengambil foto presensi.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Buka pengaturan'),
              ),
            ],
          ),
        );
        if (!mounted || openSettings != true) return false;
        await _permissionService.openAppSettings();
        if (!mounted) return false;
        status = await _permissionService.getCameraPermissionStatus();
        if (!status.isGranted) return false;
        continue;
      }

      if (!mounted) return false;
      final retry = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Izin kamera diperlukan'),
          content: const Text(
            'Kamera dibutuhkan untuk mengambil foto saat masuk dan pulang.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
      if (!mounted || retry != true) return false;
      status = await _permissionService.requestCameraPermission();
      if (!mounted) return false;
    }
    return status.isGranted;
  }

  void _showMessage(String message) {
    showErrorAlert(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      label: widget.label,
      isLoading: widget.isLoading || _isCapturing,
      onPressed: _capture,
    );
  }
}
