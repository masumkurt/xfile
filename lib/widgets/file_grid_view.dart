import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_file/open_file.dart';
import '../models/file_manager_state.dart';
import 'file_context_menu.dart';

class FileGridView extends StatelessWidget {
  const FileGridView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FileManagerState>();
    final items = state.items;

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final item = items[i];
        return _GridItem(item: item, index: i);
      },
    );
  }
}

class _GridItem extends StatelessWidget {
  final FileItem item;
  final int index;
  const _GridItem({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final state = context.read<FileManagerState>();

    return GestureDetector(
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: item.isSelected
              ? const Color(0xFFE94560).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: item.isSelected
                ? const Color(0xFFE94560).withOpacity(0.6)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 4),
                Icon(item.icon, size: 32, color: item.iconColor),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFEAEAEA),
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!item.isDirectory && item.formattedSize.isNotEmpty)
                  Text(
                    item.formattedSize,
                    style: const TextStyle(fontSize: 9, color: Color(0xFF8892A4)),
                  ),
              ],
            ),
            if (item.isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE94560),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, size: 10, color: Colors.white),
                ),
              ),
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              bottom: 0,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onSecondaryTap: () => FileContextMenu.show(context, item),
                  onLongPress: () => state.toggleSelection(item),
                  onTap: () {
                    if (state.hasSelection) {
                      state.toggleSelection(item);
                    } else if (item.isDirectory) {
                      state.navigateTo(item.path);
                    } else {
                      OpenFile.open(item.path);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
