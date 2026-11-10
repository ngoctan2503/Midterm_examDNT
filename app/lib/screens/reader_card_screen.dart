import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/doc_gia.dart';
import '../services/api_service.dart';
import '../widgets/author_footer.dart';
import '../widgets/confirm.dart';
import '../widgets/library_card.dart';
import 'reader_form_screen.dart';

class ReaderCardScreen extends StatefulWidget {
  final DocGia reader;
  const ReaderCardScreen({super.key, required this.reader});

  @override
  State<ReaderCardScreen> createState() => _ReaderCardScreenState();
}

class _ReaderCardScreenState extends State<ReaderCardScreen> {
  late DocGia _r = widget.reader;

  Future<void> _edit() async {
    final ok = await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (_) => ReaderFormScreen(reader: _r)));
    if (ok != true) return;
    notifyDataChanged();
    try {
      final u = await ApiService.instance.getReader(_r.id);
      if (mounted) setState(() => _r = u);
    } on ApiException catch (_) {}
  }

  Future<void> _delete() async {
    if (await confirmAndDeleteReader(context, _r)) {
      notifyDataChanged();
      if (mounted) Navigator.pop(context, true);
    }
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) showMsg(context, 'Đã sao chép');
  }

  Widget _info(BuildContext context, IconData icon, String label, String value,
      {Widget? trailing}) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cs.primaryContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: cs.primary),
      ),
      title: Text(label,
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
      subtitle: Text(value,
          style: TextStyle(
              color: cs.onSurface, fontWeight: FontWeight.w700, fontSize: 15)),
      trailing: trailing,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Thẻ thư viện')),
      bottomNavigationBar: const SafeArea(child: AuthorFooter()),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(padding: const EdgeInsets.all(16), children: [
            LibraryCard(reader: _r, hero: true),
            const SizedBox(height: 20),
            Card(
              child: Column(children: [
                _info(context, Icons.person_rounded, 'Họ tên', _r.hoten),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _info(context, Icons.email_rounded, 'Email', _r.email),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _info(context, Icons.lock_rounded, 'Mật khẩu',
                    '•••••••• (đã mã hóa bcrypt)'),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _info(context, Icons.badge_rounded, 'Mã thẻ', _r.maThe),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _info(context, Icons.fingerprint_rounded, 'Mã ID', _r.id,
                    trailing: IconButton(
                      tooltip: 'Sao chép',
                      icon: const Icon(Icons.copy_rounded),
                      onPressed: () => _copy(_r.id),
                    )),
              ]),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _edit,
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Cập nhật'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.error,
                    side: BorderSide(color: cs.error.withValues(alpha: 0.6)),
                  ),
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Thu hồi thẻ'),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}
