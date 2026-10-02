// ======================================================
// نمایش انواع محتوای کتاب
// ======================================================

import 'package:flutter/material.dart';

import '../models/content_block.dart';

class ContentRenderer extends StatelessWidget {
  final ContentBlock block;

  // ----------------------------------------------------
  // ضریب اندازه متن
  // ----------------------------------------------------

  final double textScale;

  const ContentRenderer({
    super.key,
    required this.block,
    this.textScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      case ContentType.heading:
        return _buildHeading();

      case ContentType.text:
        return _buildText();

      case ContentType.image:
        return _buildImage(context);

      case ContentType.table:
        return _buildTable();

      case ContentType.formula:
        return _buildFormula();

      case ContentType.bullet:
        return _buildBullet();

      case ContentType.note:
        return _buildNote();

      case ContentType.summary:
        return _buildSummary();
    }
  }

  // ----------------------------------------------------
  // عنوان
  // ----------------------------------------------------

  Widget _buildHeading() {
    final level = block.headingLevel ?? 2;

    double fontSize;

    if (level == 1) {
      fontSize = 26;
    } else if (level == 2) {
      fontSize = 22;
    } else {
      fontSize = 19;
    }

    fontSize *= textScale;

    final title = block.number != null &&
            block.number!.isNotEmpty
        ? '${block.number} ${block.text ?? ''}'
        : block.text ?? '';

    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        bottom: 12,
      ),
      child: Text(
        title,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // متن معمولی
  // ----------------------------------------------------

  Widget _buildText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        block.text ?? '',

        // ------------------------------------------------
        // تراز متن از JSON خوانده می‌شود.
        //
        // مثال:
        // "align": "center"
        //
        // اگر align در JSON نباشد، مقدار null است
        // و رفتار پیش‌فرض Flutter حفظ می‌شود.
        // ------------------------------------------------
        textAlign: block.textAlign,

        style: TextStyle(
          fontSize: 18 * textScale,
          height: 1.8,
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // تصویر
  // ----------------------------------------------------

  Widget _buildImage(BuildContext context) {
    if (block.imagePath == null) {
      return const SizedBox.shrink();
    }

    // عرض صفحه
    final screenWidth =
        MediaQuery.of(context).size.width;

    // فضای خالی دو طرف تصویر
    final availableWidth =
        screenWidth - 40;

    // --------------------------------------------------
    // تعیین عرض تصویر
    // --------------------------------------------------

    double imageWidth;

    if (block.imageWidth != null) {
      imageWidth =
          availableWidth *
          (block.imageWidth! / 100);
    } else {
      double factor;

      switch (block.imageSize) {
        case ImageSize.small:
          factor = 0.40;
          break;

        case ImageSize.medium:
          factor = 0.65;
          break;

        case ImageSize.full:
          factor = 1.0;
          break;

        case null:
          factor = 0.65;
          break;
      }

      imageWidth =
          availableWidth * factor;
    }

    // --------------------------------------------------
    // جلوگیری از مقدار نامعتبر
    // --------------------------------------------------

    if (imageWidth > availableWidth) {
      imageWidth = availableWidth;
    }

    if (imageWidth < 1) {
      imageWidth = availableWidth * 0.65;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [

            // ------------------------------------------------
            // خود تصویر
            //
            // با کلیک روی تصویر، نسخه بزرگ باز می‌شود.
            // ------------------------------------------------

            Center(
              child: GestureDetector(
                onTap: () {
                  _openImageViewer(
                    context,
                    block.imagePath!,
                  );
                },
                child: Image.asset(
                  block.imagePath!,
                  width: imageWidth,

                  // حفظ نسبت واقعی تصویر
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // ------------------------------------------------
            // عنوان تصویر
            // ------------------------------------------------

            if (block.caption != null &&
                block.caption!.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 8,
                    left: 10,
                    right: 10,
                  ),
                  child: Text(
                    block.caption!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15 * textScale,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // نمایش تصویر در حالت بزرگ
  // ----------------------------------------------------

  void _openImageViewer(
    BuildContext context,
    String imagePath,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.black,

            // ------------------------------------------------
            // نوار بالای صفحه
            // ------------------------------------------------

            appBar: AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),

            // ------------------------------------------------
            // InteractiveViewer
            //
            // امکان Zoom و جابه‌جایی تصویر را فراهم می‌کند.
            // در Android با دو انگشت نیز کار می‌کند.
            // ------------------------------------------------

            body: Center(
              child: InteractiveViewer(
                minScale: 1.0,
                maxScale: 5.0,

                // تصویر بزرگ‌شده
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ----------------------------------------------------
  // جدول
  // ----------------------------------------------------

  Widget _buildTable() {
    final rows = block.table ?? [];

    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          if (block.tableCaption != null &&
              block.tableCaption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                bottom: 8,
              ),
              child: Text(
                block.tableCaption!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15 * textScale,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          Table(
            border: TableBorder.all(),
            children: rows.map((row) {
              return TableRow(
                children: row.map((cell) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      cell,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14 * textScale,
                      ),
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // فرمول
  // ----------------------------------------------------

  Widget _buildFormula() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 20,
      ),
      child: Center(
        child: Text(
          block.text ?? '',
          style: TextStyle(
            fontSize: 20 * textScale,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // فهرست گلوله‌ای
  // ----------------------------------------------------

  Widget _buildBullet() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            '•  ',
            style: TextStyle(
              fontSize: 18 * textScale,
            ),
          ),
          Expanded(
            child: Text(
              block.text ?? '',
              style: TextStyle(
                fontSize: 18 * textScale,
                height: 1.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // نکته
  // ----------------------------------------------------

  Widget _buildNote() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        block.text ?? '',
        style: TextStyle(
          fontSize: 17 * textScale,
          height: 1.8,
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // جمع‌بندی
  // ----------------------------------------------------

  Widget _buildSummary() {
    return Container(
      margin: const EdgeInsets.only(
        top: 10,
        bottom: 20,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        block.text ?? '',
        style: TextStyle(
          fontSize: 17 * textScale,
          height: 1.8,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
