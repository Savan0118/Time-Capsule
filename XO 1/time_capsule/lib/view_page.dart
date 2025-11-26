// view_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'memory_model.dart';

class ViewPage extends StatefulWidget {
  final Memory memory;
  const ViewPage({super.key, required this.memory});

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  int _currentImage = 0;

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '';
    try {
      final dt = DateFormat('yyyy-MM-dd HH:mm:ss').parse(value);
      return DateFormat('dd MMM, yyyy').format(dt);
    } catch (_) {
      return value;
    }
  }

  List<String> get _images {
    final p = widget.memory.photoPaths;
    if (p == null || p.isEmpty) {
      return ['/mnt/data/75d62128-c09c-412d-93d9-5dfef24686e3.png'];
    }
    return p;
  }

  Widget _buildImageViewer() {
    final imgs = _images;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: imgs.length,
            onPageChanged: (i) => setState(() => _currentImage = i),
            itemBuilder: (context, i) {
              final path = imgs[i];
              if (path.startsWith('http')) {
                return Image.network(path, fit: BoxFit.cover, width: double.infinity);
              }
              final f = File(path);
              if (f.existsSync()) {
                return Image.file(f, fit: BoxFit.cover, width: double.infinity);
              }
              return Container(
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.broken_image, size: 48)),
              );
            },
          ),

          // Page counter
          if (imgs.length > 1)
            Positioned(
              bottom: 8,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentImage + 1}/${imgs.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.memory.title ?? '';
    final note = widget.memory.note ?? '';
    final dateStr = _formatDate(widget.memory.createdAt);

    return Scaffold(
      backgroundColor: const Color(0xFFDDF3F9),

      // ✔ AppBar on top
      appBar: AppBar(
        backgroundColor: const Color(0xFFDDF3F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Memory",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ✔ Now image is BELOW the app bar
            _buildImageViewer(),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      dateStr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      note.isEmpty ? 'No additional notes.' : note,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
