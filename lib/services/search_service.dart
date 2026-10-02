// ======================================================
// سرویس جستجو در محتوای کتاب
// ======================================================
//
// این فایل مسئول جستجو در ContentBlockها است.
//
// نکته:
// در این مرحله فقط موتور جستجو را می‌سازیم.
// رابط کاربری جستجو را در مرحله بعد اضافه می‌کنیم.
// ======================================================

import '../models/content_block.dart';

// ======================================================
// مدل نتیجه جستجو
// ======================================================

class SearchResult {
  // شماره بلوکی که عبارت در آن پیدا شده است.
  final int blockIndex;

  // خود بلوک محتوا
  final ContentBlock block;

  // متن قابل نمایش برای نتیجه
  final String text;

  const SearchResult({
    required this.blockIndex,
    required this.block,
    required this.text,
  });
}

// ======================================================
// سرویس جستجو
// ======================================================

class SearchService {
  // ----------------------------------------------------
  // جستجو در لیست بلوک‌های یک فصل
  // ----------------------------------------------------

  static List<SearchResult> search(
    List<ContentBlock> blocks,
    String query,
  ) {
    final results = <SearchResult>[];

    // حذف فاصله‌های اضافی از عبارت جستجو
    final searchText = query.trim();

    // اگر عبارت خالی باشد، نتیجه‌ای نداریم.
    if (searchText.isEmpty) {
      return results;
    }

    // بررسی تک‌تک بلوک‌های فصل
    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];

      // متن قابل جستجوی این بلوک را به دست می‌آوریم.
      final searchableText = _getSearchableText(block);

      // جستجو بدون حساسیت به حروف بزرگ و کوچک
      if (searchableText.toLowerCase().contains(
            searchText.toLowerCase(),
          )) {
        results.add(
          SearchResult(
            blockIndex: i,
            block: block,
            text: searchableText,
          ),
        );
      }
    }

    return results;
  }

  // ----------------------------------------------------
  // استخراج متن قابل جستجو از یک ContentBlock
  // ----------------------------------------------------

  static String _getSearchableText(ContentBlock block) {
    final parts = <String>[];

    // متن اصلی
    if (block.text != null) {
      parts.add(block.text!);
    }

    // شماره عنوان
    if (block.number != null) {
      parts.add(block.number!);
    }

    // توضیح تصویر
    if (block.caption != null) {
      parts.add(block.caption!);
    }

    // عنوان جدول
    if (block.tableCaption != null) {
      parts.add(block.tableCaption!);
    }

    // محتوای جدول
    if (block.table != null) {
      for (final row in block.table!) {
        for (final cell in row) {
          parts.add(cell);
        }
      }
    }

    // تمام قسمت‌ها را با فاصله به هم وصل می‌کنیم.
    return parts.join(' ');
  }
}

