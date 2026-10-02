// ======================================================
// صفحه تنظیمات مطالعه
// ======================================================
//
// این صفحه تنظیمات مربوط به نحوه نمایش کتاب را کنترل می‌کند.
//
// در مرحله اول:
// فقط اندازه متن را مدیریت می‌کنیم.
//
// مقدار انتخاب‌شده در SharedPreferences ذخیره می‌شود
// تا بعد از بسته شدن برنامه نیز باقی بماند.
// ======================================================

import 'package:flutter/material.dart';

import '../services/reader_settings_service.dart';

// ======================================================
// صفحه تنظیمات مطالعه
// ======================================================

class ReaderSettingsPage extends StatefulWidget {
  const ReaderSettingsPage({
    super.key,
  });

  @override
  State<ReaderSettingsPage> createState() =>
      _ReaderSettingsPageState();
}

// ======================================================
// وضعیت صفحه
// ======================================================

class _ReaderSettingsPageState
    extends State<ReaderSettingsPage> {
  // ----------------------------------------------------
  // اندازه فعلی متن
  // ----------------------------------------------------

  double textScale = 1.0;

  // ----------------------------------------------------
  // وضعیت بارگذاری
  // ----------------------------------------------------

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadSettings();
  }

  // ====================================================
  // خواندن تنظیمات ذخیره‌شده
  // ====================================================

  Future<void> loadSettings() async {
    final scale =
        await ReaderSettingsService.getTextScale();

    if (!mounted) {
      return;
    }

    setState(() {
      textScale = scale;
      isLoading = false;
    });
  }

  // ====================================================
  // تغییر اندازه متن
  // ====================================================

  Future<void> changeTextScale(
    double value,
  ) async {
    // محدوده مجاز اندازه متن
    final newScale =
        value.clamp(0.8, 1.5);

    await ReaderSettingsService.setTextScale(
      newScale,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      textScale = newScale;
    });
  }

  // ====================================================
  // کوچک کردن متن
  // ====================================================

  Future<void> decreaseTextSize() async {
    await changeTextScale(
      textScale - 0.1,
    );
  }

  // ====================================================
  // بزرگ کردن متن
  // ====================================================

  Future<void> increaseTextSize() async {
    await changeTextScale(
      textScale + 0.1,
    );
  }

  // ====================================================
  // بازگردانی تنظیمات
  // ====================================================

  Future<void> resetSettings() async {
    await ReaderSettingsService.resetTextScale();

    if (!mounted) {
      return;
    }

    setState(() {
      textScale =
          ReaderSettingsService.defaultTextScale;
    });
  }

  // ====================================================
  // نمایش درصد اندازه متن
  // ====================================================

  String get scalePercent {
    final percent =
        (textScale * 100).round();

    return '$percent٪';
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
          title: const Text(
            'تنظیمات مطالعه',
          ),
          centerTitle: true,
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : buildSettingsBody(),
      ),
    );
  }

  // ====================================================
  // بدنه تنظیمات
  // ====================================================

  Widget buildSettingsBody() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // ------------------------------------------------
        // عنوان بخش
        // ------------------------------------------------

        const Text(
          'اندازه متن',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        // ------------------------------------------------
        // نمایش درصد
        // ------------------------------------------------

        Center(
          child: Text(
            scalePercent,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 25),

        // ------------------------------------------------
        // دکمه‌های کاهش و افزایش
        // ------------------------------------------------

        Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'کوچک‌تر کردن متن',
              iconSize: 34,
              icon: const Icon(
                Icons.remove_circle_outline,
              ),
              onPressed:
                  textScale <= 0.8
                      ? null
                      : decreaseTextSize,
            ),

            const SizedBox(width: 35),

            IconButton(
              tooltip: 'بزرگ‌تر کردن متن',
              iconSize: 34,
              icon: const Icon(
                Icons.add_circle_outline,
              ),
              onPressed:
                  textScale >= 1.5
                      ? null
                      : increaseTextSize,
            ),
          ],
        ),

        const SizedBox(height: 30),

        // ------------------------------------------------
        // توضیح
        // ------------------------------------------------

        const Text(
          'با استفاده از دکمه‌های بالا می‌توانید '
          'اندازه متن کتاب را تغییر دهید.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 30),

        // ------------------------------------------------
        // دکمه بازگردانی
        // ------------------------------------------------

        OutlinedButton.icon(
          icon: const Icon(
            Icons.restart_alt,
          ),
          label: const Text(
            'بازگردانی به حالت پیش‌فرض',
          ),
          onPressed: resetSettings,
        ),
      ],
    );
  }
}

