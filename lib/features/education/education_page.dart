import 'package:flutter/material.dart';

import 'education_article.dart';
import 'education_repository.dart';
import 'education_video.dart';
import 'education_detail_page.dart';

// ---------------------------------------------------------------------------
// EducationPage – main entry point (StatefulWidget for tab state)
// ---------------------------------------------------------------------------

class EducationPage extends StatefulWidget {
  const EducationPage({super.key});

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  static const _categories = ['Semua', 'Gejala', 'Pengobatan', 'Mitos', 'FAQ'];
  int _selectedCategoryIndex = 0;

  final List<EducationArticle> _articles = EducationRepository.getArticles();
  final List<EducationVideo> _videos = EducationRepository.getVideos();

  List<EducationArticle> get _filteredArticles {
    final cat = _categories[_selectedCategoryIndex];
    if (cat == 'Semua') return _articles.where((a) => !a.isFeatured).toList();
    return _articles.where((a) => !a.isFeatured && a.category == cat).toList();
  }

  EducationArticle? get _featuredArticle {
    try {
      return _articles.firstWhere((a) => a.isFeatured);
    } catch (_) {
      return _articles.isNotEmpty ? _articles.first : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: _buildAppBar(context),
      body: CustomScrollView(
        slivers: [
          // ── Hero Banner ──
          if (_featuredArticle != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _HeroBanner(
                  article: _featuredArticle!,
                  onTap: () => _openDetail(_featuredArticle!),
                ),
              ),
            ),

          // ── Category Tabs ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: _CategoryTabs(
                categories: _categories,
                selectedIndex: _selectedCategoryIndex,
                onTap: (i) => setState(() => _selectedCategoryIndex = i),
              ),
            ),
          ),

          // ── Artikel Terbaru header ──
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: _SectionHeader(
                icon: Icons.article_outlined,
                label: 'Artikel Terbaru',
              ),
            ),
          ),

          // ── Article Grid ──
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: _filteredArticles.isEmpty
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Belum ada artikel untuk kategori ini.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                : SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _ArticleCard(
                        article: _filteredArticles[i],
                        onTap: () => _openDetail(_filteredArticles[i]),
                      ),
                      childCount: _filteredArticles.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                  ),
          ),

          // ── Video Edukasi header ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                children: [
                  const _SectionHeader(
                    icon: Icons.play_circle_outline,
                    label: 'Video Edukasi',
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1F6FEB),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'LIHAT SEMUA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Video horizontal list ──
          SliverToBoxAdapter(
            child: SizedBox(
              height: 180,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _videos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) => _VideoCard(video: _videos[i]),
              ),
            ),
          ),

          // bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF7F8FA),
      centerTitle: true,
      title: const Text(
        'Edukasi Kusta',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Cari Artikel',
          onPressed: () {},
        ),
      ],
    );
  }

  void _openDetail(EducationArticle article) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EducationDetailPage(article: article)),
    );
  }
}

// ---------------------------------------------------------------------------
// _HeroBanner
// ---------------------------------------------------------------------------

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.article, required this.onTap});

  final EducationArticle article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // background image
              article.imageUrl.isNotEmpty
                  ? Image.network(
                      article.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _placeholderGradient(),
                    )
                  : _placeholderGradient(),

              // gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(200),
                    ],
                  ),
                ),
              ),

              // content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F6FEB),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'UTAMA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 13, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          article.readTime,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F6FEB), Color(0xFF0A3D8A)],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _CategoryTabs
// ---------------------------------------------------------------------------

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({
    required this.categories,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF1F6FEB)
                    : const Color(0xFFE8EEF7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                categories[i],
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF4A5568),
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _SectionHeader
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1F6FEB)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A202C),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _ArticleCard
// ---------------------------------------------------------------------------

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article, required this.onTap});

  final EducationArticle article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // thumbnail
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: article.imageUrl.isNotEmpty
                    ? Image.network(
                        article.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _placeholderBox(),
                      )
                    : _placeholderBox(),
              ),
            ),

            // text content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // category chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EEF7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        article.category,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F6FEB),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 11, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            article.readTime,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderBox() {
    return Container(
      color: const Color(0xFFD6E4FF),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Color(0xFF1F6FEB), size: 28),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _VideoCard
// ---------------------------------------------------------------------------

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video});

  final EducationVideo video;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // thumbnail with play icon and duration badge
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 110,
              width: 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  video.thumbnailUrl.isNotEmpty
                      ? Image.network(
                          video.thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),

                  // dark overlay
                  Container(color: Colors.black.withAlpha(60)),

                  // play button
                  const Center(
                    child: Icon(Icons.play_circle_fill,
                        color: Colors.white, size: 38),
                  ),

                  // duration badge
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(180),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        video.duration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            video.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: Color(0xFF1A202C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF0A3D8A),
      child: const Center(
        child: Icon(Icons.ondemand_video, color: Colors.white54, size: 32),
      ),
    );
  }
}
