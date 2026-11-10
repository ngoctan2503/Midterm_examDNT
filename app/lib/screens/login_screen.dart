import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/author_footer.dart';
import '../widgets/confirm.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _hide = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await auth.login(_email.text.trim(), _pass.text);
    } on ApiException catch (e) {
      if (mounted) showMsg(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      body: wide ? _wide(context) : _narrow(context),
    );
  }

  // ---------- Màn hình rộng: chia đôi ----------
  Widget _wide(BuildContext context) {
    return Row(children: [
      Expanded(child: _brandPanel()),
      Expanded(
        child: SafeArea(
          child: Column(children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: _formBlock(context, title: true),
                  ),
                ),
              ),
            ),
            const AuthorFooter(),
          ]),
        ),
      ),
    ]);
  }

  Widget _brandPanel() {
    Widget bullet(IconData icon, String text) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Text(text,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ]),
        );
    final bullets = [
      (Icons.badge_rounded, 'Cấp thẻ độc giả nhanh chóng'),
      (Icons.photo_camera_front_rounded, 'Quản lý ảnh thẻ & thông tin'),
      (Icons.devices_rounded, 'Đồng bộ Web & Android'),
    ];
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B4F4A), AppColors.teal, AppColors.emerald],
        ),
      ),
      child: Stack(children: [
        Positioned(top: -90, right: -70, child: _blob(300, 0.10)),
        Positioned(bottom: -120, left: -80, child: _blob(360, 0.08)),
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4), width: 2),
                ),
                child: const Icon(Icons.local_library_rounded,
                    color: Colors.white, size: 68),
              )
                  .animate()
                  .scale(
                      duration: 700.ms,
                      curve: Curves.elasticOut,
                      begin: const Offset(0.5, 0.5)),
              const SizedBox(height: 22),
              const Text(AppConfig.appName,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Text('Hệ thống quản lý độc giả thư viện',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 32),
              for (var i = 0; i < bullets.length; i++)
                bullet(bullets[i].$1, bullets[i].$2)
                    .animate(delay: (200 + 120 * i).ms)
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: -0.1, end: 0),
              const SizedBox(height: 32),
              _authorBadge(),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _blob(double s, double a) => Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: Colors.white.withValues(alpha: a)),
      );

  Widget _authorBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: const Text(AppConfig.author,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13)),
      );

  // ---------- Màn hình hẹp ----------
  Widget _narrow(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(children: [
              ClipPath(
                clipper: _CurveClipper(),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                      24, MediaQuery.paddingOf(context).top + 28, 24, 64),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0B4F4A),
                        AppColors.teal,
                        AppColors.emerald
                      ],
                    ),
                  ),
                  child: Column(children: [
                    const Icon(Icons.local_library_rounded,
                            color: Colors.white, size: 60)
                        .animate()
                        .scale(
                            duration: 600.ms,
                            curve: Curves.elasticOut,
                            begin: const Offset(0.5, 0.5)),
                    const SizedBox(height: 8),
                    const Text(AppConfig.appName,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('Hệ thống quản lý độc giả thư viện',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    _authorBadge(),
                  ]),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -36),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(heightFactor: 1, child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Card(
                      elevation: 4,
                      shadowColor: Colors.black.withValues(alpha: 0.15),
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: _formBlock(context, title: false),
                      ),
                    ),
                  )),
                ),
              ),
            ]),
          ),
        ),
        const AuthorFooter(),
      ]),
    );
  }

  // ---------- Form dùng chung ----------
  Widget _formBlock(BuildContext context, {required bool title}) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Form(
      key: _form,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Đăng nhập thủ thư',
                style: (title ? t.headlineSmall : t.titleLarge)
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Vui lòng đăng nhập để quản lý độc giả',
                style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 22),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined)),
              validator: (v) {
                final s = v?.trim() ?? '';
                if (s.isEmpty) return 'Vui lòng nhập email';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)) {
                  return 'Email không hợp lệ';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _pass,
              obscureText: _hide,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(_hide
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _hide = !_hide),
                ),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Vui lòng nhập mật khẩu' : null,
            ),
            const SizedBox(height: 22),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white),
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('Đăng nhập'),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded,
                    size: 18, color: AppColors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'Tài khoản demo: thuthu@thuvien.vn / thuthu123',
                      style: t.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface)),
                ),
              ]),
            ),
          ]),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.08, end: 0);
  }
}

class _CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path()..lineTo(0, size.height - 40);
    p.quadraticBezierTo(
        size.width / 2, size.height + 20, size.width, size.height - 40);
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}
