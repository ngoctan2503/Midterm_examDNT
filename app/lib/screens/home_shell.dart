import 'package:flutter/material.dart';
import '../config.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/author_footer.dart';
import '../widgets/reader_photo.dart';
import 'dashboard_screen.dart';
import 'librarian_screen.dart';
import 'reader_list_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  void _goTo(int i) => setState(() => _index = i);

  static const _items = <({String label, IconData icon, IconData selected})>[
    (
      label: 'Tổng quan',
      icon: Icons.dashboard_outlined,
      selected: Icons.dashboard_rounded
    ),
    (
      label: 'Độc giả',
      icon: Icons.people_outline_rounded,
      selected: Icons.people_rounded
    ),
    (
      label: 'Thủ thư',
      icon: Icons.account_circle_outlined,
      selected: Icons.account_circle_rounded
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardScreen(onOpenReaders: () => _goTo(1)),
      const ReaderListScreen(),
      const LibrarianScreen(),
    ];
    final body = IndexedStack(index: _index, children: pages);
    final wide = MediaQuery.sizeOf(context).width >= 900;

    if (wide) {
      return Scaffold(
        body: Row(children: [
          _Sidebar(index: _index, items: _items, onSelect: _goTo),
          Expanded(
            child: SafeArea(
              child: Column(children: [
                Expanded(child: body),
                const AuthorFooter(),
              ]),
            ),
          ),
        ]),
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          Expanded(child: body),
          const AuthorFooter(),
        ]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        destinations: [
          for (final i in _items)
            NavigationDestination(
                icon: Icon(i.icon),
                selectedIcon: Icon(i.selected),
                label: i.label),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final int index;
  final List<({String label, IconData icon, IconData selected})> items;
  final ValueChanged<int> onSelect;
  const _Sidebar(
      {required this.index, required this.items, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B3B38), Color(0xFF082725)],
        ),
      ),
      child: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  gradient: AppColors.gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_library_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(AppConfig.appName,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.verified_rounded,
                    size: 14, color: AppColors.amber),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(AppConfig.author,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 28),
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              child: _tile(i),
            ),
          const Spacer(),
          const _MiniProfile(),
        ]),
      ),
    );
  }

  Widget _tile(int i) {
    final sel = i == index;
    final it = items[i];
    return Material(
      color: sel ? Colors.white.withValues(alpha: 0.14) : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onSelect(i),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(children: [
            Icon(sel ? it.selected : it.icon,
                color: sel ? AppColors.emerald : Colors.white70, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(it.label,
                  style: TextStyle(
                      color: sel ? Colors.white : Colors.white70,
                      fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 15)),
            ),
            if (sel)
              Container(
                width: 6,
                height: 22,
                decoration: BoxDecoration(
                    color: AppColors.amber,
                    borderRadius: BorderRadius.circular(4)),
              ),
          ]),
        ),
      ),
    );
  }
}

class _MiniProfile extends StatelessWidget {
  const _MiniProfile();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: auth,
      builder: (context, _) {
        final u = auth.user;
        if (u == null) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            ReaderPhoto(reader: u, width: 32, radius: 6, hero: false),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.hoten,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13)),
                    Text(u.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 11)),
                  ]),
            ),
          ]),
        );
      },
    );
  }
}
