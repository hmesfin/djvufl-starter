import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/data/models/auth_models.dart';

/// These tests pin the mobile auth models to the ACTUAL Django REST contract,
/// which is snake_case. They guard against the camelCase/snake_case mismatch
/// that silently broke login: `getMe()` parsed `/api/users/me/` with camelCase
/// keys, threw a cast error on the missing `firstName`, and failed login even
/// though the JWT token grab succeeded.
void main() {
  group('Auth model API contract (snake_case Django REST)', () {
    test('UserModel.fromJson parses a real /api/users/me/ payload', () {
      // Exactly what backend UserSerializer returns:
      // fields = ["first_name", "last_name", "email", "url", "avatar"]
      // Note: NO is_email_verified key.
      final json = <String, dynamic>{
        'first_name': 'Ada',
        'last_name': 'Lovelace',
        'email': 'ada@example.com',
        'url': 'http://localhost:8000/api/users/abc-123/',
        'avatar': null,
      };

      final user = UserModel.fromJson(json);

      expect(user.firstName, 'Ada');
      expect(user.lastName, 'Lovelace');
      expect(user.email, 'ada@example.com');
      // Backend /me/ doesn't return it -> must default, not throw.
      expect(user.isEmailVerified, isFalse);
      expect(user.profilePicture, isNull);
    });

    test('UserModel maps avatar -> profilePicture', () {
      final user = UserModel.fromJson(<String, dynamic>{
        'first_name': 'Ada',
        'last_name': 'Lovelace',
        'email': 'ada@example.com',
        'avatar': 'http://localhost:8000/media/avatars/ada.png',
      });
      expect(user.profilePicture, 'http://localhost:8000/media/avatars/ada.png');
    });

    test('UserRegistrationRequest serializes to snake_case keys', () {
      final json = const UserRegistrationRequest(
        email: 'a@b.com',
        password: 'secret',
        firstName: 'Ada',
        lastName: 'Lovelace',
      ).toJson();

      expect(json['first_name'], 'Ada');
      expect(json['last_name'], 'Lovelace');
      expect(json.containsKey('firstName'), isFalse);
      expect(json.containsKey('lastName'), isFalse);
    });

    test('OtpVerificationRequest sends backend field "code"', () {
      final json = const OtpVerificationRequest(
        email: 'a@b.com',
        otpCode: '123456',
      ).toJson();

      // Backend EmailVerificationOTP serializer expects "code", not "otp_code".
      expect(json['code'], '123456');
      expect(json.containsKey('otpCode'), isFalse);
      expect(json.containsKey('otp_code'), isFalse);
    });

    test('PasswordResetOtpConfirmRequest sends "code"', () {
      final json = const PasswordResetOtpConfirmRequest(
        email: 'a@b.com',
        otpCode: '123456',
        password: 'newpass',
      ).toJson();

      expect(json['code'], '123456');
      expect(json.containsKey('otpCode'), isFalse);
    });
  });
}
