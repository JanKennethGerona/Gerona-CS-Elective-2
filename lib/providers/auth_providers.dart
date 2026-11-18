import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user_profile.dart';
import '../services/supabase_service.dart';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

final authStateProvider = StreamProvider<AuthState?>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return service.authStateChanges ?? const Stream.empty();
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  if (authState != null) return authState.session?.user;
  return ref.watch(supabaseServiceProvider).currentUser;
});

final userProfileProvider = FutureProvider<AppUserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final service = ref.watch(supabaseServiceProvider);
  final map = await service.fetchProfile(user.id);
  if (map == null) {
    return AppUserProfile(
      id: user.id,
      createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
      email: user.email ?? '',
      firstname: user.userMetadata?['firstname'] ?? '',
      lastname: user.userMetadata?['lastname'] ?? '',
      roleId: 1,
      roleName: 'customer',
    );
  }
  return AppUserProfile.fromJson(map);
});

final isAdminProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  return profile?.isAdmin ?? false;
});
