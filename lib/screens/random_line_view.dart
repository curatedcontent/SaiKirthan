import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:convert';

class RandomLineView extends StatefulWidget {
  final String fileName;
  final TabController? tabController;
  final int? tabIndex;

  const RandomLineView(
      {super.key, required this.fileName, this.tabController, this.tabIndex});

  @override
  State<RandomLineView> createState() => _RandomLineViewState();
}

class _RandomLineViewState extends State<RandomLineView> {
  String _currentQuote = 'Loading...';
  List<String> _allQuotes = [];
  bool _isLoading = true;
  final double _backgroundTransparency = 0.3;
  late String _backgroundImage;

  @override
  void initState() {
    super.initState();
    _backgroundImage = 'assets/images/landing_image.jpg';
    _initBackground();
    _loadQuotes();
    if (widget.tabController != null && widget.tabIndex != null) {
      widget.tabController!.addListener(_handleTabChange);
    }
  }

  @override
  void dispose() {
    if (widget.tabController != null && widget.tabIndex != null) {
      widget.tabController!.removeListener(_handleTabChange);
    }
    super.dispose();
  }

  void _handleTabChange() {
    if (!mounted) return;
    if (widget.tabController!.index == widget.tabIndex) {
      setState(() {
        _backgroundImage = _getRandomImageName();
      });
    }
  }

  String _getRandomImageName() {
    try {
      _refreshImagesFromManifest();
    } catch (_) {}
    return 'assets/images/landing_image.jpg';
  }

  Future<void> _initBackground() async {
    final img = await _pickRandomImageFromManifest();
    if (mounted && img != null) setState(() => _backgroundImage = img);
  }

  Future<void> _refreshImagesFromManifest() async {
    final img = await _pickRandomImageFromManifest();
    if (mounted && img != null) setState(() => _backgroundImage = img);
  }

  Future<String?> _pickRandomImageFromManifest() async {
    try {
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestJson);
      final images = manifestMap.keys
          .where((k) =>
              k.startsWith('assets/images/') &&
              (k.endsWith('.png') || k.endsWith('.jpg') || k.endsWith('.jpeg')))
          .where((k) => !k.endsWith('landing_image.jpg'))
          .toList();
      if (images.isEmpty) return 'assets/images/landing_image.jpg';
      final rand = Random();
      return images[rand.nextInt(images.length)];
    } catch (e) {
      return 'assets/images/landing_image.jpg';
    }
  }

  Future<void> _loadQuotes() async {
    try {
      final contents = await rootBundle.loadString(widget.fileName);
      final lines =
          contents.split('\n').where((line) => line.trim().isNotEmpty).toList();

      if (mounted) {
        setState(() {
          _allQuotes = lines;
          _isLoading = false;
          if (lines.isNotEmpty) {
            _currentQuote = lines[Random().nextInt(lines.length)];
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentQuote = 'Error loading quotes: ${widget.fileName}\n$e';
          _isLoading = false;
        });
      }
    }
  }

  void _showRandomQuote() {
    if (_allQuotes.isNotEmpty) {
      setState(() {
        _currentQuote = _allQuotes[Random().nextInt(_allQuotes.length)];
        _backgroundImage = _getRandomImageName();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full-bleed background image (cover) with darken blend and direct blur
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
            child: Image.asset(
              _backgroundImage,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              color: Colors.black.withOpacity(0.40),
              colorBlendMode: BlendMode.darken,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.grey[200]),
            ),
          ),
        ),
        // Vignette / gradient overlay to keep focus on center
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.18),
                  Colors.transparent,
                  Colors.black.withOpacity(0.18)
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        // Content
        Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 24.0),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 18.0),
                              constraints: const BoxConstraints(maxWidth: 900),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.36),
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black26, blurRadius: 8.0)
                                ],
                              ),
                              child: Text(
                                _currentQuote,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _showRandomQuote,
                        icon: const Icon(Icons.refresh),
                        label: const Text('New Quote'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
