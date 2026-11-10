import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libracard/models/doc_gia.dart';
import 'package:libracard/utils.dart';
import 'package:libracard/widgets/author_footer.dart';

void main() {
  testWidgets('AuthorFooter hiển thị thông tin tác giả', (tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AuthorFooter())));
    expect(find.textContaining('23IT.EB089 - Đặng Ngọc Tân'), findsOneWidget);
  });

  test('Mã thẻ được suy ra từ id', () {
    const r = DocGia(
        id: '6af2d59277c825a456b338f1', email: 'a@b.c', hoten: 'A', hinhanh: '');
    expect(r.maThe, 'TV-56B338F1');
  });

  test('removeDiacritics và sắp xếp tên tiếng Việt', () {
    expect(removeDiacritics('Đặng Ngọc Tân'), 'Dang Ngoc Tan');
    expect(removeDiacritics('ĐỖ THẢO NHI'), 'DO THAO NHI');
    final names = ['Đặng Ngọc Tân', 'Bùi Minh Khoa', 'Phan Ngọc Ánh']
      ..sort(compareVietnameseName);
    expect(names.first, 'Phan Ngọc Ánh');
  });
}
