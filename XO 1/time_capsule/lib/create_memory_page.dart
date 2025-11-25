// create_memory_page.dart

import 'dart:typed_data';
import 'dart:io' show File;
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'mood_themes.dart';

class CreateMemoryPage extends StatefulWidget {
  final String mood;
  const CreateMemoryPage({super.key, required this.mood});

  @override
  State<CreateMemoryPage> createState() => _CreateMemoryPageState();
}

class _CreateMemoryPageState extends State<CreateMemoryPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  DateTime? _selectedDate;

  final List<Uint8List> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  late final PageController _pageController;
  int _currentPage = 0;

  // Standard field height to match Title / Date fields and Add-photos placeholder
  static const double _fieldHeight = 56.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.95, initialPage: 0);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF8B6B4A),
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<Uint8List?> _readBytesSafely(XFile file) async {
    try {
      final b = await file.readAsBytes();
      if (b.isNotEmpty && b.lengthInBytes > 32) return Uint8List.fromList(b);
    } catch (_) {}
    if (!kIsWeb && file.path.isNotEmpty) {
      try {
        final fb = await File(file.path).readAsBytes();
        if (fb.isNotEmpty && fb.lengthInBytes > 32) return Uint8List.fromList(fb);
      } catch (_) {}
    }
    return null;
  }

  bool _validImage(Uint8List? b) => b != null && b.isNotEmpty && b.lengthInBytes > 32;

  Future<void> _pickImageFromCamera({int? insertAfter}) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (picked == null) return;
      final bytes = await _readBytesSafely(picked);
      if (!_validImage(bytes)) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to read image from camera')));
        return;
      }
      _insertBytesAt(Uint8List.fromList(bytes! as List<int>), insertAfter);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not take photo')));
    }
  }

  Future<void> _pickImagesFromGallery({int? insertAfter}) async {
    try {
      final List<XFile>? picks = await _picker.pickMultiImage(
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      if (picks != null && picks.isNotEmpty) {
        final List<Uint8List> good = [];
        for (final p in picks) {
          final bytes = await _readBytesSafely(p);
          if (_validImage(bytes)) good.add(Uint8List.fromList(bytes! as List<int>));
        }
        if (good.isNotEmpty) {
          _insertBytesListAt(good, insertAfter);
        } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No valid images selected')));
        }
        return;
      }

      final XFile? pick = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      if (pick == null) return;
      final bytes = await _readBytesSafely(pick);
      if (!_validImage(bytes)) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to read image from gallery')));
        return;
      }
      _insertBytesAt(Uint8List.fromList(bytes! as List<int>), insertAfter);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not pick images from gallery')));
    }
  }

  void _insertBytesAt(Uint8List bytes, int? insertAfter) {
    final stable = Uint8List.fromList(bytes);
    setState(() {
      if (insertAfter == null || insertAfter < 0 || insertAfter >= _selectedImages.length) {
        _selectedImages.add(stable);
        _safeAnimateToIndex(_selectedImages.length - 1);
      } else {
        final insertIndex = insertAfter + 1;
        _selectedImages.insert(insertIndex, stable);
        _safeAnimateToIndex(insertIndex);
      }
    });
  }

  void _insertBytesListAt(List<Uint8List> list, int? insertAfter) {
    final clones = list.map((b) => Uint8List.fromList(b)).toList();
    setState(() {
      if (insertAfter == null || insertAfter < 0 || insertAfter >= _selectedImages.length) {
        final start = _selectedImages.length;
        _selectedImages.addAll(clones);
        _safeAnimateToIndex(start);
      } else {
        final insertIndex = insertAfter + 1;
        _selectedImages.insertAll(insertIndex, clones);
        _safeAnimateToIndex(insertIndex);
      }
    });
  }

  void _safeAnimateToIndex(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 60), () {
        if (_pageController.hasClients && index >= 0 && index < _selectedImages.length) {
          _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        }
      });
    });
  }

  void _showImageOptions({int? insertAfter}) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.photo_library)),
              title: const Text("Choose from gallery (multiple)"),
              onTap: () {
                Navigator.pop(ctx);
                Future.delayed(const Duration(milliseconds: 150), () => _pickImagesFromGallery(insertAfter: insertAfter));
              },
            ),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.camera_alt)),
              title: const Text("Take a photo"),
              onTap: () {
                Navigator.pop(ctx);
                Future.delayed(const Duration(milliseconds: 150), () => _pickImageFromCamera(insertAfter: insertAfter));
              },
            ),
            if (_selectedImages.isNotEmpty)
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.delete_forever, color: Colors.white)),
                title: const Text("Remove all photos", style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _selectedImages.clear());
                },
              ),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.close)),
              title: const Text("Cancel"),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  void _removeImageAt(int index) {
    if (index < 0 || index >= _selectedImages.length) return;
    setState(() {
      _selectedImages.removeAt(index);
      if (_selectedImages.isEmpty) {
        _currentPage = 0;
        if (_pageController.hasClients) _pageController.jumpToPage(0);
      } else if (_currentPage >= _selectedImages.length) {
        final last = _selectedImages.length - 1;
        _currentPage = last;
        if (_pageController.hasClients) _pageController.animateToPage(last, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  void selectImageAt(int index) {
    if (index < 0 || index >= _selectedImages.length) return;
    setState(() => _currentPage = index);
    if (_pageController.hasClients) _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  Widget _buildSquareCarousel(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // card uses 92% width on mobile (keeps square) clamped to max for tablets
    final double cardWidth = min(screenWidth * 0.92, 420);
    final double cardSize = cardWidth;

    // thumbnail sizing responsive to screen width
    final double thumbWidth = (screenWidth * 0.18).clamp(60.0, 110.0);
    final double thumbHeight = thumbWidth * 0.72;

    // + button size responsive
    final double plusSize = (screenWidth * 0.085).clamp(34.0, 44.0);

    // If no images: show placeholder button that matches field height
    if (_selectedImages.isEmpty) {
      return InkWell(
        onTap: () => _showImageOptions(insertAfter: null),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: _fieldHeight, // same height as TextField
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Container(
                width: _fieldHeight - 12,
                height: _fieldHeight - 12,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white),
                child: const Icon(Icons.photo_camera, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text("Add photos", style: TextStyle(color: Colors.black.withOpacity(0.9), fontSize: 16))),
              const Icon(Icons.arrow_drop_down, size: 28),
            ],
          ),
        ),
      );
    }

    // When images exist: show big square card and a responsive thumbnail row
    return Column(
      children: [
        SizedBox(
          height: cardSize,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _selectedImages.length,
            onPageChanged: (p) => setState(() => _currentPage = p),
            itemBuilder: (context, index) {
              final bytes = _selectedImages[index];

              // IMPORTANT: build the Card with an internal Stack so the delete button
              // is always inside the card bounds (won't appear outside).
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Center(
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: cardSize,
                        height: cardSize,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // the image (fills the card)
                            Image.memory(
                              bytes,
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                              errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image)),
                            ),

                            // delete button INSIDE the card (top-right)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Material(
                                color: Colors.black45,
                                shape: const CircleBorder(),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                  icon: const Icon(Icons.delete, size: 20, color: Colors.white),
                                  onPressed: () => _removeImageAt(index),
                                  tooltip: 'Remove photo',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Thumbnail row: last item is a single + button
        SizedBox(
          height: thumbHeight + 12,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length + 1,
            padding: EdgeInsets.symmetric(horizontal: max(8, screenWidth * 0.02)),
            separatorBuilder: (_, __) => SizedBox(width: max(8, screenWidth * 0.02)),
            itemBuilder: (context, idx) {
              if (idx == _selectedImages.length) {
                // single + button at the end
                return Center(
                  child: GestureDetector(
                    onTap: () => _showImageOptions(insertAfter: _selectedImages.isEmpty ? null : _selectedImages.length - 1),
                    child: Container(
                      width: plusSize,
                      height: plusSize,
                      decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.add, size: 20, color: Colors.white),
                    ),
                  ),
                );
              }

              final isActive = idx == _currentPage;
              return GestureDetector(
                onTap: () => selectImageAt(idx),
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: isActive ? thumbWidth + 10 : thumbWidth,
                      height: isActive ? thumbHeight + 8 : thumbHeight,
                      padding: EdgeInsets.all(isActive ? 4 : 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isActive ? [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))] : null,
                        border: isActive ? Border.all(color: Colors.white, width: 2) : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _selectedImages[idx],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image)),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImageAt(idx),
                        child: Container(decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle), padding: const EdgeInsets.all(2), child: const Icon(Icons.close, size: 14, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  PageController _page_controller_or_init() => _pageController;

  Route _smoothRoute(Widget page) => PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    final theme = MoodThemes.moods[widget.mood] ?? MoodThemes.moods["Calm"]!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: theme.mainColor,
      appBar: AppBar(
        backgroundColor: theme.mainColor,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text("Create Your Memory!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title field (fixed height to match add-photos placeholder)
            SizedBox(
              height: _fieldHeight,
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Title of Memory",
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Add photos / carousel
            GestureDetector(onTap: () => _showImageOptions(insertAfter: null), child: _buildSquareCarousel(context)),
            const SizedBox(height: 12),

            // Date field (same height)
            GestureDetector(
              onTap: () => _pickDate(context),
              child: AbsorbPointer(
                child: SizedBox(
                  height: _fieldHeight,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: _selectedDate == null ? "Select Date" : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _textController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Add text",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Memory created')));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.bottomNavColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Create", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
