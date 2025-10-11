// Modal for searching movements and selecting
import 'package:flutter/material.dart';
import 'package:heartlandstrengthapp/services/train_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MovementSearchModal extends StatefulWidget {
  const MovementSearchModal({super.key});

  @override
  State<MovementSearchModal> createState() => _MovementSearchModalState();
}

class _MovementSearchModalState extends State<MovementSearchModal> {
  String _query = '';
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _results = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadAllMovements();
  }

  Future<void> _loadAllMovements() async {
    setState(() => _loading = true);
    final results = await TrainService().getAllMovements();
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  Future<void> _search(String q) async {
    setState(() => _loading = true);
    final results = await TrainService().searchMovements(q);
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Search Movements'),
                onChanged: (v) {
                  _query = v.trim();
                  _search(_query);
                },
              ),
              const SizedBox(height: 12),
              _loading
                  ? const CircularProgressIndicator()
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (ctx, idx) {
                          final doc = _results[idx];
                          final data = doc.data();
                          final title = data['name'] ?? 'Untitled';

                          return ListTile(
                            title: Text(title),
                            subtitle: data['description'] != null
                                ? Text(data['description'])
                                : null,
                            onTap: () {
                              Navigator.of(context).pop(data['name']); // Just return the ID
                            },
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
