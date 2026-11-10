import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/doc_gia.dart';
import '../theme.dart';

/// Ảnh thẻ độc giả: giải mã data URI (SVG hoặc ảnh raster), thiếu ảnh thì
/// hiển thị chữ cái đầu trên nền gradient.
class ReaderPhoto extends StatelessWidget {
  final DocGia reader;
  final double width;
  final double height;
  final double radius;
  final bool circle;
  final bool hero;

  /// Ảnh thẻ 3:4 (mặc định).
  const ReaderPhoto({
    super.key,
    required this.reader,
    this.width = 48,
    this.radius = 8,
    this.hero = true,
  })  : height = width * 4 / 3,
        circle = false;

  /// Ảnh tròn nhỏ.
  const ReaderPhoto.circle({
    super.key,
    required this.reader,
    double size = 40,
    this.hero = false,
  })  : width = size,
        height = size,
        radius = 0,
        circle = true;

  static ({String mime, Uint8List bytes})? decode(String uri) {
    if (!uri.startsWith('data:')) return null;
    final i = uri.indexOf(',');
    if (i < 0) return null;
    final meta = uri.substring(5, i);
    final mime = meta.split(';').first.toLowerCase();
    try {
      final data = uri.substring(i + 1);
      final bytes = meta.contains('base64')
          ? base64Decode(data)
          : Uint8List.fromList(utf8.encode(Uri.decodeComponent(data)));
      return (mime: mime, bytes: bytes);
    } catch (_) {
      return null;
    }
  }

  String get _initials {
    final parts = reader.hoten.trim().split(RegExp(r'\s+'))
      ..removeWhere((e) => e.isEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Widget _fallback() => Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: Text(_initials,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: width * 0.38)),
      );

  Widget _content() {
    final d = decode(reader.hinhanh);
    Widget img;
    if (d == null || d.bytes.isEmpty) {
      img = _fallback();
    } else if (d.mime.contains('svg')) {
      img = SvgPicture.memory(d.bytes,
          width: width,
          height: height,
          fit: BoxFit.cover,
          placeholderBuilder: (_) => _fallback());
    } else {
      img = Image.memory(d.bytes,
          width: width,
          height: height,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => _fallback());
    }
    final sized = SizedBox(width: width, height: height, child: img);
    return circle
        ? ClipOval(child: sized)
        : ClipRRect(borderRadius: BorderRadius.circular(radius), child: sized);
  }

  @override
  Widget build(BuildContext context) {
    final w = _content();
    if (!hero || reader.id.isEmpty) return w;
    return Hero(tag: 'photo-${reader.id}', child: w);
  }
}
