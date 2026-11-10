import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/doc_gia.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/reader_photo.dart';
import '../widgets/stat_card.dart';
import 'reader_card_screen.dart';
import 'reader_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onOpenReaders;
  const DashboardScreen({super.key, required this.onOpenReaders});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ReaderStats? _stats;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    dataVersion.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    dataVersion.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _error = null);
    try {
      final s = await ApiService.instance.getStats();
      if (mounted) setState(() => _stats = s);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _add() async {
    final ok = await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (_) => const ReaderFormScreen()));
    if (ok == true) notifyDataChanged();
  }

  String _today() {
    final now = DateTime.now();
    try {
      return DateFormat('EEEE, dd/MM/yyyy', 'vi').format(now);
    } catch (_) {
      return DateFormat('dd/MM/yyyy').format(now);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth >= 700;
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(children: [
                  _greeting(context)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 16),
                  if (_loading)
                    const Padding(
                        padding: EdgeInsets.all(48),
                        child: CircularProgressIndicator())
                  else if (_error != null && _stats == null)
                    _errorBox(context)
                  else ...[
                    _statsRow(wide),
                    const SizedBox(height: 16),
                    _progress(context),
                    const SizedBox(height: 16),
                    _newest(context),
                  ],
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _greeting(BuildContext context) {
    final u = auth.user;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppColors.gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppColors.teal.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 10))
        ],
      ),
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned(
          right: -30,
          top: -50,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1)),
          ),
        ),
        Row(children: [
          if (u != null)
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white),
              child: ReaderPhoto(reader: u, width: 60, radius: 10, hero: false),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Xin chào, ${u?.hoten ?? 'Thủ thư'}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 14, color: Colors.white.withValues(alpha: 0.9)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(_today(),
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                  ]),
                ]),
          ),
        ]),
      ]),
    );
  }

  Widget _statsRow(bool wide) {
    final s = _stats!;
    final cards = [
      StatCard(
          label: 'Tổng độc giả',
          value: s.total,
          icon: Icons.people_alt_rounded,
          colors: const [AppColors.teal, Color(0xFF2DD4BF)]),
      StatCard(
          label: 'Đã có ảnh thẻ',
          value: s.withImage,
          icon: Icons.verified_user_rounded,
          colors: const [Color(0xFF059669), AppColors.emerald]),
      StatCard(
          label: 'Chưa có ảnh thẻ',
          value: s.withoutImage,
          icon: Icons.no_photography_rounded,
          colors: const [Color(0xFFD97706), AppColors.amber]),
    ];
    final animated = [
      for (var i = 0; i < cards.length; i++)
        cards[i]
            .animate(delay: (100 * i).ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.2, end: 0)
    ];
    if (wide) {
      return Row(children: [
        for (var i = 0; i < animated.length; i++) ...[
          if (i > 0) const SizedBox(width: 14),
          Expanded(child: animated[i]),
        ]
      ]);
    }
    return Column(children: [
      for (var i = 0; i < animated.length; i++) ...[
        if (i > 0) const SizedBox(height: 12),
        animated[i],
      ]
    ]);
  }

  Widget _progress(BuildContext context) {
    final s = _stats!;
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final ratio = s.total == 0 ? 0.0 : s.withImage / s.total;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.donut_large_rounded, color: cs.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Tỉ lệ hoàn thiện ảnh thẻ',
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            ),
            Text('${(ratio * 100).round()}%',
                style: t.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800, color: cs.primary)),
          ]),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ratio),
              duration: const Duration(milliseconds: 700),
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 12,
                color: AppColors.emerald,
                backgroundColor: cs.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('${s.withImage}/${s.total} độc giả đã có ảnh thẻ',
              style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        ]),
      ),
    ).animate(delay: 250.ms).fadeIn(duration: 400.ms);
  }

  Widget _newest(BuildContext context) {
    final list = _stats!.newest;
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text('Độc giả mới đăng ký',
                    style:
                        t.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
            TextButton(
                onPressed: widget.onOpenReaders,
                child: const Text('Xem tất cả')),
          ]),
          const SizedBox(height: 4),
          if (list.isEmpty)
            const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('Chưa có độc giả nào')))
          else
            for (final u in list) _tile(u),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _add,
              icon: const Icon(Icons.badge_rounded),
              label: const Text('Cấp thẻ mới'),
            ),
          ),
        ]),
      ),
    ).animate(delay: 350.ms).fadeIn(duration: 400.ms);
  }

  Widget _tile(DocGia u) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: ReaderPhoto(reader: u, width: 36, radius: 6, hero: false),
        title: Text(u.hoten,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${u.email} · ${u.maThe}',
            maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () async {
          final changed = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                  builder: (_) => ReaderCardScreen(reader: u)));
          if (changed == true) notifyDataChanged();
        },
      );

  Widget _errorBox(BuildContext context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(children: [
          Icon(Icons.cloud_off_rounded,
              size: 56, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.icon(
              onPressed: () {
                setState(() => _loading = true);
                _load();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại')),
        ]),
      );
}
