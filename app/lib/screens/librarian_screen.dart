import 'package:flutter/material.dart';
import '../config.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/confirm.dart';
import '../widgets/reader_photo.dart';

class LibrarianScreen extends StatelessWidget {
  const LibrarianScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final ok = await confirmDialog(context,
        title: 'Đăng xuất?',
        message: 'Bạn có chắc muốn đăng xuất khỏi hệ thống?',
        confirmText: 'Đăng xuất',
        danger: true,
        icon: Icons.logout_rounded);
    if (ok) await auth.logout();
  }

  Widget _line(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 18, color: AppColors.teal),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(TextSpan(children: [
              TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              TextSpan(text: value),
            ])),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final u = auth.user;
    return ListenableBuilder(
      listenable: auth,
      builder: (context, _) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.gradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(children: [
                if (u != null)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white),
                    child: ReaderPhoto(
                        reader: u, width: 84, radius: 10, hero: false),
                  ),
                const SizedBox(height: 12),
                Text(u?.hoten ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(u?.email ?? '',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9))),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text('Thủ thư',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_rounded),
                  title: const Text('Chế độ tối'),
                  value: auth.themeMode == ThemeMode.dark,
                  onChanged: auth.setDark,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.password_rounded),
                  title: const Text('Đổi mật khẩu'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => showDialog<void>(
                      context: context,
                      builder: (_) => const _ChangePasswordDialog()),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(Icons.logout_rounded, color: cs.error),
                  title: Text('Đăng xuất',
                      style: TextStyle(
                          color: cs.error, fontWeight: FontWeight.w700)),
                  onTap: () => _logout(context),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.school_rounded, color: cs.primary),
                        const SizedBox(width: 8),
                        const Text('Thông tin đồ án',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 16)),
                      ]),
                      const SizedBox(height: 10),
                      _line(Icons.assignment_rounded, 'Đề thi',
                          'Giữa kỳ - Lập trình đa nền tảng'),
                      _line(Icons.local_library_rounded, 'Đề tài',
                          'LibraCard - Quản lý độc giả thư viện'),
                      _line(Icons.person_rounded, 'Sinh viên',
                          'Đặng Ngọc Tân'),
                      _line(Icons.badge_rounded, 'MSSV', '23IT.EB089'),
                      _line(Icons.code_rounded, 'Công nghệ',
                          'Flutter • Node.js/Express • MongoDB'),
                    ]),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(AppConfig.appName,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _form = GlobalKey<FormState>();
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _hide = true;
  bool _loading = false;

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ApiService.instance.changePassword(_old.text, _new.text);
      if (!mounted) return;
      Navigator.pop(context);
      showMsg(context, 'Đổi mật khẩu thành công');
    } on ApiException catch (e) {
      if (mounted) showMsg(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
            icon: Icon(
                _hide ? Icons.visibility_outlined : Icons.visibility_off_outlined),
            onPressed: () => setState(() => _hide = !_hide)),
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Đổi mật khẩu'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                controller: _old,
                obscureText: _hide,
                decoration: _dec('Mật khẩu cũ'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Vui lòng nhập mật khẩu cũ' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _new,
                obscureText: _hide,
                decoration: _dec('Mật khẩu mới'),
                validator: (v) => (v == null || v.length < 6)
                    ? 'Mật khẩu mới tối thiểu 6 ký tự'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirm,
                obscureText: _hide,
                decoration: _dec('Xác nhận mật khẩu mới'),
                validator: (v) =>
                    v != _new.text ? 'Mật khẩu xác nhận không khớp' : null,
              ),
            ]),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: _loading ? null : () => Navigator.pop(context),
            child: const Text('Hủy')),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(96, 44)),
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Cập nhật'),
        ),
      ],
    );
  }
}
