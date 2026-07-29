import 'dart:ui';
import 'package:flutter/material.dart';
import 'text_file_view.dart';
import 'random_line_view.dart';

class LanguageView extends StatefulWidget {
  final String language;

  const LanguageView({super.key, required this.language});

  @override
  State<LanguageView> createState() => _LanguageViewState();
}

class _LanguageViewState extends State<LanguageView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ScrollController _tabScrollController;
  bool _canScrollLeft = false;
  bool _canScrollRight = true;

  static const Map<String, Map<String, String>> translations = {
    'English': {
      'Morning': 'Morning',
      'Afternoon': 'Afternoon',
      'Evening': 'Evening',
      'Night': 'Night',
      'Stories': 'Stories',
      'Quotes': 'Quotes',
    },
    'हिन्दी': {
      'Morning': 'सुबह',
      'Afternoon': 'दोपहर',
      'Evening': 'शाम',
      'Night': 'रात',
      'Stories': 'कहानियाँ',
      'Quotes': 'उद्धरण',
    },
    'తెలుగు': {
      'Morning': 'ఉదయం',
      'Afternoon': 'మధ్యాహ్నం',
      'Evening': 'సాయంత్రం',
      'Night': 'రాత్రి',
      'Stories': 'కథలు',
      'Quotes': 'సూక్తులు',
    },
  };

  String _getLanguageFolder() {
    final language = widget.language;
    if (language == 'English') return 'English';
    if (language == 'हिन्दी') return 'Hindi';
    if (language == 'తెలుగు') return 'Telugu';
    return 'English';
  }

  String _getTranslation(String key) {
    return translations[widget.language]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabScrollController = ScrollController();
    _tabScrollController.addListener(_updateScrollButtons);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollButtons());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  void _scrollTabsRight() {
    if (!_tabScrollController.hasClients) return;
    final max = _tabScrollController.position.maxScrollExtent;
    final cur = _tabScrollController.offset;
    final next = (cur + 200.0).clamp(0.0, max);
    _tabScrollController.animateTo(next,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void _scrollTabsLeft() {
    if (!_tabScrollController.hasClients) return;
    final cur = _tabScrollController.offset;
    final prev =
        (cur - 200.0).clamp(0.0, _tabScrollController.position.maxScrollExtent);
    _tabScrollController.animateTo(prev,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void _updateScrollButtons() {
    if (!_tabScrollController.hasClients) return;
    final max = _tabScrollController.position.maxScrollExtent;
    final cur = _tabScrollController.offset;
    final canLeft = cur > 5.0;
    final canRight = cur < (max - 5.0);
    if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canLeft;
        _canScrollRight = canRight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageFolder = _getLanguageFolder();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.language),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Row(
            children: [
              Visibility(
                visible: _canScrollLeft,
                child: IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _scrollTabsLeft,
                  tooltip: 'Previous',
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _tabScrollController,
                  scrollDirection: Axis.horizontal,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabs: [
                      Tab(
                        icon: const Icon(Icons.wb_sunny),
                        text: _getTranslation('Morning'),
                      ),
                      Tab(
                        icon: const Icon(Icons.wb_sunny_outlined),
                        text: _getTranslation('Afternoon'),
                      ),
                      Tab(
                        icon: const Icon(Icons.wb_twilight),
                        text: _getTranslation('Evening'),
                      ),
                      Tab(
                        icon: const Icon(Icons.nightlight_round),
                        text: _getTranslation('Night'),
                      ),
                      Tab(
                        icon: const Icon(Icons.menu_book),
                        text: _getTranslation('Stories'),
                      ),
                      Tab(
                        icon: const Icon(Icons.format_quote),
                        text: _getTranslation('Quotes'),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: _canScrollRight,
                child: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _scrollTabsRight,
                  tooltip: 'More',
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TextFileView(
            fileName:
                'assets/texts/$languageFolder/${languageFolder}_Morning.txt',
            tabController: _tabController,
            tabIndex: 0,
          ),
          TextFileView(
            fileName:
                'assets/texts/$languageFolder/${languageFolder}_Afternoon.txt',
            tabController: _tabController,
            tabIndex: 1,
          ),
          TextFileView(
            fileName:
                'assets/texts/$languageFolder/${languageFolder}_Evening.txt',
            tabController: _tabController,
            tabIndex: 2,
          ),
          TextFileView(
            fileName:
                'assets/texts/$languageFolder/${languageFolder}_Night.txt',
            tabController: _tabController,
            tabIndex: 3,
          ),
          TextFileView(
            fileName:
                'assets/texts/$languageFolder/${languageFolder}_Story.txt',
            tabController: _tabController,
            tabIndex: 4,
          ),
          RandomLineView(
            fileName:
                'assets/texts/$languageFolder/${languageFolder}_Quotes.txt',
            tabController: _tabController,
            tabIndex: 5,
          ),
        ],
      ),
    );
  }
}
