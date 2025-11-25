import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'db_helper.dart';
import 'memory_model.dart';
import 'settings_page.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DBHelper _db = DBHelper();
  List<Memory> _memories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    setState(() => _loading = true);
    final data = await _db.getAllMemories();
    setState(() {
      _memories = data;
      _loading = false;
    });
  }

  Future<void> _deleteMemory(Memory m) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Memory"),
        content: const Text("Are you sure you want to delete this memory?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirm != true) return;

    await _db.deleteMemory(m.id!);

    if (m.photoPaths != null) {
      for (final p in m.photoPaths!) {
        try {
          if (File(p).existsSync()) File(p).deleteSync();
        } catch (_) {}
      }
    }

    _loadMemories();
  }

  Color _pickCardColor(int index) {
    const palette = [
      Color(0xFFAEE0ED),
      Color(0xFFE5E5E5),
      Color(0xFFC8D79B),
      Color(0xFFE5E5E5),
    ];
    return palette[index % palette.length];
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final d = DateFormat('yyyy-MM-dd HH:mm:ss').parse(raw);
      return DateFormat('dd MMM, yyyy').format(d);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD2B999),

      bottomNavigationBar: _bottomNav(),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome Back!",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 20),

                    Expanded(
                      child: _memories.isEmpty
                          ? const Center(child: Text("No memories yet"))
                          : ListView.builder(
                              itemCount: _memories.length,
                              itemBuilder: (context, i) {
                                final m = _memories[i];
                                return _memoryCard(
                                  color: _pickCardColor(i),
                                  memory: m,
                                );
                              },
                            ),
                    )
                  ],
                ),
        ),
      ),
    );
  }

  Widget _memoryCard({required Color color, required Memory memory}) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, "/view", arguments: memory);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + Icons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      memory.title ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "/view", arguments: memory);
                        },
                        child: const Icon(Icons.edit, size: 18),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _deleteMemory(memory),
                        child: const Icon(Icons.delete_outline, size: 18),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Date
              Text(
                _formatDate(memory.createdAt),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      height: 68,
      color: const Color(0xFFD2B999),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Search button (opens SearchPage)
          GestureDetector(
            onTap: () async {
              // pass current memories to SearchPage if you want, or let SearchPage load DB itself
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage()));
              await _loadMemories();
            },
            child: const Icon(Icons.search, size: 32),
          ),

          // Create button (named route '/create' expected to be registered in main.dart)
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, "/create"),
            child: const Icon(Icons.add_box_outlined, size: 32),
          ),

          // Settings button (opens SettingsPage)
          GestureDetector(
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
              await _loadMemories(); 
            },
            child: const Icon(Icons.settings_outlined, size: 32),
          ),
        ],
      ),
    );
  }
}
