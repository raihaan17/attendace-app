import 'package:attendance_app/screens/config_error/config_error_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('configuration error explains setup and shows original error', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ConfigErrorApp(error: 'Firebase belum dikonfigurasi untuk tes'),
    );

    expect(find.text('Firebase belum dikonfigurasi'), findsOneWidget);
    expect(find.textContaining('flutterfire configure'), findsOneWidget);
    expect(
      find.textContaining('Firebase belum dikonfigurasi untuk tes'),
      findsOneWidget,
    );
  });
}
