import 'package:attendance_app/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializes and deserializes a profile', () {
    final profile = UserProfile(
      id: 'user-1',
      email: 'pengguna@example.com',
      fullName: 'Nama Pengguna',
      createdAt: DateTime(2026, 11, 12),
    );

    final json = profile.toJson();
    final restored = UserProfile.fromJson(json);

    expect(json['full_name'], 'Nama Pengguna');
    expect(restored.id, profile.id);
    expect(restored.email, profile.email);
    expect(restored.createdAt, profile.createdAt);
    expect(restored.role, 'Pengguna');
  });
}
