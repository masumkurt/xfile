import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/file_manager_state.dart';

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FileManagerState>();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF16213E),
        border: Border(top: BorderSide(color: Color(0x20FFFFFF))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Text(
            '${state.selectedCount} seçili',
            style: const TextStyle(fontSize: 12, color: Color(0xFFE94560), fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          _ActionBtn(
            icon: Icons.copy_rounded,
            label: 'Kopyala',
            onTap: () {
              state.copySelected();
              _snack(context, 'Kopyalandı');
            },
          ),
          _ActionBtn(
            icon: Icons.content_cut_rounded,
            label: 'Kes',
            onTap: () {
              state.cutSelected();
              _snack(context, 'Kesildi');
            },
          ),
          _ActionBtn(
            icon: Icons.drive_file_rename_outline_rounded,
            label: 'Yeniden Adlandır',
            onTap: state.selectedCount == 1
                ? () => _showRenameDialog(context, state)
                : null,
          ),
          _ActionBtn(
            icon: Icons.share_rounded,
            label: 'Paylaş',
            onTap: () => _snack(context, 'Paylaşılıyor...'),
          ),
          _ActionBtn(
            icon: Icons.delete_rounded,
            label: 'Sil',
            color: const Color(0xFFFF6B6B),
            onTap: () => _showDeleteDialog(context, state),
          ),
          _ActionBtn(
            icon: Icons.close_rounded,
            label: 'İptal',
            onTap: () => state.clearSelection(),
          ),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF16213E),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, FileManagerState state) {
    final item = state.selectedItems.first;
    final controller = TextEditingController(text: item.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('Yeniden Adlandır', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF533483))),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE94560))),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal', style: TextStyle(color: Color(0xFF8892A4)))),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != item.name) {
                Navigator.pop(ctx);
                final msg = await state.renameItem(item, newName);
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: const Color(0xFF16213E), behavior: SnackBarBehavior.floating));
              }
            },
            child: const Text('Tamam', style: TextStyle(color: Color(0xFFE94560))),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, FileManagerState state) {
    final count = state.selectedCount;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('Sil', style: TextStyle(color: Colors.white)),
        content: Text('$count öğe kalıcı olarak silinsin mi?', style: const TextStyle(color: Color(0xFF8892A4))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal', style: TextStyle(color: Color(0xFF8892A4)))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final msg = await state.deleteSelected();
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: const Color(0xFF16213E), behavior: SnackBarBehavior.floating));
            },
            child: const Text('Sil', style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  const _ActionBtn({required this.icon, required this.label, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white.withOpacity(onTap != null ? 0.7 : 0.2);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Tooltip(
        message: label,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Icon(icon, size: 20, color: c),
        ),
      ),
    );
  }
}
