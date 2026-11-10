class DocGia {
  final String id;
  final String email;
  final String hoten;
  final String hinhanh;

  const DocGia({
    required this.id,
    required this.email,
    required this.hoten,
    required this.hinhanh,
  });

  factory DocGia.fromJson(Map<String, dynamic> j) => DocGia(
        id: (j['_id'] ?? '').toString(),
        email: (j['email'] ?? '').toString(),
        hoten: (j['hoten'] ?? '').toString(),
        hinhanh: (j['hinhanh'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() =>
      {'_id': id, 'email': email, 'hoten': hoten, 'hinhanh': hinhanh};

  /// Mã thẻ thư viện được suy ra từ _id (không lưu trong CSDL).
  String get maThe => id.length >= 8
      ? 'TV-${id.substring(id.length - 8).toUpperCase()}'
      : 'TV-${id.toUpperCase()}';

  bool get coAnh => hinhanh.isNotEmpty;
}
