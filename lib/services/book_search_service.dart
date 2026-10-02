// ======================================================
// جستجو در کل کتاب
// ======================================================
//
// این فایل مسئول جستجو در تمام فصل‌های کتاب است.
//
// SearchService قبلی فقط در یک فصل جستجو می‌کند.
// این فایل از آن سرویس استفاده می‌کند تا جستجوی
// کل کتاب انجام شود.
// ======================================================

import '../data/chapters.dart';
import '../models/content_block.dart';
import 'content_loader.dart';
import 'search_service.dart';

// ======================================================
// مدل نتیجه جستجو در کل کتاب
// ======================================================

class BookSearchResult {
  // شماره فصل
  final int chapterNumber;

  // عنوان فصل
  final String chapterTitle;

  // مسیر فایل JSON فصل
  final String chapterFile;

  // نتیجه جستجوی داخل فصل
  final SearchResult result;

  const BookSearchResult({
    required this.chapterNumber,
    required this.chapterTitle,
    required this.chapterFile,
    required this.result,
  });
}

// ======================================================
// سرویس جستجوی کل کتاب
// ======================================================

class BookSearchService {
  // ----------------------------------------------------
  // جستجو در تمام فصل‌های کتاب
  // ----------------------------------------------------

  static Future<List<BookSearchResult>> searchBook(
    String query,
  ) async {
    final results = <BookSearchResult>[];

    // اگر عبارت جستجو خالی باشد،
    // نیازی به خواندن فایل‌های کتاب نیست.
    if (query.trim().isEmpty) {
      return results;
    }

    // تمام فصل‌های تعریف‌شده در chapters.dart
    // را یکی‌یکی بررسی می‌کنیم.
    for (final chapter in chapters) {
      try {
        // خواندن محتوای فصل
        final blocks = await ContentLoader.loadChapter(
          chapter.file,
        );

        // جستجو در بلوک‌های همان فصل
        final chapterResults = SearchService.search(
          blocks,
          query,
        );

        // اضافه کردن نتایج این فصل به نتایج کل کتاب
        for (final result in chapterResults) {
          results.add(
            BookSearchResult(
              chapterNumber: chapter.number,
              chapterTitle: chapter.title,
              chapterFile: chapter.file,
              result: result,
            ),
          );
        }
      } catch (e) {
        // اگر یک فصل مشکل داشت،
        // جستجوی سایر فصل‌ها متوقف نمی‌شود.
        continue;
      }
    }

    return results;
  }

  // ----------------------------------------------------
  // متن مناسب برای نمایش نتیجه
  // ----------------------------------------------------

  static String getDisplayText(BookSearchResult result) {
    final block = result.result.block;

    // اگر بلوک عنوان باشد، عنوان را نمایش می‌دهیم.
    if (block.type == ContentType.heading) {
      return block.text ?? '';
    }

    // در غیر این صورت متن بلوک نمایش داده می‌شود.
    return result.result.text;
  }
}

