import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/doc_gia.dart';
import '../services/api_service.dart';
import '../widgets/author_footer.dart';
import '../widgets/confirm.dart';
import '../widgets/library_card.dart';
import '../widgets/reader_photo.dart';

class ReaderFormScreen extends StatefulWidget {
  final DocGia? reader;
  const ReaderFormScreen({super.key, this.reader});

  @override
  State<ReaderFormScreen> createState() => _ReaderFormScreenState();
}

class _ReaderFormScreenState extends State<ReaderFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _hoten = TextEditingController(text: widget.reader?.hoten ?? '');
  late final _email = TextEditingController(text: widget.reader?.email ?? '');
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  late String _hinhanh = widget.reader?.hinhanh ?? '';
  bool _hide = true;
  bool _saving = false;

  bool get _edit => widget.reader != null;

  @override
  void dispose() {
    _hoten.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String _mimeOf(XFile f) {
    final n = (f.name.isNotEmpty ? f.name : f.path).toLowerCase();
    if (n.endsWith('.png')) return 'image/png';
    if (n.endsWith('.webp')) return 'image/webp';
    if (n.endsWith('.gif')) return 'image/gif';
    if (n.endsWith('.svg')) return 'image/svg+xml';
    return 'image/jpeg';
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final f = await ImagePicker().pickImage(
          source: source, maxWidth: 600, maxHeight: 800, imageQuality: 70);
      if (f == null) return;
      final bytes = await f.readAsBytes();
      setState(
          () => _hinhanh = 'data:${_mimeOf(f)};base64,${base64Encode(bytes)}');
    } catch (_) {
      if (mounted) showMsg(context, 'Không thể chọn ảnh', error: true);
    }
  }

  void _chooseImage() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.photo_library_rounded),
            title: const Text('Chọn từ thư viện'),
            onTap: () {
              Navigator.pop(ctx);
              _pick(ImageSource.gallery);
            },
          ),
          if (!kIsWeb)
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(ctx);
                _pick(ImageSource.camera);
              },
            ),
          if (_hinhanh.isNotEmpty)
            ListTile(
              leading: Icon(Icons.delete_outline_rounded,
                  color: Theme.of(ctx).colorScheme.error),
              title: Text('Xóa ảnh',
                  style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _hinhanh = '');
              },
            ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final api = ApiService.instance;
    try {
      if (_edit) {
        await api.updateReader(widget.reader!.id,
            email: _email.text.trim(),
            hoten: _hoten.text.trim(),
            hinhanh: _hinhanh,
            matkhau: _pass.text);
      } else {
        await api.createReader(
            email: _email.text.trim(),
            matkhau: _pass.text,
            hoten: _hoten.text.trim(),
            hinhanh: _hinhanh);
      }
      if (!mounted) return;
      showMsg(context, _edit ? 'Đã cập nhật độc giả' : 'Đã cấp thẻ mới');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) showMsg(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  DocGia get _preview => DocGia(
      id: widget.reader?.id ?? '',
      email: _email.text.trim().isEmpty ? 'email@thuvien.vn' : _email.text.trim(),
      hoten: _hoten.text,
      hinhanh: _hinhanh);

  Widget _photoFrame(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(children: [
      GestureDetector(
        onTap: _chooseImage,
        child: Container(
          width: 150,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: cs.primary.withValues(alpha: 0.6), width: 2),
            color: cs.primaryContainer.withValues(alpha: 0.3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _hinhanh.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Icon(Icons.add_a_photo_rounded,
                            size: 40, color: cs.primary),
                        const SizedBox(height: 8),
                        Text('Ảnh thẻ 3×4',
                            style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.w800)),
                      ])
                : ReaderPhoto(
                    reader: _preview, width: 146, radius: 0, hero: false),
          ),
        ),
      ),
      const SizedBox(height: 8),
      TextButton.icon(
        onPressed: _chooseImage,
        icon: const Icon(Icons.photo_camera_rounded, size: 18),
        label: const Text('Chạm để chọn ảnh thẻ'),
      ),
    ]);
  }

  Widget _fields(BuildContext context) {
    return Column(children: [
      TextFormField(
        controller: _hoten,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(
            labelText: 'Họ tên', prefixIcon: Icon(Icons.person_outline_rounded)),
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ tên' : null,
      ),
      const SizedBox(height: 14),
      TextFormField(
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(
            labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
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
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: 'Mật khẩu',
          helperText: _edit ? 'Để trống nếu không đổi' : null,
          prefixIcon: const Icon(Icons.lock_outline_rounded),
          suffixIcon: IconButton(
            icon: Icon(_hide
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined),
            onPressed: () => setState(() => _hide = !_hide),
          ),
        ),
        validator: (v) {
          final s = v ?? '';
          if (_edit && s.isEmpty) return null;
          if (s.isEmpty) return 'Vui lòng nhập mật khẩu';
          if (s.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
          return null;
        },
      ),
      const SizedBox(height: 14),
      TextFormField(
        controller: _confirm,
        obscureText: _hide,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => _save(),
        decoration: const InputDecoration(
            labelText: 'Xác nhận mật khẩu',
            prefixIcon: Icon(Icons.lock_reset_rounded)),
        validator: (v) {
          if (_edit && _pass.text.isEmpty) return null;
          if ((v ?? '') != _pass.text) return 'Mật khẩu xác nhận không khớp';
          return null;
        },
      ),
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white))
              : const Icon(Icons.save_rounded),
          label: Text(_edit ? 'Lưu thay đổi' : 'Cấp thẻ'),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final form = Form(
      key: _form,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: wide
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _photoFrame(context),
                  const SizedBox(width: 24),
                  Expanded(child: _fields(context)),
                ])
              : Column(children: [
                  _photoFrame(context),
                  const SizedBox(height: 16),
                  _fields(context),
                ]),
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
          title: Text(_edit ? 'Cập nhật độc giả' : 'Cấp thẻ độc giả mới')),
      bottomNavigationBar: const SafeArea(child: AuthorFooter()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: wide ? 1200 : 560),
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: form),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 5,
                        child: Column(children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 10, left: 4),
                              child: Text('Xem trước thẻ thư viện',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16)),
                            ),
                          ),
                          LibraryCard(reader: _preview),
                        ]),
                      ),
                    ],
                  )
                : form,
          ),
        ),
      ),
    );
  }
}
