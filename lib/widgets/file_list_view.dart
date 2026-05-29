import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_file/open_file.dart';
import '../models/file_manager_state.dart';
import 'file_context_menu.dart';

class FileListView extends StatelessWidget {
  const FileListView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FileManagerState>();
    final items = state.items;

    return Column(
      children: [
        // Header row
        Container(
          color: const Color(0xFF0F3460),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              const SizedBox(width: 32),
              Expanded(
                child: GestureDetector(
                  onTap: () => state.setSortBy(SortBy.name),
                  child: const Text('AD', style: TextStyle(fontSize: 10, color: Color(0xFF8892A4), letterSpacing: 1)),
                ),
              ),
              GestureDetector(
                onTap: () => state.setSortBy(SortBy.size),
                child: const SizedBox(
                  width: 64,
                  child: Text('BOYUT', style: TextStyle(fontSize: 10, color: Color(0xFF8892A4), letterSpacing: 1), textAlign: TextAlign.right),
                ),
              ),
              GestureDetector(
                onTap: () => state.setSortBy(SortBy.date),
                child: const SizedBox(
                  width: 90,
                  child: Text('TARİH', style: TextStyle(fontSize: 10, color: Color(0xFF8892A4), letterSpacing: 1), textAlign: TextAlign.right),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final item = items[i];
              return _ListItem(item: item);
            },
          ),
        ),
      ],
    );
  }
}

class _ListItem extends StatelessWidget {
  final FileItem item;
  const _ListItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final state = context.read<FileManagerState>();

    return InkWell(
      onTap: () {
        if (state.hasSelection) {
          state.toggleSelection(item);
        } else if (item.isDirectory) {
          state.navigateTo(item.path);
        } else {
          OpenFile.open(item.path);
        }
      },
      onLongPress: () => state.toggleSelection(item),
      onSecondaryTap: () => FileContextMenu.show(context, item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: item.isSelected
            ? const Color(0xFFE94560).withOpacity(0.15)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Checkbox or icon
            SizedBox(
              width: 32,
              child: item.isSelected
                  ? Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE94560),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, size: 12, color: Colors.white),
                    )
                  : Icon(item.icon, size: 20, color: item.iconColor),
            ),
            const SizedBox(width: 8),
            // Name
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(fontSize: 13, color: Color(0xFFEAEAEA)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Size
            SizedBox(
              width: 64,
              child: Text(
                item.formattedSize,
                style: const TextStyle(fontSize: 11, color: Color(0xFF8892A4)),
                textAlign: TextAlign.right,
              ),
            ),
            // Date
            SizedBox(
              width: 90,
              child: Text(
                item.formattedDate,
                style: const TextStyle(fontSize: 11, color: Color(0xFF8892A4)),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
