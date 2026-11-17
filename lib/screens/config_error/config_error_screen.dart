import 'package:flutter/material.dart';

class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Presensi Digital',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B5B)),
      ),
      home: ConfigErrorScreen(error: error),
    );
  }
}

class ConfigErrorScreen extends StatelessWidget {
  const ConfigErrorScreen({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Pasang Firebase CLI',
      'Jalankan firebase login',
      'Jalankan dart pub global activate flutterfire_cli',
      'Jalankan flutterfire configure --project=ID_PROJECT_ANDA',
      'Jalankan ulang aplikasi',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Presensi Digital')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Firebase belum dikonfigurasi',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    const Text('Selesaikan langkah berikut secara berurutan:'),
                    const SizedBox(height: 12),
                    for (var index = 0; index < steps.length; index++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('${index + 1}. ${steps[index]}'),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
