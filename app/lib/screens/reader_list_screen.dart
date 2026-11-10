import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/doc_gia.dart';
import '../services/api_service.dart';
import '../utils.dart';
import '../widgets/confirm.dart';
import '../widgets/reader_photo.dart';
import 'reader_card_screen.dart';
import 'reader_form_screen.dart';

enum _PhotoFilter { all, withPhoto, withoutPhoto }

class ReaderListScreen extends StatefulWidget {
  const ReaderListScreen({super.key});

  @override
  State<ReaderListScreen> createState() => _ReaderListScreenState();
}

class _ReaderListScreenState extends State<ReaderListScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  List<DocGia> _all = [];
  bool _loading = true;
  String? _error;
  bool _newest = false; // false = A–Z, true = mới nhất
  _PhotoFilter _filter = _PhotoFilter.all;
  int _reqId = 0;

  @override
  void initState() {
    super.initState();
    dataVersion.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    dataVersion.removeListener(_load);
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  List<DocGia> get _shown => switch (_filter) {
        _PhotoFilter.all => _all,
        _PhotoFilter.withPhoto => _all.where((e) => e.coAnh).toList(),
        _PhotoFilter.withoutPhoto => _all.where((e) => !e.coAnh).toList(),
      };

  Future<void> _load() async {
    if (!mounted) return;
    final id = ++_reqId;
    setState(() => _error = null);
    try {
      final list = await ApiService.instance
          .getReaders(q: _search.text.trim(), sort: _newest ? 'newest' : null);
      if (!mounted || id != _reqId) return;
      if (!_newest) {
        list.sort((a, b) => compareVietnameseName(a.hoten, b.hoten));
      }
      setState(() => _all = list);
    } on ApiException catch (e) {
      if (mounted && id == _reqId) setState(() => _error = e.message);
    } finally {
      if (mounted && id == _reqId) setState(() => _loading = false);
    }
  }

  void _onSearch(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _load);
    setState(() {});
  }

  Future<void> _add() async {
    final ok = await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (_) => const ReaderFormScreen()));
    if (ok == true) notifyDataChanged();
  }

  Future<void> _view(DocGia u) async {
    final changed = await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (_) => ReaderCardScreen(reader: u)));
    if (changed == true) notifyDataChanged();
  }

  Future<void> _edit(DocGia u) async {
    final ok = await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (_) => ReaderFormScreen(reader: u)));
    if (ok == true) notifyDataChanged();
  }

  Future<void> _delete(DocGia u) async {
    if (await confirmAndDeleteReader(context, u)) notifyDataChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.badge_rounded),
        label: const Text('Cấp thẻ mới'),
      ),
      body: Column(children: [
        _toolbar(context),
        Expanded(child: _body(context)),
      ]),
    );
  }

  Widget _toolbar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(children: [
        TextField(
          controller: _search,
          onChanged: _onSearch,
          decoration: InputDecoration(
            hintText: 'Tìm theo họ tên hoặc email...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _search.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _search.clear();
                      setState(() {});
                      _load();
                    }),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (final e in const [
              (_PhotoFilter.all, 'Tất cả'),
              (_PhotoFilter.withPhoto, 'Có ảnh thẻ'),
              (_PhotoFilter.withoutPhoto, 'Chưa có ảnh'),
            ])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(e.$2, softWrap: false),
                  selected: _filter == e.$1,
                  onSelected: (_) => setState(() => _filter = e.$1),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 6),
        Row(children: [
          Chip(
            avatar: Icon(Icons.people_rounded, size: 18, color: cs.primary),
            label: Text('${_shown.length} độc giả', softWrap: false),
            side: BorderSide.none,
            backgroundColor: cs.primaryContainer.withValues(alpha: 0.6),
          ),
          const Spacer(),
          SegmentedButton<bool>(
            showSelectedIcon: false,
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
            segments: const [
              ButtonSegment(
                  value: false,
                  icon: Icon(Icons.sort_by_alpha_rounded, size: 18),
                  label: Text('A–Z', softWrap: false)),
              ButtonSegment(
                  value: true,
                  icon: Icon(Icons.schedule_rounded, size: 18),
                  label: Text('Mới nhất', softWrap: false)),
            ],
            selected: {_newest},
            onSelectionChanged: (s) {
              setState(() => _newest = s.first);
              _load();
            },
          ),
        ]),
      ]),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return _centered(
        context,
        Icons.cloud_off_rounded,
        _error!,
        action: FilledButton.icon(
            onPressed: () {
              setState(() => _loading = true);
              _load();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Thử lại')),
        error: true,
      );
    }
    final list = _shown;
    if (list.isEmpty) {
      final searching =
          _search.text.trim().isNotEmpty || _filter != _PhotoFilter.all;
      return _centered(
        context,
        searching ? Icons.search_off_rounded : Icons.group_off_rounded,
        searching
            ? 'Không tìm thấy độc giả phù hợp'
            : 'Chưa có độc giả nào',
        action: searching
            ? null
            : FilledButton.icon(
                onPressed: _add,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Cấp thẻ mới')),
      );
    }
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return RefreshIndicator(
      onRefresh: _load,
      child: wide ? _table(context, list) : _cards(context, list),
    );
  }

  // ---------- Bảng (màn hình rộng) ----------
  Widget _table(BuildContext context, List<DocGia> list) {
    final cs = Theme.of(context).colorScheme;
    final head = TextStyle(
        fontWeight: FontWeight.w800,
        color: cs.onSurfaceVariant,
        fontSize: 13);
    Widget cell(int flex, Widget child) => Expanded(flex: flex, child: child);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(children: [
            Container(
              color: cs.primaryContainer.withValues(alpha: 0.4),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                SizedBox(width: 56, child: Text('Ảnh', style: head)),
                cell(3, Text('Họ tên', style: head)),
                cell(3, Text('Email', style: head)),
                cell(2, Text('Mã thẻ', style: head)),
                SizedBox(
                    width: 132,
                    child: Text('Thao tác',
                        textAlign: TextAlign.center, style: head)),
              ]),
            ),
            for (var i = 0; i < list.length; i++) ...[
              if (i > 0) Divider(height: 1, color: cs.outlineVariant),
              _row(context, list[i], i),
            ],
          ]),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, DocGia u, int i) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => _view(u),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          SizedBox(
              width: 56,
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: ReaderPhoto(reader: u, width: 36, radius: 6))),
          Expanded(
            flex: 3,
            child: Text(u.hoten,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Expanded(
            flex: 3,
            child: Text(u.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: _codeChip(u))),
          SizedBox(
            width: 132,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(
                  tooltip: 'Xem thẻ',
                  icon: const Icon(Icons.visibility_outlined),
                  onPressed: () => _view(u)),
              IconButton(
                  tooltip: 'Cập nhật',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _edit(u)),
              IconButton(
                  tooltip: 'Thu hồi thẻ / Xóa',
                  icon: Icon(Icons.delete_outline_rounded, color: cs.error),
                  onPressed: () => _delete(u)),
            ]),
          ),
        ]),
      ),
    ).animate(delay: (25 * (i % 12)).ms).fadeIn(duration: 300.ms);
  }

  Widget _codeChip(DocGia u) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(u.maThe,
          maxLines: 1,
          softWrap: false,
          style: TextStyle(
              color: cs.primary, fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }

  // ---------- Danh sách thẻ (màn hình hẹp) ----------
  Widget _cards(BuildContext context, List<DocGia> list) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _card(list[i], i),
    );
  }

  Widget _centered(BuildContext context, IconData icon, String text,
      {Widget? action, bool error = false}) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (error ? cs.errorContainer : cs.primaryContainer)
                    .withValues(alpha: 0.6)),
            child:
                Icon(icon, size: 52, color: error ? cs.error : cs.primary),
          ),
          const SizedBox(height: 16),
          Text(text, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 16), action],
        ]).animate().fadeIn(duration: 300.ms),
      ),
    );
  }

  Widget _card(DocGia u, int i) {
    final cs = Theme.of(context).colorScheme;
    Widget card = Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _view(u),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          child: Row(children: [
            ReaderPhoto(reader: u, width: 48, radius: 8),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.hoten,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(u.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    _codeChip(u),
                  ]),
            ),
            PopupMenuButton<String>(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              onSelected: (v) {
                if (v == 'view') _view(u);
                if (v == 'edit') _edit(u);
                if (v == 'delete') _delete(u);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'view',
                    child: ListTile(
                        leading: Icon(Icons.visibility_outlined),
                        title: Text('Xem'))),
                const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Sửa'))),
                PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                        leading: Icon(Icons.delete_outline_rounded,
                            color: cs.error),
                        title:
                            Text('Xóa', style: TextStyle(color: cs.error)))),
              ],
            ),
          ]),
        ),
      ),
    );
    card = Dismissible(
      key: ValueKey('dismiss-${u.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await _delete(u);
        return false; // danh sách được tải lại sau khi xóa
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
            color: cs.error, borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.delete_rounded, color: cs.onError),
      ),
      child: card,
    );
    return card
        .animate(delay: (30 * (i % 12)).ms)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, end: 0);
  }
}
