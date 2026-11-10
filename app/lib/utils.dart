const _from =
    'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ'
    'ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ';
const _to =
    'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd'
    'AAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';

/// Bỏ dấu tiếng Việt (gồm đ/Đ).
String removeDiacritics(String s) {
  final b = StringBuffer();
  for (final r in s.runes) {
    final ch = String.fromCharCode(r);
    final i = _from.indexOf(ch);
    b.write(i >= 0 ? _to[i] : ch);
  }
  return b.toString();
}

/// So sánh tên Việt: theo tên (từ cuối) rồi đến họ tên đầy đủ, không dấu.
int compareVietnameseName(String a, String b) {
  String last(String s) {
    final w = removeDiacritics(s.trim().toLowerCase()).split(RegExp(r'\s+'));
    return w.isEmpty ? '' : w.last;
  }

  final c = last(a).compareTo(last(b));
  if (c != 0) return c;
  return removeDiacritics(a.toLowerCase())
      .compareTo(removeDiacritics(b.toLowerCase()));
}
