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
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.errorMessage, isNull);
    });

    test('signOut clears user session', () async {
      await authProvider.signOut();
      expect(authProvider.isAuthenticated, isFalse);
    });
  });
}

