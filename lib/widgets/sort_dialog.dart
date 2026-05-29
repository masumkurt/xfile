import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/file_manager_state.dart';

class SortDialog extends StatelessWidget {
  const SortDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF16213E),
      title: const Text('Sıralama', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: SortBy.values.map((s) => _SortOption(sortBy: s)).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tamam', style: TextStyle(color: Color(0xFFE94560))),
        ),
      ],
    );
  }
}

class _SortOption extends StatelessWidget {
  final SortBy sortBy;
  const _SortOption({required this.sortBy});

  String get label {
    switch (sortBy) {
      case SortBy.name: return 'Ada göre';
      case SortBy.size: return 'Boyuta göre';
      case SortBy.date: return 'Tarihe göre';
      case SortBy.type: return 'Türe göre';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(label, style: const TextStyle(fontSize: 14, color: Colors.white)),
      onTap: () {
        context.read<FileManagerState>().setSortBy(sortBy);
        Navigator.pop(context);
      },
    );
  }
}
