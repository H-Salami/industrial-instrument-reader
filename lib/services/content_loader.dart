// ======================================================
// خواندن محتوای کتاب از فایل JSON
// ======================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/content_block.dart';

class ContentLoader {
  // ----------------------------------------------------
  // خواندن محتوای یک فصل از فایل JSON
  // ----------------------------------------------------
  static Future<List<ContentBlock>> loadChapter(
    String filePath,
  ) async {
    final jsonString =
        await rootBundle.loadString(filePath);

    final Map<String, dynamic> jsonData =
        json.decode(jsonString);

    final List<dynamic> content =
        jsonData['content'] ?? [];

    final basePath = _getBasePath(filePath);

    debugPrint('CONTENT BASE => $basePath');

    return content.map((item) {
      return _blockFromJson(
        item as Map<String, dynamic>,
        basePath,
      );
    }).toList();
  }

  // ----------------------------------------------------
  // تبدیل یک آیتم JSON به ContentBlock
  // ----------------------------------------------------
  static ContentBlock _blockFromJson(
    Map<String, dynamic> json,
    String basePath,
  ) {
    final type = _parseContentType(
      json['type'] as String?,
    );

    final text = json['text'] as String?;
    final level = json['level'] as int?;
    final number = json['number'] as String?;

    // --------------------------------------------------
    // تراز متن
    // --------------------------------------------------
    //
    // مقدار align از JSON خوانده می‌شود.
    //
    // مثال:
    // "align": "center"
    //
    // اگر align وجود نداشته باشد، null خواهد بود
    // و رفتار پیش‌فرض Text حفظ می‌شود.
    // --------------------------------------------------

    final textAlign = _parseTextAlign(
      json['align'] as String?,
    );

    // --------------------------------------------------
    // تصویر
    // --------------------------------------------------
    if (type == ContentType.image) {
      final relativePath =
          json['path'] as String?;

      final imagePath = _buildAssetPath(
        basePath,
        relativePath,
      );

      // ------------------------------------------------
      // عرض سفارشی تصویر
      // ------------------------------------------------
      //
      // مقدار width در JSON اختیاری است.
      //
      // مثال:
      // "width": 45
      //
      // یعنی تصویر با 45 درصد عرض فضای متن نمایش داده شود.
      //
      // اگر width وجود نداشته باشد، مقدار null خواهد بود
      // و Renderer اندازه پیش‌فرض را استفاده می‌کند.
      // ------------------------------------------------

      final imageWidth =
          (json['width'] as num?)?.toDouble();

      debugPrint(
        'IMAGE => $imagePath | WIDTH => $imageWidth',
      );

      return ContentBlock(
        type: type,
        text: text,
        imagePath: imagePath,
        caption: json['caption'] as String?,
        imageSize: _parseImageSize(
          json['imageSize'] as String?,
        ),

        // ارسال عرض تصویر به مدل
        imageWidth: imageWidth,
      );
    }

    // --------------------------------------------------
    // جدول
    // --------------------------------------------------
    if (type == ContentType.table) {
      final table = _parseTable(
        json['table'],
      );

      debugPrint(
        'TABLE => rows: ${table.length}',
      );

      return ContentBlock(
        type: type,
        text: text,
        tableCaption:
            json['tableCaption'] as String?,
        table: table,
      );
    }

    // --------------------------------------------------
    // سایر انواع محتوا
    // --------------------------------------------------
    return ContentBlock(
      type: type,
      text: text,

      // تراز متن
      textAlign: textAlign,

      headingLevel: level,
      number: number,
    );
  }

  // ----------------------------------------------------
  // تبدیل align موجود در JSON به TextAlign
  // ----------------------------------------------------
  static TextAlign? _parseTextAlign(
    String? align,
  ) {
    switch (align) {
      case 'center':
        return TextAlign.center;

      case 'right':
        return TextAlign.right;

      case 'left':
        return TextAlign.left;

      case 'justify':
        return TextAlign.justify;

      default:
        return null;
    }
  }

  // ----------------------------------------------------
  // پیدا کردن مسیر پوشه content.json
  // ----------------------------------------------------
  static String _getBasePath(
    String filePath,
  ) {
    final lastSlash =
        filePath.lastIndexOf('/');

    if (lastSlash == -1) {
      return '';
    }

    return filePath.substring(
      0,
      lastSlash + 1,
    );
  }

  // ----------------------------------------------------
  // ساخت مسیر کامل Asset تصویر
  // ----------------------------------------------------
  static String _buildAssetPath(
    String basePath,
    String? relativePath,
  ) {
    if (relativePath == null ||
        relativePath.isEmpty) {
      return '';
    }

    if (relativePath.startsWith('assets/')) {
      return relativePath;
    }

    final cleanPath =
        relativePath.startsWith('/')
            ? relativePath.substring(1)
            : relativePath;

    return '$basePath$cleanPath';
  }

  // ----------------------------------------------------
  // تبدیل اندازه تصویر
  // ----------------------------------------------------
  static ImageSize _parseImageSize(
    String? size,
  ) {
    switch (size) {
      case 'small':
        return ImageSize.small;

      case 'full':
        return ImageSize.full;

      case 'medium':
      default:
        return ImageSize.medium;
    }
  }

  // ----------------------------------------------------
  // تبدیل اطلاعات جدول
  // ----------------------------------------------------
  static List<List<String>> _parseTable(
    dynamic tableData,
  ) {
    if (tableData is! List) {
      return [];
    }

    return tableData.map<List<String>>((row) {
      if (row is! List) {
        return [];
      }

      return row.map<String>((cell) {
        return cell.toString();
      }).toList();
    }).toList();
  }

  // ----------------------------------------------------
  // تشخیص نوع محتوا
  // ----------------------------------------------------
  static ContentType _parseContentType(
    String? type,
  ) {
    switch (type) {
      case 'heading':
        return ContentType.heading;

      case 'text':
        return ContentType.text;

      case 'formula':
        return ContentType.formula;

      case 'bullet':
        return ContentType.bullet;

      case 'note':
        return ContentType.note;

      case 'summary':
        return ContentType.summary;

      case 'image':
        return ContentType.image;

      case 'table':
        return ContentType.table;

      default:
        return ContentType.text;
    }
  }
}