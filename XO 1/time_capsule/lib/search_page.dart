// search_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'db_helper.dart';
import 'memory_model.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final DBHelper _db = DBHelper();
  List<Memory> _memories = [];
  String query = "";
  bool _loading = true;

  final Map<String, int> _moodColors = {
    'happy': 0xFFFFF9C4,
    'sad': 0xFFBBDEFB,
    'angry': 0xFFFFCDD2,
    'love': 0xFFF8BBD0,
    'relaxed': 0xFFC8E6C9,
    'neutral': 0xFFD7CCC8,
  };

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    setState(() => _loading = true);
    try {
      _memories = await _db.getAllMemories();
    } catch (e) {
      _memories = [];
    } finally {
      setState(() => _loading = false);
    }
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return "";
    final dt = DateTime.tryParse(raw);
    if (dt != null) {
      return DateFormat('yyyy-MM-dd').format(dt);
    }
    return raw;
  }

  int _colorForMemory(Memory m) {
    final mood = (m.mood ?? '').toLowerCase();
    if (_moodColors.containsKey(mood)) return _moodColors[mood]!;
    // fallback: create a pseudo-random but deterministic color based on id/title
    final seed = (m.id ?? 0) ^ (m.title?.hashCode ?? 0);
    final rgb = (seed * 2654435761) & 0x00FFFFFF;
    return 0xFF000000 | rgb;
  }

  Future<void> _deleteMemory(int? id) async {
    if (id == null) return;
    await _db.deleteMemory(id);
    await _loadMemories();
  }

  @override
  Widget build(BuildContext context) {
    final search = query.toLowerCase();
    final filtered = _memories.where((m) {
      final title = (m.title ?? '').toLowerCase();
      final date = _formatDate(m.createdAt).toLowerCase();
      return title.contains(search) || date.contains(search);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFD2B48C),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD2B48C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadMemories,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            onChanged: (v) => setState(() => query = v),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Colors.black),
              hintText: "Search by title or date (e.g. 2025-03-12)",
              filled: true,
              fillColor: const Color(0xFFDCDCDC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.search_off, size: 60, color: Colors.black54),
                          SizedBox(height: 10),
                          Text(
                            "No results found",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ],
                      )
                    : RefreshIndicator(
                        onRefresh: _loadMemories,
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, idx) {
                            final m = filtered[idx];
                            final colorValue = _colorForMemory(m);
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              color: Color(colorValue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                title: Text(
                                  m.title ?? '',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  _formatDate(m.createdAt),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                trailing: Wrap(
                                  spacing: 12,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.black87),
                                      onPressed: () async {
                                        // TODO: replace with your edit page
                                        // example:
                                        // final updated = await Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(builder: (_) => EditMemoryPage(memory: m)),
                                        // );
                                        // if (updated == true) await _loadMemories();
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.black87),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Delete memory?'),
                                            content: const Text('This will permanently delete the memory.'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await _deleteMemory(m.id);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ]),
      ),
    );
  }
}
