// ======================================================
// سرویس ذخیره آخرین محل مطالعه
// ======================================================
//
// این فایل مسئول ذخیره و بازیابی آخرین محل مطالعه
// کاربر در کتاب است.
//
// برای ذخیره اطلاعات از SharedPreferences استفاده می‌کنیم.
// این اطلاعات روی دستگاه کاربر ذخیره می‌شود.
// ======================================================

import 'package:shared_preferences/shared_preferences.dart';

// ======================================================
// مدل محل مطالعه
// ======================================================
//
// این کلاس اطلاعات محل مطالعه را در یک بسته نگه می‌دارد.
// ======================================================

class ReadingPosition {
  final String chapterFile;
  final String chapterTitle;
  final int blockIndex;

  const ReadingPosition({
    required this.chapterFile,
    required this.chapterTitle,
    required this.blockIndex,
  });
}

// ======================================================
// سرویس محل مطالعه
// ======================================================

class ReadingPositionService {
  // ----------------------------------------------------
  // کلیدهای مورد استفاده برای ذخیره اطلاعات
  // ----------------------------------------------------

  static const String _chapterFileKey =
      'last_reading_chapter_file';

  static const String _chapterTitleKey =
      'last_reading_chapter_title';

  static const String _blockIndexKey =
      'last_reading_block_index';

  // ----------------------------------------------------
  // ذخیره آخرین محل مطالعه
  // ----------------------------------------------------

  static Future<void> savePosition({
    required String chapterFile,
    required String chapterTitle,
    required int blockIndex,
  }) async {
    // دسترسی به حافظه تنظیمات برنامه
    final prefs = await SharedPreferences.getInstance();

    // ذخیره مسیر فصل
    await prefs.setString(
      _chapterFileKey,
      chapterFile,
    );

    // ذخیره عنوان فصل
    await prefs.setString(
      _chapterTitleKey,
      chapterTitle,
    );

    // ذخیره شماره بلوک
    await prefs.setInt(
      _blockIndexKey,
      blockIndex,
    );
  }

  // ----------------------------------------------------
  // دریافت آخرین محل مطالعه
  // ----------------------------------------------------

  static Future<ReadingPosition?> getLastPosition() async {
    final prefs = await SharedPreferences.getInstance();

    // خواندن اطلاعات ذخیره شده
    final chapterFile =
        prefs.getString(_chapterFileKey);

    final chapterTitle =
        prefs.getString(_chapterTitleKey);

    final blockIndex =
        prefs.getInt(_blockIndexKey);

    // اگر اطلاعات کامل نباشد،
    // محل مطالعه‌ای ذخیره نشده است.
    if (chapterFile == null ||
        chapterTitle == null ||
        blockIndex == null) {
      return null;
    }

    // ساخت مدل محل مطالعه
    return ReadingPosition(
      chapterFile: chapterFile,
      chapterTitle: chapterTitle,
      blockIndex: blockIndex,
    );
  }

  // ----------------------------------------------------
  // پاک کردن آخرین محل مطالعه
  // ----------------------------------------------------

  static Future<void> clearPosition() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_chapterFileKey);
    await prefs.remove(_chapterTitleKey);
    await prefs.remove(_blockIndexKey);
  }
}