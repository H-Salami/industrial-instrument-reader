// ======================================================
// صفحه مطالعه کتاب
// ======================================================
//
// این صفحه مسئول:
// 1. بارگذاری content.json
// 2. نمایش محتوای فصل
// 3. ساخت فهرست مطالب
// 4. انتقال به عنوان انتخاب‌شده
// 5. انتقال به نتیجه جستجو
// 6. بازیابی آخرین محل مطالعه
// 7. ذخیره محل فعلی مطالعه
// 8. ایجاد نشانک
// 9. دریافت تنظیم اندازه متن
// 10. تغییر اندازه متن هنگام مطالعه
//
// نکته:
// در این نسخه منطق اصلی صفحه تغییر نکرده است.
// تغییرات اصلی مربوط به ظاهر صفحه مطالعه است.
// ======================================================

import 'package:flutter/material.dart';

import '../models/content_block.dart';
import '../services/content_loader.dart';
import '../services/reading_position_service.dart';
import '../services/bookmark_service.dart';
import '../services/reader_settings_service.dart';
import '../widgets/content_renderer.dart';

// ======================================================
// صفحه مطالعه
// ======================================================

class ReadingPage extends StatefulWidget {
  final String chapterFile;
  final String chapterTitle;

  final int? initialBlockIndex;

  const ReadingPage({
    super.key,
    required this.chapterFile,
    required this.chapterTitle,
    this.initialBlockIndex,
  });

  @override
  State<ReadingPage> createState() =>
      _ReadingPageState();
}

// ======================================================
// وضعیت صفحه
// ======================================================

class _ReadingPageState extends State<ReadingPage> {
  List<ContentBlock> blocks = [];

  bool isLoading = true;
  String? errorMessage;

  // ----------------------------------------------------
  // ضریب اندازه متن
  // ----------------------------------------------------

  double textScale = 1.0;

  // ----------------------------------------------------
  // برای هر بلوک یک GlobalKey داریم.
  // ----------------------------------------------------

  final List<GlobalKey> blockKeys = [];

  @override
  void initState() {
    super.initState();

    // ابتدا تنظیمات را می‌خوانیم.
    loadReaderSettings();

    // سپس فصل را بارگذاری می‌کنیم.
    loadChapter();
  }

  // ====================================================
  // خواندن تنظیمات مطالعه
  // ====================================================

  Future<void> loadReaderSettings() async {
    final scale =
        await ReaderSettingsService.getTextScale();

    if (!mounted) {
      return;
    }

    setState(() {
      textScale = scale;
    });
  }

  // ====================================================
  // نمایش پنجره تنظیم اندازه متن
  // ====================================================

  void openReaderSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            // --------------------------------------------
            // تغییر اندازه متن
            // --------------------------------------------

            Future<void> changeScale(
              double value,
            ) async {
              final newScale =
                  value.clamp(0.8, 1.5);

              // تغییر فوری متن صفحه کتاب
              setState(() {
                textScale = newScale;
              });

              // به‌روزرسانی خود پنجره
              setSheetState(() {});

              // ذخیره مقدار جدید
              await ReaderSettingsService.setTextScale(
                newScale,
              );
            }

            // محاسبه درصد نمایش
            final percent =
                (textScale * 100).round();

            return Directionality(
              textDirection: TextDirection.rtl,

              child: Container(
                margin: const EdgeInsets.all(12),

                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  20,
                ),

                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surface,

                  borderRadius:
                      BorderRadius.circular(20),
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [

                    // ----------------------------------
                    // دستگیره بالای پنجره
                    // ----------------------------------

                    Container(
                      width: 45,
                      height: 5,

                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ----------------------------------
                    // عنوان
                    // ----------------------------------

                    const Text(
                      'اندازه متن',

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ----------------------------------
                    // نمایش درصد
                    // ----------------------------------

                    Text(
                      '$percent٪',

                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ----------------------------------
                    // کنترل اندازه متن
                    // ----------------------------------

                    Row(
                      children: [

                        // کوچک کردن
                        IconButton(
                          tooltip: 'کوچک‌تر',

                          iconSize: 32,

                          icon: const Icon(
                            Icons
                                .remove_circle_outline,
                          ),

                          onPressed:
                              textScale <= 0.8
                                  ? null
                                  : () {
                                      changeScale(
                                        textScale - 0.1,
                                      );
                                    },
                        ),

                        // نوار انتخاب اندازه
                        Expanded(
                          child: Slider(
                            min: 0.8,
                            max: 1.5,
                            divisions: 7,
                            value: textScale,

                            onChanged:
                                changeScale,
                          ),
                        ),

                        // بزرگ کردن
                        IconButton(
                          tooltip: 'بزرگ‌تر',

                          iconSize: 32,

                          icon: const Icon(
                            Icons
                                .add_circle_outline,
                          ),

                          onPressed:
                              textScale >= 1.5
                                  ? null
                                  : () {
                                      changeScale(
                                        textScale + 0.1,
                                      );
                                    },
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    // ----------------------------------
                    // بازگردانی به حالت پیش‌فرض
                    // ----------------------------------

                    TextButton.icon(
                      icon: const Icon(
                        Icons.restart_alt,
                      ),

                      label: const Text(
                        'بازگردانی به ۱۰۰٪',
                      ),

                      onPressed: () {
                        changeScale(1.0);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ====================================================
  // بارگذاری فصل
  // ====================================================

  Future<void> loadChapter() async {
    try {
      final result =
          await ContentLoader.loadChapter(
        widget.chapterFile,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        blocks = result;

        blockKeys.clear();

        // برای هر بلوک یک کلید ایجاد می‌کنیم.
        for (int i = 0; i < result.length; i++) {
          blockKeys.add(GlobalKey());
        }

        isLoading = false;
      });

      // اگر از جستجو آمده باشیم،
      // به نتیجه جستجو برو.
      if (widget.initialBlockIndex != null) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) {
          scrollToBlock(
            widget.initialBlockIndex!,
          );
        });
      } else {
        // در غیر این صورت آخرین محل مطالعه را بازیابی کن.
        restoreLastPosition();
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  // ====================================================
  // استخراج عنوان‌های فصل
  // ====================================================

  List<int> get headingIndexes {
    final indexes = <int>[];

    for (int i = 0; i < blocks.length; i++) {
      if (blocks[i].type == ContentType.heading) {
        indexes.add(i);
      }
    }

    return indexes;
  }

  // ====================================================
  // رفتن به یک بلوک مشخص
  // ====================================================

  void scrollToBlock(int index) {
    if (index < 0 ||
        index >= blockKeys.length) {
      return;
    }

    final targetContext =
        blockKeys[index].currentContext;

    if (targetContext == null) {
      return;
    }

    Scrollable.ensureVisible(
      targetContext,

      duration:
          const Duration(milliseconds: 600),

      curve: Curves.easeInOut,

      alignment: 0.05,
    );
  }

  // ====================================================
  // بازیابی آخرین محل مطالعه
  // ====================================================

  Future<void> restoreLastPosition() async {
    if (widget.initialBlockIndex != null) {
      return;
    }

    final position =
        await ReadingPositionService
            .getLastPosition();

    if (position == null) {
      return;
    }

    if (position.chapterFile !=
        widget.chapterFile) {
      return;
    }

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      scrollToBlock(
        position.blockIndex,
      );
    });
  }

  // ====================================================
  // تشخیص اولین بلوک قابل مشاهده
  // ====================================================

  int? getCurrentBlockIndex() {
    final screenHeight =
        MediaQuery.of(context).size.height;

    for (int i = 0;
        i < blockKeys.length;
        i++) {
      final blockContext =
          blockKeys[i].currentContext;

      if (blockContext == null) {
        continue;
      }

      final renderObject =
          blockContext.findRenderObject();

      if (renderObject == null) {
        continue;
      }

      final box =
          renderObject as RenderBox;

      final position =
          box.localToGlobal(
        Offset.zero,
      );

      final top = position.dy;

      final bottom =
          top + box.size.height;

      if (bottom > 0 &&
          top < screenHeight) {
        return i;
      }
    }

    return null;
  }

  // ====================================================
  // ذخیره محل فعلی مطالعه
  // ====================================================

  Future<void> saveCurrentPosition() async {
    final index =
        getCurrentBlockIndex();

    if (index == null) {
      return;
    }

    await ReadingPositionService
        .savePosition(
      chapterFile: widget.chapterFile,
      chapterTitle: widget.chapterTitle,
      blockIndex: index,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content:
            Text('محل مطالعه ذخیره شد'),

        duration:
            Duration(seconds: 2),
      ),
    );
  }

  // ====================================================
  // ایجاد نشانک برای محل فعلی
  // ====================================================

  Future<void> addCurrentBookmark() async {
    final index =
        getCurrentBlockIndex();

    if (index == null) {
      return;
    }

    final block = blocks[index];

    String blockTitle =
        block.text ?? '';

    if (block.number != null &&
        block.number!.isNotEmpty) {
      blockTitle =
          '${block.number} '
          '${block.text ?? ''}';
    }

    final bookmark = Bookmark(
      chapterFile: widget.chapterFile,
      chapterTitle: widget.chapterTitle,
      blockIndex: index,
      blockTitle: blockTitle,
      createdAt: DateTime.now(),
    );

    await BookmarkService.addBookmark(
      bookmark,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          blockTitle.isEmpty
              ? 'نشانک ذخیره شد'
              : 'نشانک «$blockTitle» ذخیره شد',
        ),

        duration:
            const Duration(seconds: 2),
      ),
    );
  }

  // ====================================================
  // رفتن به عنوان انتخاب‌شده
  // ====================================================

  void scrollToHeading(int index) {
    final targetContext =
        blockKeys[index].currentContext;

    if (targetContext != null) {
      Navigator.pop(context);

      Scrollable.ensureVisible(
        targetContext,

        duration:
            const Duration(milliseconds: 500),

        curve: Curves.easeInOut,

        alignment: 0.05,
      );
    }
  }

  // ====================================================
  // نمایش فهرست مطالب
  // ====================================================

  void showTableOfContents() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      builder: (context) {
        return Directionality(
          textDirection:
              TextDirection.rtl,

          child: SafeArea(
            child: SizedBox(
              height:
                  MediaQuery.of(context)
                          .size
                          .height *
                      0.75,

              child: Column(
                children: [

                  // ------------------------------------
                  // عنوان فهرست
                  // ------------------------------------

                  const Padding(
                    padding:
                        EdgeInsets.all(18),

                    child: Text(
                      'فهرست مطالب فصل',

                      style: TextStyle(
                        fontSize: 21,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  const Divider(),

                  // ------------------------------------
                  // فهرست عنوان‌ها
                  // ------------------------------------

                  Expanded(
                    child:
                        ListView.builder(
                      itemCount:
                          headingIndexes.length,

                      itemBuilder:
                          (context, position) {
                        final index =
                            headingIndexes[
                                position];

                        final block =
                            blocks[index];

                        final level =
                            block.headingLevel ??
                                1;

                        final title =
                            block.number != null &&
                                    block.number!
                                        .isNotEmpty
                                ? '${block.number} '
                                    '${block.text ?? ''}'
                                : block.text ?? '';

                        return ListTile(
                          contentPadding:
                              EdgeInsets.only(
                            right:
                                20.0 +
                                    ((level - 1) *
                                        20),

                            left: 10,
                          ),

                          title: Text(
                            title,

                            style: TextStyle(
                              fontSize:
                                  level == 1
                                      ? 17
                                      : 15,

                              fontWeight:
                                  level == 1
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),

                          onTap: () {
                            scrollToHeading(
                              index,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

        // ------------------------------------------------
        // نوار بالای صفحه
        // ------------------------------------------------

        appBar: AppBar(
          title: Text(
            widget.chapterTitle,

            maxLines: 1,

            overflow:
                TextOverflow.ellipsis,

            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),

          centerTitle: true,

          actions: [

            // ------------------------------------------
            // تنظیم اندازه متن
            // ------------------------------------------

            IconButton(
              tooltip:
                  'تنظیم اندازه متن',

              icon: const Icon(
                Icons.text_fields,
              ),

              onPressed:
                  isLoading
                      ? null
                      : openReaderSettings,
            ),

            // ------------------------------------------
            // افزودن نشانک
            // ------------------------------------------

            IconButton(
              tooltip:
                  'افزودن نشانک',

              icon: const Icon(
                Icons.bookmark_add_outlined,
              ),

              onPressed:
                  isLoading
                      ? null
                      : addCurrentBookmark,
            ),

            // ------------------------------------------
            // ذخیره محل مطالعه
            // ------------------------------------------

            IconButton(
              tooltip:
                  'ذخیره محل مطالعه',

              icon: const Icon(
                Icons.bookmark_outline,
              ),

              onPressed:
                  isLoading
                      ? null
                      : saveCurrentPosition,
            ),

            // ------------------------------------------
            // فهرست مطالب
            // ------------------------------------------

            IconButton(
              tooltip:
                  'فهرست مطالب',

              icon: const Icon(
                Icons.list_alt,
              ),

              onPressed:
                  isLoading
                      ? null
                      : showTableOfContents,
            ),
          ],
        ),

        // ------------------------------------------------
        // بدنه صفحه
        // ------------------------------------------------

        body: buildBody(),
      ),
    );
  }

  // ====================================================
  // ساخت بدنه صفحه
  // ====================================================

  Widget buildBody() {
    // --------------------------------------------------
    // حالت بارگذاری
    // --------------------------------------------------

    if (isLoading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    // --------------------------------------------------
    // نمایش خطا
    // --------------------------------------------------

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding:
              const EdgeInsets.all(24),

          child: Text(
            'خطا در بارگذاری فصل:\n\n'
            '$errorMessage',

            textAlign:
                TextAlign.center,

            style: const TextStyle(
              fontSize: 16,
              height: 1.7,
            ),
          ),
        ),
      );
    }

    // --------------------------------------------------
    // نمایش محتوای کتاب
    // --------------------------------------------------

    return Container(
      color: Theme.of(context)
          .colorScheme
          .surface,

      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          24,
          28,
          24,
          50,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,

          children: List.generate(
            blocks.length,

            (index) {
              return Container(
                key: blockKeys[index],

                // فاصله بین بلوک‌های محتوا
                margin:
                    const EdgeInsets.only(
                  bottom: 4,
                ),

                child: ContentRenderer(
                  block: blocks[index],

                  // اندازه متن انتخاب‌شده
                  // توسط کاربر
                  textScale: textScale,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}