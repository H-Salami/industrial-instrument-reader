// ======================================================
// نقطه شروع برنامه
// ======================================================
//
// این فایل فقط مسئول راه‌اندازی اصلی برنامه است.
// صفحات برنامه در فایل‌های جداگانه قرار دارند.
// ======================================================

import 'package:flutter/material.dart';

import 'screens/home_page.dart';

// ======================================================
// شروع برنامه
// ======================================================

void main() {
  // اجرای برنامه
  runApp(const BookReaderApp());
}

// ======================================================
// ویجت اصلی برنامه
// ======================================================

class BookReaderApp extends StatelessWidget {
  const BookReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // نام برنامه
      title: 'کتاب ابزار دقیق',

      // حذف نوار Debug
      debugShowCheckedModeBanner: false,

      // زبان برنامه
      locale: const Locale('fa'),

      // اولین صفحه برنامه
      home: const HomePage(),
    );
  }
}

