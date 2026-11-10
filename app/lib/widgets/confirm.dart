import 'package:flutter/material.dart';
import '../models/doc_gia.dart';
import '../services/api_service.dart';

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Đồng ý',
  bool danger = false,
  IconData icon = Icons.help_outline_rounded,
}) async {
  final cs = Theme.of(context).colorScheme;
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: Icon(icon, size: 32, color: danger ? cs.error : cs.primary),
      title: Text(title, textAlign: TextAlign.center),
      content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Text(message, textAlign: TextAlign.center)),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy')),
        FilledButton(
          style: danger
              ? FilledButton.styleFrom(
                  backgroundColor: cs.error,
                  foregroundColor: cs.onError,
                  minimumSize: const Size(96, 44))
              : FilledButton.styleFrom(minimumSize: const Size(96, 44)),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return r ?? false;
}

void showMsg(BuildContext context, String msg, {bool error = false}) {
  final cs = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(msg,
          style: TextStyle(color: error ? cs.onError : cs.onInverseSurface)),
      backgroundColor: error ? cs.error : cs.inverseSurface,
    ));
}

/// Hỏi xác nhận rồi xóa. Trả về true nếu đã xóa.
Future<bool> confirmAndDeleteReader(BuildContext context, DocGia u) async {
  final ok = await confirmDialog(
    context,
    title: 'Thu hồi thẻ / Xóa độc giả?',
    message: 'Bạn có chắc muốn xóa "${u.hoten}" (${u.email})? '
        'Hành động này không thể hoàn tác.',
    confirmText: 'Thu hồi thẻ',
    danger: true,
    icon: Icons.delete_forever_rounded,
  );
  if (!ok || !context.mounted) return false;
  try {
    await ApiService.instance.deleteReader(u.id);
    if (context.mounted) showMsg(context, 'Đã thu hồi thẻ của "${u.hoten}"');
    return true;
  } on ApiException catch (e) {
    if (context.mounted) showMsg(context, e.message, error: true);
    return false;
  }
}
