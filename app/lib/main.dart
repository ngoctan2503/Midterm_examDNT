import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'config.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'theme.dart';
import 'widgets/gradient_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Tải font trước khi vẽ giao diện để tránh đo sai kích thước chữ (web)
  for (final w in [
    FontWeight.w400,
    FontWeight.w600,
    FontWeight.w700,
    FontWeight.w800
  ]) {
    GoogleFonts.nunito(fontWeight: w);
  }
  try {
    await GoogleFonts.pendingFonts().timeout(const Duration(seconds: 5));
  } catch (_) {}
  try {
    await initializeDateFormatting('vi');
  } catch (_) {}
  auth.init();
  runApp(const LibraCardApp());
}

class LibraCardApp extends StatelessWidget {
  const LibraCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: auth,
      builder: (context, _) {
        return MaterialApp(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: auth.themeMode,
          home: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: !auth.ready
                ? const _Splash(key: ValueKey('splash'))
                : auth.isLoggedIn
                    ? const HomeShell(key: ValueKey('home'))
                    : const LoginScreen(key: ValueKey('login')),
          ),
        );
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: GradientBackground(
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }
}
