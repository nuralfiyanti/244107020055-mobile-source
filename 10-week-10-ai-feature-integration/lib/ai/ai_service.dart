import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Service untuk berkomunikasi dengan Gemini AI API.
///
/// Fitur utama:
/// - API key disimpan aman via [FlutterSecureStorage] (tidak pernah hardcode).
/// - Validasi privasi input sebelum dikirim ke API.
/// - Local in-memory cache untuk menghindari panggilan berulang.
/// - Rate limiter: maksimal [_maxRequestsPerSession] request per sesi.
/// - Fallback lokal jika API tidak tersedia / key belum diatur.
class AiService {
  static const String _apiKeyStorageKey = 'ai_api_key';
  static const String _systemPrompt =
      'Kamu asisten kampus ramah, jawab dalam Bahasa Indonesia, maksimal 2 kalimat.';
  static const String _apiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  static const int _maxRequestsPerSession = 20;

  static const String _fallbackResponse =
      'Maaf, layanan AI sementara tidak tersedia. '
      'Untuk informasi jadwal, hubungi akademik kampus atau cek portal mahasiswa.';

  final FlutterSecureStorage _storage;

  /// Cache in-memory: normalized question → jawaban AI.
  final Map<String, String> _cache = {};

  /// Jumlah request yang sudah dikirim ke API dalam sesi ini.
  int _requestCount = 0;

  AiService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  // ---------------------------------------------------------------------------
  // API Key management
  // ---------------------------------------------------------------------------

  /// Membaca API key yang tersimpan di secure storage. Null jika belum diatur.
  Future<String?> getApiKey() async => _storage.read(key: _apiKeyStorageKey);

  /// Menyimpan [key] ke secure storage.
  Future<void> saveApiKey(String key) async =>
      _storage.write(key: _apiKeyStorageKey, value: key);

  // ---------------------------------------------------------------------------
  // Privacy validation
  // ---------------------------------------------------------------------------

  /// Memvalidasi bahwa [input] tidak mengandung data pribadi sensitif.
  /// Melempar [Exception] dengan pesan ramah jika terdeteksi.
  void _validatePrivacy(String input) {
    // NIK: 16 digit berurutan
    final nikPattern = RegExp(r'\b\d{16}\b');
    // Nomor telepon Indonesia: diawali 08 atau +62
    final phonePattern = RegExp(r'(^|\s)(08|\+62)\d{8,12}');
    // Alamat email
    final emailPattern = RegExp(
      r'[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}',
    );
    // Kata kunci sensitif
    const sensitiveKeywords = ['password', 'alamat'];

    if (nikPattern.hasMatch(input)) {
      throw Exception(
        'Input mengandung nomor NIK. Jangan kirim data pribadi ke AI.',
      );
    }
    if (phonePattern.hasMatch(input)) {
      throw Exception(
        'Input mengandung nomor telepon. Jangan kirim data pribadi ke AI.',
      );
    }
    if (emailPattern.hasMatch(input)) {
      throw Exception(
        'Input mengandung alamat email. Jangan kirim data pribadi ke AI.',
      );
    }
    for (final kw in sensitiveKeywords) {
      if (input.toLowerCase().contains(kw)) {
        throw Exception(
          'Input mengandung data sensitif ($kw). Silakan ubah pertanyaan Anda.',
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Core: ask
  // ---------------------------------------------------------------------------

  /// Mengirim [question] ke Gemini API dan mengembalikan jawaban teks.
  ///
  /// Urutan eksekusi:
  /// 1. Validasi privasi → [_validatePrivacy]
  /// 2. Cek cache → kembalikan jika tersedia
  /// 3. Cek rate limit → kembalikan pesan batas jika tercapai
  /// 4. Ambil API key → kembalikan pesan setup jika kosong
  /// 5. POST ke Gemini API
  /// 6. Parse respons → cache → increment counter
  Future<String> ask(String question) async {
    // 1. Validasi privasi
    _validatePrivacy(question);

    // 2. Cek cache
    final cacheKey = question.trim().toLowerCase();
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    // 3. Rate limit
    if (_requestCount >= _maxRequestsPerSession) {
      return 'Batas maksimal pertanyaan sesi ini telah tercapai '
          '($_maxRequestsPerSession pertanyaan). Silakan restart aplikasi.';
    }

    // 4. API key
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      return 'API Key belum diatur. Silakan atur di halaman pengaturan.';
    }

    // 5. POST ke Gemini API
    try {
      final answer = await _callGeminiApi(apiKey: apiKey, question: question);
      _cache[cacheKey] = answer;
      _requestCount++;
      return answer;
    } catch (_) {
      return _fallbackResponse;
    }
  }

  // ---------------------------------------------------------------------------
  // HTTP helper (dipecah agar mudah diuji secara terpisah)
  // ---------------------------------------------------------------------------

  Future<String> _callGeminiApi({
    required String apiKey,
    required String question,
  }) async {
    final uri = Uri.parse('$_apiBaseUrl?key=$apiKey');
    final requestBody = _buildRequestBody(question);

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      return _parseResponse(response.body);
    }
    return '$_fallbackResponse (Error ${response.statusCode})';
  }

  Map<String, dynamic> _buildRequestBody(String question) {
    return {
      'system_instruction': {
        'parts': [
          {'text': _systemPrompt},
        ],
      },
      'contents': [
        {
          'parts': [
            {'text': question},
          ],
        },
      ],
    };
  }

  String _parseResponse(String responseBody) {
    final data = jsonDecode(responseBody) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>;
    final parts =
        (candidates[0]['content']['parts'] as List<dynamic>);
    return parts[0]['text'] as String;
  }

  // ---------------------------------------------------------------------------
  // Utilities
  // ---------------------------------------------------------------------------

  /// Jumlah request yang sudah dikirim ke API dalam sesi ini (read-only).
  int get requestCount => _requestCount;

  /// Menghapus seluruh cache in-memory.
  void clearCache() => _cache.clear();
}

