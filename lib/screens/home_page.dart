// ======================================================
// صفحه معرفی کتاب
// ======================================================
//
// این صفحه جلد اصلی کتاب را نمایش می‌دهد.
//
// امکانات:
// 1. نمایش تصویر جلد
// 2. نمایش عنوان کتاب
// 3. نمایش تهیه‌کننده
// 4. لینک سایت
// 5. ورود به صفحه فهرست کتاب
// ======================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'chapter_list_page.dart';

// ======================================================
// صفحه اصلی
// ======================================================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // ====================================================
  // باز کردن سایت
  // ====================================================

  Future<void> openWebsite() async {
    final uri = Uri.parse(
      'https://hipower.ir',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  // ====================================================
  // ورود به کتاب
  // ====================================================

  void openBook(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const ChapterListPage(),
      ),
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
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [

              // ------------------------------------------------
              // تصویر جلد
              // ------------------------------------------------

              Image.asset(
                'assets/images/cover1.png',
                fit: BoxFit.cover,
              ),

              // ------------------------------------------------
              // لایه تیره روی تصویر
              // ------------------------------------------------
              //
              // این لایه کمک می‌کند نوشته‌ها روی تصویر
              // واضح‌تر دیده شوند.
              // ------------------------------------------------

              Container(
                color: Colors.black.withOpacity(0.22),
              ),

              // ------------------------------------------------
              // محتوای روی جلد
              // ------------------------------------------------

              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context)
                            .size
                            .height,
                  ),

                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 25,
                    ),

                    child: Column(
                      children: [

                        // ========================================
                        // عنوان کتاب
                        // ========================================

                        const Text(
                          'مبانی فیزیکی و کاربردی تجهیزات\n'
                          'ابزار دقیق و اندازه‌گیری صنعتی',

                          textAlign:
                              TextAlign.center,

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight:
                                FontWeight.w700,
                            height: 1.6,
                            letterSpacing: 0.2,

                            shadows: [
                              Shadow(
                                offset:
                                    Offset(1, 2),
                                blurRadius: 6,
                                color:
                                    Colors.black87,
                              ),
                            ],
                          ),
                        ),

                        // فضای میانی
                        SizedBox(
                          height:
                              MediaQuery.of(context)
                                      .size
                                      .height *
                                  0.30,
                        ),

                        // ========================================
                        // اطلاعات تهیه‌کننده
                        // ========================================

                        const Text(
                          'تهیه و تولید',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight:
                                FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset:
                                    Offset(1, 1),
                                blurRadius: 4,
                                color:
                                    Colors.black,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        const Text(
                          'حسن سلامی',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight:
                                FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset:
                                    Offset(1, 1),
                                blurRadius: 4,
                                color:
                                    Colors.black,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        // ========================================
                        // سایت
                        // ========================================

                        InkWell(
                          onTap: openWebsite,

                          child: const Text(
                            'Hipower.ir',

                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              decoration:
                                  TextDecoration
                                      .underline,
                              decorationColor:
                                  Colors.white,

                              shadows: [
                                Shadow(
                                  offset:
                                      Offset(1, 1),
                                  blurRadius: 4,
                                  color:
                                      Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 22,
                        ),

                        // ========================================
                        // دکمه ورود به کتاب
                        // ========================================

                        SizedBox(
                          width: 250,
                          height: 50,

                          child:
                              ElevatedButton.icon(
                            onPressed: () {
                              openBook(context);
                            },

                            icon: const Icon(
                              Icons.menu_book,
                            ),

                            label: const Text(
                              'ورود به کتاب',

                              style: TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}