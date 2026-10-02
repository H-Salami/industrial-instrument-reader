// ======================================================
// صفحه فهرست فصل‌های کتاب
// ======================================================
//
// این صفحه بعد از زدن «ورود به کتاب» نمایش داده می‌شود.
//
// امکانات:
// 1. نمایش ادامه مطالعه
// 2. نمایش فصل‌های کتاب
// 3. جستجو
// 4. نشانک‌ها
// 5. تنظیمات مطالعه
//
// در این صفحه عنوان اصلی کتاب و نام تهیه‌کننده
// نمایش داده نمی‌شوند.
// ======================================================

import 'package:flutter/material.dart';

import '../data/chapters.dart';
import '../services/reading_position_service.dart';

import 'reading_page.dart';
import 'search_page.dart';
import 'bookmarks_page.dart';
import 'reader_settings_page.dart';

// ======================================================
// صفحه فهرست فصل‌ها
// ======================================================

class ChapterListPage extends StatefulWidget {
  const ChapterListPage({super.key});

  @override
  State<ChapterListPage> createState() =>
      _ChapterListPageState();
}

// ======================================================
// وضعیت صفحه
// ======================================================

class _ChapterListPageState
    extends State<ChapterListPage> {
  // آخرین محل مطالعه
  ReadingPosition? lastPosition;

  // وضعیت بارگذاری
  bool isLoadingPosition = true;

  @override
  void initState() {
    super.initState();

    // دریافت آخرین محل مطالعه
    loadLastPosition();
  }

  // ====================================================
  // دریافت آخرین محل مطالعه
  // ====================================================

  Future<void> loadLastPosition() async {
    final position =
        await ReadingPositionService.getLastPosition();

    if (!mounted) {
      return;
    }

    setState(() {
      lastPosition = position;
      isLoadingPosition = false;
    });
  }

  // ====================================================
  // ادامه مطالعه
  // ====================================================

  void continueReading() {
    if (lastPosition == null) {
      return;
    }

    final position = lastPosition!;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadingPage(
          chapterFile: position.chapterFile,
          chapterTitle: position.chapterTitle,
          initialBlockIndex: position.blockIndex,
        ),
      ),
    );
  }

  // ====================================================
  // ساخت کارت ادامه مطالعه
  // ====================================================

  Widget buildContinueReadingCard() {
    if (isLoadingPosition ||
        lastPosition == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(
        bottom: 4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      child: InkWell(
        onTap: continueReading,
        borderRadius: BorderRadius.circular(16),

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Row(
            children: [

              // آیکون ادامه مطالعه
              Container(
                width: 48,
                height: 48,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                ),

                child: Icon(
                  Icons.play_arrow,
                  size: 30,
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer,
                ),
              ),

              const SizedBox(width: 14),

              // اطلاعات محل مطالعه
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    const Text(
                      'ادامه مطالعه',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      lastPosition!.chapterTitle,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // فلش
              const Icon(
                Icons.arrow_back_ios_new,
                size: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====================================================
  // باز کردن فصل
  // ====================================================

  void openChapter(int index) {
    final chapter = chapters[index];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadingPage(
          chapterFile: chapter.file,
          chapterTitle: chapter.title,
        ),
      ),
    );
  }

  // ====================================================
  // ساخت کارت فصل
  // ====================================================

  Widget buildChapterItem(int index) {
    final chapter = chapters[index];

    return Card(
      margin: const EdgeInsets.only(
        bottom: 9,
      ),

      elevation: 1,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
      ),

      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),

        // شماره فصل
        leading: Container(
          width: 43,
          height: 43,

          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(12),

            color: Theme.of(context)
                .colorScheme
                .primaryContainer,
          ),

          alignment: Alignment.center,

          child: Text(
            '${index + 1}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context)
                  .colorScheme
                  .onPrimaryContainer,
            ),
          ),
        ),

        // عنوان فصل
        title: Text(
          chapter.title,

          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),

        // فلش ورود به فصل
        trailing: const Icon(
          Icons.arrow_back_ios_new,
          size: 16,
        ),

        // باز کردن فصل
        onTap: () {
          openChapter(index);
        },
      ),
    );
  }

  // ====================================================
  // ساخت صفحه
  // ====================================================

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,

      child: Scaffold(

        // ------------------------------------------------
        // نوار بالای صفحه
        // ------------------------------------------------

        appBar: AppBar(
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [

              Icon(
                Icons.menu_book,
                size: 22,
              ),

              SizedBox(width: 8),

              Text(
                'فهرست مطالب',
              ),
            ],
          ),

          centerTitle: true,

          actions: [

            // تنظیمات مطالعه
            IconButton(
              tooltip: 'تنظیمات مطالعه',

              icon: const Icon(
                Icons.text_fields,
              ),

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ReaderSettingsPage(),
                  ),
                );
              },
            ),

            // نشانک‌ها
            IconButton(
              tooltip: 'نشانک‌های من',

              icon: const Icon(
                Icons.bookmarks,
              ),

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const BookmarksPage(),
                  ),
                );
              },
            ),

            // جستجو
            IconButton(
              tooltip: 'جستجوی کتاب',

              icon: const Icon(
                Icons.search,
              ),

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const SearchPage(),
                  ),
                );
              },
            ),
          ],
        ),

        // ------------------------------------------------
        // محتوای صفحه
        // ------------------------------------------------

        body: Padding(
          padding: const EdgeInsets.fromLTRB(
            18,
            16,
            18,
            12,
          ),

          child: Column(
            children: [

              // ادامه مطالعه
              buildContinueReadingCard(),

              if (lastPosition != null)
                const SizedBox(height: 14),

              // فهرست فصل‌ها
              Expanded(
                child: ListView.builder(
                  itemCount: chapters.length,

                  itemBuilder:
                      (context, index) {
                    return buildChapterItem(
                      index,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}