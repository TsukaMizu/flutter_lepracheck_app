import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import 'education_article.dart';
import 'education_video.dart';

class EducationRepository {
  /// Mengambil daftar artikel dari CMS API.
  /// Melempar [Exception] dengan pesan yang jelas jika request gagal.
  Future<List<EducationArticle>> fetchArticles() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConstants.getArticles))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> body =
            jsonDecode(response.body) as List<dynamic>;
        return body
            .map((item) =>
                EducationArticle.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
            'Gagal memuat artikel: Server mengembalikan status ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception(
          'Koneksi terputus. Pastikan laptop dan HP berada di jaringan WiFi yang sama.');
    } on SocketException {
      throw Exception(
          'Gagal terhubung ke server. Pastikan berada di jaringan yang sama.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal memuat artikel: $e');
    }
  }

  /// Mengambil daftar video dari CMS API.
  /// Melempar [Exception] dengan pesan yang jelas jika request gagal.
  Future<List<EducationVideo>> fetchVideos() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConstants.getVideos))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> body =
            jsonDecode(response.body) as List<dynamic>;
        return body
            .map((item) =>
                EducationVideo.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
            'Gagal memuat video: Server mengembalikan status ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception(
          'Koneksi terputus. Pastikan laptop dan HP berada di jaringan WiFi yang sama.');
    } on SocketException {
      throw Exception(
          'Gagal terhubung ke server. Pastikan berada di jaringan yang sama.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal memuat video: $e');
    }
  }
}

