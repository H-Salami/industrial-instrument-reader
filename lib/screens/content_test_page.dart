// ======================================================
// صفحه آزمایش محتوای JSON
// ======================================================

import 'package:flutter/material.dart';

import '../services/content_loader.dart';
import '../widgets/content_renderer.dart';

class ContentTestPage extends StatelessWidget {
  const ContentTestPage({super.key});

  // مسیر فایل JSON فصل اول
  static const String chapterFile =
      'assets/books/chapter_01/content.json';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('آزمایش محتوای فصل اول'),
        ),

        // FutureBuilder برای خواندن اطلاعات غیرهمزمان
        body: FutureBuilder(
          future: ContentLoader.loadChapter(chapterFile),

          builder: (context, snapshot) {
            // --------------------------------------------
            // در حال خواندن فایل
            // --------------------------------------------
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // --------------------------------------------
            // اگر خطایی رخ داده باشد
            // --------------------------------------------
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'خطا در خواندن محتوای فصل:\n\n'
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
              );
            }

            // --------------------------------------------
            // دریافت لیست ContentBlockها
            // --------------------------------------------
            final blocks = snapshot.data ?? [];

            // --------------------------------------------
            // نمایش محتوا
            // --------------------------------------------
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  ...blocks.map(
                    (block) {
                      return ContentRenderer(
                        block: block,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}