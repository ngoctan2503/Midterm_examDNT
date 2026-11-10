import 'package:flutter/material.dart';
import '../models/doc_gia.dart';
import '../theme.dart';
import 'reader_photo.dart';

/// Thẻ thư viện kích thước thẻ tín dụng (tỉ lệ 1.586).
class LibraryCard extends StatelessWidget {
  final DocGia reader;
  final bool hero;
  const LibraryCard({super.key, required this.reader, this.hero = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: AspectRatio(
          aspectRatio: 1.586,
          child: LayoutBuilder(builder: (context, c) {
            final s = c.maxWidth / 460; // hệ số co giãn
            return Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0B4F4A), AppColors.teal, AppColors.emerald],
                ),
                borderRadius: BorderRadius.circular(20 * s),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.teal.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 10)),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(children: [
                Positioned(
                    top: -70 * s, right: -50 * s, child: _circle(220 * s, 0.10)),
                Positioned(
                    bottom: -90 * s,
                    left: -40 * s,
                    child: _circle(240 * s, 0.07)),
                Positioned(
                    top: 40 * s, right: 90 * s, child: _circle(60 * s, 0.08)),
                Padding(
                  padding: EdgeInsets.fromLTRB(18 * s, 14 * s, 18 * s, 12 * s),
                  child: Column(children: [
                    Row(children: [
                      Icon(Icons.local_library_rounded,
                          color: Colors.white, size: 18 * s),
                      SizedBox(width: 6 * s),
                      Expanded(
                        child: Text('THẺ THƯ VIỆN · LIBRACARD',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13 * s,
                                letterSpacing: 1.2 * s,
                                fontWeight: FontWeight.w800)),
                      ),
                    ]),
                    SizedBox(height: 10 * s),
                    Expanded(
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10 * s),
                                border:
                                    Border.all(color: Colors.white, width: 2 * s),
                              ),
                              child: ReaderPhoto(
                                  reader: reader,
                                  width: 68 * s,
                                  radius: 8 * s,
                                  hero: hero),
                            ),
                            SizedBox(width: 16 * s),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        reader.hoten.isEmpty
                                            ? 'HỌ TÊN ĐỘC GIẢ'
                                            : reader.hoten.toUpperCase(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17 * s,
                                            height: 1.15,
                                            fontWeight: FontWeight.w800)),
                                    SizedBox(height: 4 * s),
                                    Text(reader.email,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.9),
                                            fontSize: 12 * s)),
                                    const Spacer(),
                                    Text(
                                        'Mã thẻ: ${reader.id.isEmpty ? 'TV-????????' : reader.maThe}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: AppColors.amber,
                                            fontSize: 14 * s,
                                            fontWeight: FontWeight.w800)),
                                    SizedBox(height: 2 * s),
                                    Text('Đơn vị cấp: Thư viện số 23IT.EB089',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.85),
                                            fontSize: 11 * s)),
                                  ]),
                            ),
                          ]),
                    ),
                    SizedBox(height: 8 * s),
                    Container(
                      height: 28 * s,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 10 * s, vertical: 4 * s),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6 * s),
                      ),
                      child: CustomPaint(
                          painter: _BarcodePainter(reader.id.isEmpty
                              ? '0123456789abcdef'
                              : reader.id)),
                    ),
                  ]),
                ),
              ]),
            );
          }),
        ),
      ),
    );
  }

  Widget _circle(double d, double a) => Container(
        width: d,
        height: d,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: Colors.white.withValues(alpha: a)),
      );
}

/// Mã vạch giả lập: độ rộng vạch được suy ra từ các ký tự hex của id.
class _BarcodePainter extends CustomPainter {
  final String id;
  _BarcodePainter(this.id);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0B1715);
    final widths = <double>[];
    for (final ch in id.codeUnits) {
      final v = int.tryParse(String.fromCharCode(ch), radix: 16) ?? 7;
      widths.add(1.0 + (v % 4)); // vạch đen 1..4
      widths.add(1.0 + ((v ~/ 4) % 3)); // khoảng trắng 1..3
    }
    final total = widths.fold<double>(0, (a, b) => a + b);
    final unit = size.width / total;
    var x = 0.0;
    for (var i = 0; i < widths.length; i++) {
      final w = widths[i] * unit;
      if (i.isEven) {
        canvas.drawRect(Rect.fromLTWH(x, 0, w, size.height), paint);
      }
      x += w;
    }
  }

  @override
  bool shouldRepaint(_BarcodePainter old) => old.id != id;
}
