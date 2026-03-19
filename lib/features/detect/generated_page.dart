import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GeneratedPage extends StatefulWidget {
  final String imagePath;
  const GeneratedPage({super.key, required this.imagePath});

  @override
  State<GeneratedPage> createState() => _GeneratedPageState();
}

class _GeneratedPageState extends State<GeneratedPage> {
  @override
  void initState() {
    super.initState();

    // Dummy processing 2 detik
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      final label = DateTime.now().second.isEven ? 'indikasi' : 'tidak_indikasi';
      final conf = label == 'indikasi' ? 0.82 : 0.76;

      context.go(
        '/detect/result?path=${Uri.encodeComponent(widget.imagePath)}&label=$label&conf=$conf',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Sedang memproses gambar...\nMohon tunggu.', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}