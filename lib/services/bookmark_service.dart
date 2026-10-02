// ======================================================
// سرویس مدیریت نشانک‌های کتاب
// ======================================================
//
// این فایل مسئول:
// 1. ذخیره نشانک
// 2. دریافت تمام نشانک‌ها
// 3. حذف یک نشانک
// 4. حذف تمام نشانک‌ها
//
// اطلاعات نشانک در SharedPreferences ذخیره می‌شود.
// ======================================================

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

// ======================================================
// مدل نشانک
// ======================================================

class Bookmark {
  // ----------------------------------------------------
  // اطلاعات اصلی نشانک
  // ----------------------------------------------------

  final String chapterFile;
  final String chapterTitle;
  final int blockIndex;
  final String blockTitle;
  final DateTime createdAt;

  // ----------------------------------------------------
  // سازنده Bookmark
  // ----------------------------------------------------

  const Bookmark({
    required this.chapterFile,
    required this.chapterTitle,
    required this.blockIndex,
    required this.blockTitle,
    required this.createdAt,
  });

  // ====================================================
  // تبدیل Bookmark به Map
  // ====================================================
  //
  // برای ذخیره اطلاعات در SharedPreferences
  // باید آن را به Map تبدیل کنیم.
  // ====================================================

  Map<String, dynamic> toMap() {
    return {
      'chapterFile': chapterFile,
      'chapterTitle': chapterTitle,
      'blockIndex': blockIndex,
      'blockTitle': blockTitle,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // ====================================================
  // ساخت Bookmark از Map
  // ====================================================

  factory Bookmark.fromMap(
    Map<String, dynamic> map,
  ) {
    return Bookmark(
      chapterFile: map['chapterFile'] as String,
      chapterTitle: map['chapterTitle'] as String,
      blockIndex: map['blockIndex'] as int,
      blockTitle: map['blockTitle'] as String,
      createdAt: DateTime.parse(
        map['createdAt'] as String,
      ),
    );
  }

  // ====================================================
  // تبدیل Bookmark به JSON
  // ====================================================

  String toJson() {
    return jsonEncode(toMap());
  }

  // ====================================================
  // ساخت Bookmark از JSON
  // ====================================================

  factory Bookmark.fromJson(String json) {
    final map =
        jsonDecode(json) as Map<String, dynamic>;

    return Bookmark.fromMap(map);
  }
}

// ======================================================
// سرویس نشانک‌ها
// ======================================================

class BookmarkService {
  // کلیدی که اطلاعات نشانک‌ها با آن ذخیره می‌شوند.
  static const String _bookmarksKey = 'bookmarks';

  // ====================================================
  // دریافت تمام نشانک‌ها
  // ====================================================

  static Future<List<Bookmark>> getBookmarks() async {
    final prefs =
        await SharedPreferences.getInstance();

    final bookmarkStrings =
        prefs.getStringList(_bookmarksKey);

    // اگر هنوز هیچ نشانکی ذخیره نشده باشد.
    if (bookmarkStrings == null) {
      return [];
    }

    // تبدیل JSONها به Bookmark
    return bookmarkStrings
        .map(
          (item) => Bookmark.fromJson(item),
        )
        .toList();
  }

  // ====================================================
  // افزودن نشانک
  // ====================================================

  static Future<void> addBookmark(
    Bookmark bookmark,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    // نشانک‌های قبلی را دریافت می‌کنیم.
    final bookmarks = await getBookmarks();

    // اگر این محل قبلاً نشانک شده باشد،
    // دوباره آن را اضافه نمی‌کنیم.
    final exists = bookmarks.any(
      (item) =>
          item.chapterFile ==
              bookmark.chapterFile &&
          item.blockIndex == bookmark.blockIndex,
    );

    if (exists) {
      return;
    }

    // اضافه کردن نشانک جدید
    bookmarks.add(bookmark);

    // تبدیل Bookmarkها به JSON
    final bookmarkStrings = bookmarks
        .map((item) => item.toJson())
        .toList();

    // ذخیره در SharedPreferences
    await prefs.setStringList(
      _bookmarksKey,
      bookmarkStrings,
    );
  }

  // ====================================================
  // حذف یک نشانک
  // ====================================================

  static Future<void> removeBookmark(
    Bookmark bookmark,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final bookmarks = await getBookmarks();

    // حذف نشانک موردنظر
    bookmarks.removeWhere(
      (item) =>
          item.chapterFile ==
              bookmark.chapterFile &&
          item.blockIndex == bookmark.blockIndex,
    );

    final bookmarkStrings = bookmarks
        .map((item) => item.toJson())
        .toList();

    await prefs.setStringList(
      _bookmarksKey,
      bookmarkStrings,
    );
  }

  // ====================================================
  // حذف تمام نشانک‌ها
  // ====================================================

  static Future<void> clearBookmarks() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_bookmarksKey);
  }
}