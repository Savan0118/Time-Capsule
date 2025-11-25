import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'db_helper.dart';
import 'memory_model.dart';
import 'create_memory_page.dart';

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
    final items = await _db.getAllMemories();
    setState(() {
      _memories = items;
      _loading = false;
    });
  }

  Future<void> _deleteMemory(int id, List<String>? photoPaths) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete memory'),
        content: const Text('Are you sure you want to delete this memory?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _db.deleteMemory(id);
      if (photoPaths != null && photoPaths.isNotEmpty) {
        for (final path in photoPaths) {
          try {
            final f = File(path);
            if (await f.exists()) {
              await f.delete();
            }
          } catch (_) {
            // ignore individual file delete errors
          }
        }
      }
      await _loadMemories();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Memory deleted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete memory')));
      }
    }
  }

  Future<void> _editMemory(Memory memory) async {
    final titleController = TextEditingController(text: memory.title);
    final noteController = TextEditingController(text: memory.note);

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit memory'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: noteController, decoration: const InputDecoration(labelText: 'Note')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final newTitle = titleController.text.trim();
              final newNote = noteController.text.trim();
              final updated = Memory(
                id: memory.id,
                title: newTitle,
                note: newNote,
                mood: memory.mood,
                photoPaths: memory.photoPaths,
                createdAt: memory.createdAt,
              );
              await _db.updateMemory(updated);
              Navigator.pop(context, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true) {
      await _loadMemories();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Memory updated')));
    }
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '';
    try {
      final dt = DateFormat('yyyy-MM-dd HH:mm:ss').parse(value);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateMemoryPage(mood: '')),
              );
              await _loadMemories();
            },
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _memories.isEmpty
              ? const Center(child: Text('No memories yet'))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    itemCount: _memories.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      final m = _memories[index];

                      return InkWell(
                        onTap: () async {
                          // Navigate to view page using named route if available,
                          // otherwise push the route directly using constructor.
                          // Try named route first - this requires your main.dart to handle '/view' with Memory argument.
                          final result = await Navigator.pushNamed(context, '/view', arguments: m);
                          // If named route wasn't set up, fallback to direct push:
                          if (result == null) {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ViewFallbackPage(memory: m)),
                            );
                          }
                          await _loadMemories();
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          clipBehavior: Clip.hardEdge,
                          child: Column(
                            children: [
                              Expanded(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Use the getter photoPath to display the first image if available
                                    if (m.photoPath != null && m.photoPath!.isNotEmpty && File(m.photoPath!).existsSync())
                                      Image.file(File(m.photoPath!), fit: BoxFit.cover)
                                    else
                                      Container(
                                        color: Colors.grey[200],
                                        child: const Center(child: Icon(Icons.photo, size: 48)),
                                      ),
                                    Positioned(
                                      left: 8,
                                      top: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                                        child: Text(
                                          _formatDate(m.createdAt),
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 20, color: Colors.white),
                                            onPressed: () => _editMemory(m),
                                            tooltip: 'Edit',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 20, color: Colors.white),
                                            onPressed: () => _deleteMemory(m.id!, m.photoPaths),
                                            tooltip: 'Delete',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        m.title ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      m.mood ?? '',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

/// Fallback view page in case named route '/view' is not configured.
/// You can remove this class if you already registered '/view' in main.dart.
class ViewFallbackPage extends StatelessWidget {
  final Memory memory;
  const ViewFallbackPage({super.key, required this.memory});

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '';
    try {
      final dt = DateFormat('yyyy-MM-dd HH:mm:ss').parse(value);
      return DateFormat('dd MMM, yyyy').format(dt);
    } catch (_) {
      return value ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = memory.title ?? '';
    final note = memory.note ?? '';
    final dateStr = _formatDate(memory.createdAt);

    return Scaffold(
      backgroundColor: const Color(0xFFDDF3F9),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 220,
              child: Stack(
                children: [
                  if (memory.photoPath != null && memory.photoPath!.isNotEmpty && File(memory.photoPath!).existsSync())
                    Image.file(File(memory.photoPath!), fit: BoxFit.cover, width: double.infinity)
                  else
                    Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.photo, size: 48))),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Material(
                      color: Colors.white70,
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: Text(dateStr, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
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
