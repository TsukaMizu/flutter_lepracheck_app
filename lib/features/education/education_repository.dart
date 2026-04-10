import 'education_article.dart';
import 'education_video.dart';

class EducationRepository {
  // Mock data that mirrors the structure returned by the CMS API.
  // When the backend CMS is ready, replace these static lists with HTTP GET calls.

  static List<EducationArticle> getArticles() {
    return [
      EducationArticle(
        id: '1',
        title: 'Mengenal Lepra: Penyakit Kuno yang Masih Ada di Sekitar Kita',
        body:
            'Lepra atau kusta adalah penyakit infeksi kronis yang disebabkan oleh bakteri '
            'Mycobacterium leprae. Meski penyakit ini sudah dikenal sejak ribuan tahun lalu, '
            'masih banyak kesalahpahaman di masyarakat.',
        category: 'Umum',
        imageUrl: 'https://picsum.photos/seed/lepra1/600/400',
        readTime: '5 menit baca',
        isFeatured: true,
      ),
      EducationArticle(
        id: '2',
        title: 'Gejala Awal Lepra yang Perlu Diwaspadai',
        body:
            'Gejala awal lepra sering kali berupa bercak putih atau kemerahan pada kulit '
            'yang mati rasa. Kenali tanda-tanda awalnya agar bisa ditangani lebih cepat.',
        category: 'Gejala',
        imageUrl: 'https://picsum.photos/seed/lepra2/400/300',
        readTime: '4 menit baca',
        isFeatured: false,
      ),
      EducationArticle(
        id: '3',
        title: 'Pengobatan MDT: Solusi Tuntas untuk Penyakit Kusta',
        body:
            'Multi-Drug Therapy (MDT) adalah regimen pengobatan yang direkomendasikan WHO '
            'untuk menyembuhkan kusta secara tuntas. Pelajari bagaimana MDT bekerja.',
        category: 'Pengobatan',
        imageUrl: 'https://picsum.photos/seed/lepra3/400/300',
        readTime: '6 menit baca',
        isFeatured: false,
      ),
      EducationArticle(
        id: '4',
        title: 'Mitos vs Fakta: Kusta Tidak Semudah itu Menular',
        body:
            'Banyak mitos yang mengatakan kusta sangat mudah menular. Faktanya, 95% manusia '
            'memiliki kekebalan alami terhadap bakteri penyebab kusta.',
        category: 'Mitos',
        imageUrl: 'https://picsum.photos/seed/lepra4/400/300',
        readTime: '3 menit baca',
        isFeatured: false,
      ),
      EducationArticle(
        id: '5',
        title: 'FAQ: Pertanyaan Umum Seputar Penyakit Kusta',
        body:
            'Temukan jawaban atas pertanyaan-pertanyaan yang paling sering ditanyakan '
            'mengenai kusta, mulai dari cara penularan hingga proses penyembuhan.',
        category: 'FAQ',
        imageUrl: 'https://picsum.photos/seed/lepra5/400/300',
        readTime: '7 menit baca',
        isFeatured: false,
      ),
      EducationArticle(
        id: '6',
        title: 'Dampak Sosial Kusta dan Cara Mengatasi Stigma',
        body:
            'Stigma sosial masih menjadi hambatan terbesar bagi penderita kusta. '
            'Pelajari cara kita bisa membantu mengurangi diskriminasi terhadap OYPMK.',
        category: 'Umum',
        imageUrl: 'https://picsum.photos/seed/lepra6/400/300',
        readTime: '5 menit baca',
        isFeatured: false,
      ),
    ];
  }

  static List<EducationVideo> getVideos() {
    return [
      EducationVideo(
        id: 'v1',
        title: 'Pengenalan Penyakit Kusta untuk Masyarakat Umum',
        videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        thumbnailUrl: 'https://picsum.photos/seed/vid1/320/180',
        duration: '04:32',
      ),
      EducationVideo(
        id: 'v2',
        title: 'Cara Deteksi Dini Gejala Kusta di Rumah',
        videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        thumbnailUrl: 'https://picsum.photos/seed/vid2/320/180',
        duration: '03:15',
      ),
      EducationVideo(
        id: 'v3',
        title: 'Program MDT WHO: Pengobatan Kusta Gratis',
        videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        thumbnailUrl: 'https://picsum.photos/seed/vid3/320/180',
        duration: '06:48',
      ),
    ];
  }
}
