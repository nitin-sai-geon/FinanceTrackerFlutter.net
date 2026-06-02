import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/provider/global_state.dart';
import 'package:finance_tracker/login_page.dart';
import 'package:finance_tracker/styles/homescreen_styles.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(currentUserProvider.notifier).fetchProfile());
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final initial = (user?['name']?.toString() ?? 'U')[0].toUpperCase();

    return Scaffold(
      backgroundColor: HomeScreenStyles.background,
      appBar: AppBar(
        backgroundColor: HomeScreenStyles.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 24,
        title: const Text('Profile', style: HomeScreenStyles.appBarTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () async {
                await ref.read(currentUserProvider.notifier).clearUser();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (_) => false,
                );
              },
              icon: const Icon(Icons.logout,
                  size: 18, color: HomeScreenStyles.secondary),
              label: const Text('Logout',
                  style: TextStyle(
                      color: HomeScreenStyles.secondary, fontSize: 14)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: HomeScreenStyles.primary,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: HomeScreenStyles.onPrimary,
                    fontSize: 34,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            _InfoRow(
              label: 'NAME',
              value: user?['name']?.toString() ?? '—',
            ),
            const SizedBox(height: 4),
            const Divider(color: HomeScreenStyles.borderSubtle),
            const SizedBox(height: 16),
            _InfoRow(
              label: 'USERNAME',
              value: user?['email']?.toString() ?? '—',
            ),
            const SizedBox(height: 4),
            const Divider(color: HomeScreenStyles.borderSubtle),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: HomeScreenStyles.background,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (_) => const _EditProfileModal(),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: HomeScreenStyles.borderSubtle),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.edit_outlined,
                    size: 18, color: HomeScreenStyles.secondary),
                label: const Text('Edit Profile',
                    style: TextStyle(
                        color: HomeScreenStyles.secondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: HomeScreenStyles.fieldLabel),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: HomeScreenStyles.onBackground,
          ),
        ),
      ],
    );
  }
}

class _EditProfileModal extends ConsumerStatefulWidget {
  const _EditProfileModal();

  @override
  ConsumerState<_EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends ConsumerState<_EditProfileModal> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController.text = user?['name']?.toString() ?? '';
    _emailController.text = user?['email']?.toString() ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_currentPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Current password is required to save changes')),
      );
      return;
    }
    setState(() => _isSaving = true);
    final success =
        await ref.read(currentUserProvider.notifier).updateProfile(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              currentPassword: _currentPasswordController.text,
              newPassword: _newPasswordController.text.isNotEmpty
                  ? _newPasswordController.text
                  : null,
            );
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Incorrect password — profile not updated'),
          backgroundColor: Colors.red[700],
        ),
      );
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: HomeScreenStyles.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text('Edit Profile',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: HomeScreenStyles.onBackground)),
          const SizedBox(height: 24),
          _ModalField(
            label: 'NAME',
            controller: _nameController,
            hint: 'Full name',
          ),
          const SizedBox(height: 20),
          _ModalField(
            label: 'USERNAME',
            controller: _emailController,
            hint: 'Email / username',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          _ModalField(
            label: 'CURRENT PASSWORD',
            controller: _currentPasswordController,
            hint: 'Required to save changes',
            obscure: _obscureCurrent,
            onToggleObscure: () =>
                setState(() => _obscureCurrent = !_obscureCurrent),
          ),
          const SizedBox(height: 20),
          _ModalField(
            label: 'NEW PASSWORD',
            controller: _newPasswordController,
            hint: 'Leave blank to keep current',
            obscure: _obscureNew,
            onToggleObscure: () =>
                setState(() => _obscureNew = !_obscureNew),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: HomeScreenStyles.primary,
                foregroundColor: HomeScreenStyles.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save Changes',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModalField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;

  const _ModalField({
    required this.label,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: HomeScreenStyles.fieldLabel),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(
              fontSize: 16, color: HomeScreenStyles.onBackground),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: HomeScreenStyles.subtitleMuted),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: HomeScreenStyles.borderSubtle),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide:
                  BorderSide(color: HomeScreenStyles.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            suffixIcon: onToggleObscure != null
                ? IconButton(
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: HomeScreenStyles.secondary,
                    ),
                    onPressed: onToggleObscure,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
