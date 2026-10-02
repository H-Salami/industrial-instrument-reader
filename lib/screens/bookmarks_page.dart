// ======================================================
// صفحه نشانک‌های کتاب
// ======================================================
//
// این صفحه مسئول:
// 1. نمایش تمام نشانک‌ها
// 2. رفتن به محل نشانک
// 3. حذف نشانک
// 4. نمایش پیام در صورت نبود نشانک
// ======================================================

import 'package:flutter/material.dart';

import '../services/bookmark_service.dart';
import 'reading_page.dart';

// ======================================================
// صفحه نشانک‌ها
// ======================================================

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() =>
      _BookmarksPageState();
}

// ======================================================
// وضعیت صفحه
// ======================================================

class _BookmarksPageState extends State<BookmarksPage> {
  List<Bookmark> bookmarks = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadBookmarks();
  }

  // ====================================================
  // دریافت نشانک‌ها
  // ====================================================

  Future<void> loadBookmarks() async {
    final result =
        await BookmarkService.getBookmarks();

    if (!mounted) {
      return;
    }

    setState(() {
      bookmarks = result;
      isLoading = false;
    });
  }

  // ====================================================
  // باز کردن نشانک
  // ====================================================

  void openBookmark(Bookmark bookmark) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadingPage(
          chapterFile: bookmark.chapterFile,
          chapterTitle: bookmark.chapterTitle,

          // مستقیماً به بلوک نشانک می‌رویم.
          initialBlockIndex: bookmark.blockIndex,
        ),
      ),
    );
  }

  // ====================================================
  // حذف نشانک
  // ====================================================

  Future<void> deleteBookmark(
    Bookmark bookmark,
  ) async {
    await BookmarkService.removeBookmark(bookmark);

    if (!mounted) {
      return;
    }

    // بعد از حذف، فهرست را دوباره می‌خوانیم.
    await loadBookmarks();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('نشانک حذف شد'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ====================================================
  // ساخت کارت نشانک
  // ====================================================

  Widget buildBookmarkItem(Bookmark bookmark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(
          Icons.bookmark,
          size: 32,
        ),

        // عنوان بخش
        title: Text(
          bookmark.blockTitle.isEmpty
              ? 'بخش بدون عنوان'
              : bookmark.blockTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        // عنوان فصل
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            bookmark.chapterTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // دکمه حذف
        trailing: IconButton(
          tooltip: 'حذف نشانک',
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            deleteBookmark(bookmark);
          },
        ),

        // کلیک روی خود نشانک
        onTap: () {
          openBookmark(bookmark);
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
        appBar: AppBar(
          title: const Text('نشانک‌های من'),
          centerTitle: true,
        ),
        body: buildBody(),
      ),
    );
  }

  // ====================================================
  // ساخت بدنه صفحه
  // ====================================================

  Widget buildBody() {
    // در حال بارگذاری
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // هیچ نشانکی وجود ندارد
    if (bookmarks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bookmark_border,
                size: 70,
              ),
              SizedBox(height: 15),
              Text(
                'هنوز هیچ نشانکی ثبت نشده است.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'هنگام مطالعه با استفاده از دکمه '
                'نشانک می‌توانید یک بخش را ذخیره کنید.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // نمایش نشانک‌ها
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        return buildBookmarkItem(
          bookmarks[index],
        );
      },
    );
  }
}