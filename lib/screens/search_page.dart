// ======================================================
// صفحه جستجوی کتاب
// ======================================================
//
// این صفحه مسئول:
// 1. دریافت عبارت جستجو
// 2. جستجو در تمام فصل‌های کتاب
// 3. نمایش نتایج
// 4. باز کردن محل نتیجه در فصل مربوطه
// ======================================================

import 'package:flutter/material.dart';

import '../services/book_search_service.dart';
import 'reading_page.dart';

// ======================================================
// صفحه جستجو
// ======================================================

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

// ======================================================
// وضعیت صفحه
// ======================================================

class _SearchPageState extends State<SearchPage> {
  // کنترل کادر جستجو
  final TextEditingController searchController =
      TextEditingController();

  // نتایج جستجو
  List<BookSearchResult> results = [];

  // وضعیت جستجو
  bool isSearching = false;

  // پیام خطا
  String? errorMessage;

  // ====================================================
  // انجام جستجو
  // ====================================================

  Future<void> performSearch() async {
    final query = searchController.text.trim();

    // اگر عبارت خالی باشد
    if (query.isEmpty) {
      setState(() {
        results = [];
        errorMessage = null;
      });
      return;
    }

    setState(() {
      isSearching = true;
      errorMessage = null;
    });

    try {
      final searchResults =
          await BookSearchService.searchBook(query);

      setState(() {
        results = searchResults;
        isSearching = false;
      });
    } catch (e) {
      setState(() {
        isSearching = false;
        errorMessage = e.toString();
      });
    }
  }

  // ====================================================
  // باز کردن محل نتیجه
  // ====================================================

  void openResult(BookSearchResult result) {
    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (context) => ReadingPage(
          chapterFile: result.chapterFile,
          chapterTitle: result.chapterTitle,

          // شماره بلوکی که عبارت در آن پیدا شده
          initialBlockIndex:
              result.result.blockIndex,
        ),
      ),
    );
  }

  // ====================================================
  // آزاد کردن کنترلر
  // ====================================================

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
          title: const Text('جستجوی کتاب'),
        ),

        body: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              buildSearchBox(),

              const SizedBox(height: 16),

              Expanded(
                child: buildResults(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====================================================
  // کادر جستجو
  // ====================================================

  Widget buildSearchBox() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,

            textInputAction:
                TextInputAction.search,

            onSubmitted: (_) {
              performSearch();
            },

            decoration: const InputDecoration(
              hintText:
                  'عبارت موردنظر را وارد کنید...',

              border: OutlineInputBorder(),

              prefixIcon: Icon(
                Icons.search,
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        ElevatedButton(
          onPressed:
              isSearching ? null : performSearch,

          child: const Text('جستجو'),
        ),
      ],
    );
  }

  // ====================================================
  // نمایش نتایج
  // ====================================================

  Widget buildResults() {
    if (isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          'خطا در جستجو:\n$errorMessage',

          textAlign: TextAlign.center,
        ),
      );
    }

    if (results.isEmpty) {
      return const Center(
        child: Text(
          'نتیجه‌ای برای نمایش وجود ندارد.',

          style: TextStyle(
            fontSize: 16,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,

      children: [
        Text(
          '${results.length} نتیجه پیدا شد',

          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Expanded(
          child: ListView.builder(
            itemCount: results.length,

            itemBuilder: (context, index) {
              return buildResultItem(
                results[index],
              );
            },
          ),
        ),
      ],
    );
  }

  // ====================================================
  // نمایش یک نتیجه
  // ====================================================

  Widget buildResultItem(
    BookSearchResult result,
  ) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 8,
      ),

      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            '${result.chapterNumber}',
          ),
        ),

        title: Text(
          result.chapterTitle,

          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          BookSearchService.getDisplayText(
            result,
          ),

          maxLines: 3,

          overflow:
              TextOverflow.ellipsis,
        ),

        // کلیک روی نتیجه
        onTap: () {
          openResult(result);
        },

        trailing: const Icon(
          Icons.arrow_back_ios,
          size: 16,
        ),
      ),
    );
  }
}

