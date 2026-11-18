import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../utils/lego_theme.dart';
import '../../widgets/async_value_view.dart';

class CustomerAccountPage extends ConsumerStatefulWidget {
  const CustomerAccountPage({super.key});

  @override
  ConsumerState<CustomerAccountPage> createState() =>
      _CustomerAccountPageState();
}

class _CustomerAccountPageState extends ConsumerState<CustomerAccountPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstController;
  late final TextEditingController _lastController;
  bool _isSaving = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider).value;
    _firstController = TextEditingController(text: profile?.firstname ?? '');
    _lastController = TextEditingController(text: profile?.lastname ?? '');
  }

  @override
  void dispose() {
    _firstController.dispose();
    _lastController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        final service = ref.read(supabaseServiceProvider);
        await service.updateProfileName(
          userId: user.id,
          firstname: _firstController.text.trim(),
          lastname: _lastController.text.trim(),
        );
        ref.invalidate(userProfileProvider);
        setState(() => _isEditing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Builder profile updated!'),
              backgroundColor: LegoTheme.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: $e'),
            backgroundColor: LegoTheme.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: LegoTheme.plateBg,
      appBar: AppBar(
        backgroundColor: LegoTheme.red,
        title: const Text(
          'Builder Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
      body: AsyncValueView(
        value: profileAsync,
        data: (profile) {
          if (!_isEditing) {
            _firstController.text = profile?.firstname ?? '';
            _lastController.text = profile?.lastname ?? '';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: LegoTheme.yellow,
                      shape: BoxShape.circle,
                      border: Border.all(color: LegoTheme.blue, width: 3),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      (profile?.firstname.isNotEmpty == true)
                          ? profile!.firstname[0].toUpperCase()
                          : (user?.email?.isNotEmpty == true
                              ? user!.email![0].toUpperCase()
                              : 'B'),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: LegoTheme.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    profile?.displayName ?? 'Master Builder',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    user?.email ?? '',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: LegoTheme.blue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'ROLE: CUSTOMER',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Edit Profile Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDCD7CC), width: 1.5),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Profile Details',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                            if (!_isEditing)
                              TextButton.icon(
                                onPressed: () => setState(() => _isEditing = true),
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text('Edit'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _firstController,
                          enabled: _isEditing,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _lastController,
                          enabled: _isEditing,
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Required'
                              : null,
                        ),
                        if (_isEditing) ...[
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      setState(() => _isEditing = false),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: LegoTheme.blue,
                                  ),
                                  onPressed: _isSaving ? null : _updateProfile,
                                  child: _isSaving
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Save'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: LegoTheme.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => ref.read(supabaseServiceProvider).signOut(),
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
