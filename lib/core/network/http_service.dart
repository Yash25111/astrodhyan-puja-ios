import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../storage/local_storage.dart';
import 'api_endpoints.dart';
import 'api_exception.dart';

class HttpService {
  HttpService({
    required this.storage,
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client();
  final LocalStorage storage;
  final http.Client _client;
  final Duration timeout;
  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = path.startsWith('http')
        ? Uri.parse(path)
        : Uri.parse('${ApiEndpoints.baseUrl}$path');
    if (query == null || query.isEmpty) return base;
    return base.replace(
      queryParameters: {
        ...base.queryParameters,
        for (final entry in query.entries)
          if (entry.value != null) entry.key: '${entry.value}',
      },
    );
  }

  Future<Map<String, String>> _headers({
    bool auth = true,
    String? language,
    bool json = true,
  }) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (json) headers['Content-Type'] = 'application/json';
    if (language != null && language.isNotEmpty) {
      headers['Accept-Language'] = language;
    }
    if (auth) {
      final token = await storage.getString(LocalStorage.accessToken);
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    bool auth = true,
    String? language,
  }) async {
    return _request(
      () async => _client.get(
        _uri(path, query),
        headers: await _headers(auth: auth, language: language, json: false),
      ),
    );
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
    String? language,
  }) {
    return _request(
      () async => _client.post(
        _uri(path),
        headers: await _headers(auth: auth, language: language),
        body: jsonEncode(body ?? <String, dynamic>{}),
      ),
    );
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
    String? language,
  }) {
    return _request(
      () async => _client.put(
        _uri(path),
        headers: await _headers(auth: auth, language: language),
        body: jsonEncode(body ?? <String, dynamic>{}),
      ),
    );
  }

  /// Semantic alias for PUT, useful when repository methods are named `update*`.
  Future<dynamic> update(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
    String? language,
  }) {
    return put(path, body: body, auth: auth, language: language);
  }

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
    String? language,
  }) {
    return _request(
      () async => _client.patch(
        _uri(path),
        headers: await _headers(auth: auth, language: language),
        body: jsonEncode(body ?? <String, dynamic>{}),
      ),
    );
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) {
    return _request(
      () async => _client.delete(
        _uri(path),
        headers: await _headers(auth: auth),
        body: body == null ? null : jsonEncode(body),
      ),
    );
  }

  Future<dynamic> putMultipart(
    String path, {
    required Map<String, String> fields,
    String? filePath,
    String fileField = 'profile_img',
    bool auth = true,
  }) async {
    final request = http.MultipartRequest('PUT', _uri(path));
    request.headers.addAll(await _headers(auth: auth, json: false));
    request.fields.addAll(fields);
    if (filePath != null && filePath.trim().isNotEmpty) {
      final file = File(filePath);
      if (!await file.exists()) {
        throw const ApiException('Selected image file was not found.');
      }
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
    }
    try {
      final streamed = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamed);
      await _captureToken(response);
      return _decode(response);
    } on TimeoutException catch (e) {
      throw ApiException('Request timed out. Please try again.', cause: e);
    } on SocketException catch (e) {
      throw ApiException('No internet connection.', cause: e);
    }
  }

  Future<dynamic> _request(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(timeout);
      await _captureToken(response);
      return _decode(response);
    } on TimeoutException catch (e) {
      throw ApiException('Request timed out. Please try again.', cause: e);
    } on SocketException catch (e) {
      throw ApiException('No internet connection.', cause: e);
    } on http.ClientException catch (e) {
      throw ApiException('Unable to connect to the server.', cause: e);
    }
  }

  Future<void> _captureToken(http.Response response) async {
    final refreshed =
        response.headers['x-refreshed-token'] ??
        response.headers['x-access-token'] ??
        response.headers['access-token'];
    if (refreshed != null && refreshed.isNotEmpty) {
      await storage.setString(LocalStorage.accessToken, refreshed);
    }
    final authorization = response.headers['authorization'];
    if (authorization != null && authorization.startsWith('Bearer ')) {
      await storage.setString(
        LocalStorage.accessToken,
        authorization.substring('Bearer '.length),
      );
    }
  }

  dynamic _decode(http.Response response) {
    dynamic body;
    try {
      body = response.body.trim().isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
    } catch (_) {
      body = response.body;
    }
    _logApiResponse(response, body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body is Map && body['message'] != null
          ? '${body['message']}'
          : response.reasonPhrase ?? 'Request failed';
      throw ApiException(message, statusCode: response.statusCode);
    }
    if (body is Map && body['success'] == false) {
      throw ApiException(
        '${body['message'] ?? 'Request failed'}',
        statusCode: response.statusCode,
      );
    }
    return body;
  }

  void _logApiResponse(http.Response response, dynamic body) {
    if (!kDebugMode) return;
    debugPrint('API URL: ${response.request?.url ?? 'unknown'}');
    debugPrint('API Status: ${response.statusCode}');
    debugPrint('API Response: ${_stringify(body)}');
  }

  String _stringify(dynamic value) {
    try {
      return value is String ? value : jsonEncode(value);
    } catch (_) {
      return '$value';
    }
  }

  void dispose() => _client.close();
}
