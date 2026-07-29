import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:convert';

class TextFileView extends StatefulWidget {
  final String fileName;
  final TabController? tabController;
  final int? tabIndex;

  const TextFileView(
      {super.key, required this.fileName, this.tabController, this.tabIndex});

  @override
  State<TextFileView> createState() => _TextFileViewState();
}

class _TextFileViewState extends State<TextFileView> {
  String _fileContents = 'Loading...';
  bool _isLoading = true;
  final double _backgroundTransparency = 0.3;
  late String _backgroundImage;
  bool _showStoriesWip = false;

  @override
  void initState() {
    super.initState();
    _backgroundImage = 'assets/images/landing_image.jpg';
    _initBackground();
    _loadFileContents();
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
    // Attempt to read AssetManifest to discover images under assets/images/
    // excluding the landing image. If none found, fall back to landing_image.
    try {
      final manifestContent = rootBundle.loadString('AssetManifest.json');
      // We can't await here synchronously; so return landing image now and
      // start an async refresh that will update state when assets are known.
      _refreshImagesFromManifest();
    } catch (_) {
      // ignore
    }
    return 'assets/images/landing_image.jpg';
  }

  Future<void> _initBackground() async {
    final img = await _pickRandomImageFromManifest();
    if (mounted && img != null) {
      setState(() => _backgroundImage = img);
    }
  }

  Future<void> _refreshImagesFromManifest() async {
    final img = await _pickRandomImageFromManifest();
    if (mounted && img != null) {
      setState(() => _backgroundImage = img);
    }
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

  Future<void> _loadFileContents() async {
    try {
      final contents = await rootBundle.loadString(widget.fileName);
      if (mounted) {
        final isStory = widget.fileName.contains('_Story');
        final isEmpty = contents.trim().isEmpty;
        setState(() {
          _fileContents = contents;
          _isLoading = false;
          _showStoriesWip = isStory && isEmpty;
        });

        if (_showStoriesWip) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            showDialog<void>(
              context: context,
              barrierDismissible: true,
              builder: (context) => AlertDialog(
                title: const Text('Stories are Work In Progress'),
                content: const Text('Coming Soon!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            setState(() => _showStoriesWip = false);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        final isStory = widget.fileName.contains('_Story');
        setState(() {
          _isLoading = false;
          if (isStory) {
            _fileContents = '';
            _showStoriesWip = true;
          } else {
            _fileContents = 'Error loading file: ${widget.fileName}\n$e';
          }
        });

        if (_showStoriesWip) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            showDialog<void>(
              context: context,
              barrierDismissible: true,
              builder: (context) => AlertDialog(
                title: const Text('Stories are Work In Progress'),
                content: const Text('Coming Soon!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            setState(() => _showStoriesWip = false);
          });
        }
      }
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
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 24.0),
                    padding: const EdgeInsets.all(18.0),
                    constraints: const BoxConstraints(maxWidth: 900),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.36),
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 8.0)
                      ],
                    ),
                    child: Text(
                      _fileContents,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
