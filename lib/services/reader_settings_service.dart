// ======================================================
// سرویس تنظیمات مطالعه
// ======================================================
//
// این فایل مسئول ذخیره و دریافت تنظیمات مربوط به
// نحوه نمایش متن کتاب است.
//
// در مرحله اول:
// فقط اندازه متن را مدیریت می‌کنیم.
//
// اطلاعات در SharedPreferences ذخیره می‌شود.
// ======================================================

import 'package:shared_preferences/shared_preferences.dart';

// ======================================================
// سرویس تنظیمات مطالعه
// ======================================================

class ReaderSettingsService {
  // ----------------------------------------------------
  // کلید ذخیره اندازه متن
  // ----------------------------------------------------

  static const String _textScaleKey =
      'reader_text_scale';

  // ----------------------------------------------------
  // اندازه پیش‌فرض متن
  // ----------------------------------------------------

  static const double defaultTextScale = 1.0;

  // ====================================================
  // دریافت اندازه متن
  // ====================================================

  static Future<double> getTextScale() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getDouble(_textScaleKey) ??
        defaultTextScale;
  }

  // ====================================================
  // ذخیره اندازه متن
  // ====================================================

  static Future<void> setTextScale(
    double scale,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setDouble(
      _textScaleKey,
      scale,
    );
  }

  // ====================================================
  // بازگرداندن اندازه متن به حالت پیش‌فرض
  // ====================================================

  static Future<void> resetTextScale() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_textScaleKey);
  }
}