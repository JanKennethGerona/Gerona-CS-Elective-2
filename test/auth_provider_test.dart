import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_ui/providers/auth_provider.dart';

void main() {
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    test('Initial state is not authenticated', () {
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.isGuestMode, isFalse);
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.errorMessage, isNull);
    });

    test('continueAsGuest sets guestMode to true', () {
      authProvider.continueAsGuest();
      expect(authProvider.isGuestMode, isTrue);
      expect(authProvider.isAuthenticated, isFalse);
    });

    test('signOut resets guestMode and user', () async {
      authProvider.continueAsGuest();
      expect(authProvider.isGuestMode, isTrue);

      await authProvider.signOut();
      expect(authProvider.isGuestMode, isFalse);
      expect(authProvider.isAuthenticated, isFalse);
    });
  });
}

