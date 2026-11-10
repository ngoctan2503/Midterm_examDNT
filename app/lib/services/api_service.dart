import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/doc_gia.dart';

/// Tăng giá trị khi dữ liệu độc giả thay đổi để các màn hình tải lại.
final ValueNotifier<int> dataVersion = ValueNotifier<int>(0);
void notifyDataChanged() => dataVersion.value++;

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}

class ReaderStats {
  final int total, withImage, withoutImage;
  final List<DocGia> newest;
  ReaderStats(this.total, this.withImage, this.withoutImage, this.newest);
}

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  String? token;
  void Function()? onUnauthorized;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Uri _uri(String path, [Map<String, String>? q]) =>
      Uri.parse('${AppConfig.baseUrl}$path').replace(queryParameters: q);

  Future<dynamic> _send(Future<http.Response> Function() call,
      {bool authed = true}) async {
    http.Response res;
    try {
      res = await call().timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw ApiException('Hết thời gian chờ, vui lòng thử lại');
    } catch (_) {
      throw ApiException(
          'Không thể kết nối máy chủ. Hãy kiểm tra backend (cổng 3000)');
    }
    dynamic body;
    try {
      body = res.body.isEmpty ? null : jsonDecode(utf8.decode(res.bodyBytes));
    } catch (_) {
      body = null;
    }
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    final msg = (body is Map && body['message'] != null)
        ? body['message'].toString()
        : 'Đã xảy ra lỗi (${res.statusCode})';
    if (res.statusCode == 401 && authed && token != null) {
      onUnauthorized?.call();
    }
    throw ApiException(msg, res.statusCode);
  }

  Future<({String token, DocGia user})> login(String email, String matkhau) async {
    final b = await _send(
      () => http.post(_uri('/api/auth/login'),
          headers: _headers,
          body: jsonEncode({'email': email, 'matkhau': matkhau})),
      authed: false,
    );
    return (
      token: b['token'].toString(),
      user: DocGia.fromJson(Map<String, dynamic>.from(b['user']))
    );
  }

  Future<DocGia> me() async {
    final b = await _send(() => http.get(_uri('/api/auth/me'), headers: _headers));
    return DocGia.fromJson(Map<String, dynamic>.from(b));
  }

  Future<void> changePassword(String old, String neu) async {
    await _send(() => http.put(_uri('/api/auth/change-password'),
        headers: _headers,
        body: jsonEncode({'matkhauCu': old, 'matkhauMoi': neu})));
  }

  Future<List<DocGia>> getReaders({String q = '', String? sort}) async {
    final params = <String, String>{
      if (q.isNotEmpty) 'q': q,
      'sort': ?sort,
    };
    final b = await _send(
        () => http.get(_uri('/api/docgia', params), headers: _headers));
    return (b['data'] as List)
        .map((e) => DocGia.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<ReaderStats> getStats() async {
    final b =
        await _send(() => http.get(_uri('/api/docgia/stats'), headers: _headers));
    return ReaderStats(
      (b['total'] ?? 0) as int,
      (b['withImage'] ?? 0) as int,
      (b['withoutImage'] ?? 0) as int,
      ((b['newest'] ?? []) as List)
          .map((e) => DocGia.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Future<DocGia> getReader(String id) async {
    final b =
        await _send(() => http.get(_uri('/api/docgia/$id'), headers: _headers));
    return DocGia.fromJson(Map<String, dynamic>.from(b));
  }

  Future<DocGia> createReader(
      {required String email,
      required String matkhau,
      required String hoten,
      required String hinhanh}) async {
    final b = await _send(() => http.post(_uri('/api/docgia'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'matkhau': matkhau,
          'hoten': hoten,
          'hinhanh': hinhanh
        })));
    return DocGia.fromJson(Map<String, dynamic>.from(b));
  }

  Future<DocGia> updateReader(String id,
      {required String email,
      required String hoten,
      required String hinhanh,
      String? matkhau}) async {
    final b = await _send(() => http.put(_uri('/api/docgia/$id'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'hoten': hoten,
          'hinhanh': hinhanh,
          if (matkhau != null && matkhau.isNotEmpty) 'matkhau': matkhau,
        })));
    return DocGia.fromJson(Map<String, dynamic>.from(b));
  }

  Future<void> deleteReader(String id) async {
    await _send(
        () => http.delete(_uri('/api/docgia/$id'), headers: _headers));
  }
}
