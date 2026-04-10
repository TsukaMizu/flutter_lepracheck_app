class ApiConstants {
  // TODO: Ganti dengan IPv4 laptop saat demo (buka CMD → ipconfig).
  // Jangan gunakan localhost/127.0.0.1 karena emulator/HP Android tidak
  // dapat mengaksesnya. Contoh: 'http://192.168.1.5:8000'
  static const String baseUrl = 'http://192.168.1.10:8000';

  static const String getArticles = '$baseUrl/api/articles';
  static const String getVideos = '$baseUrl/api/videos';
}
