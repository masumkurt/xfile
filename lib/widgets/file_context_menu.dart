import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_file/open_file.dart';
import '../models/file_manager_state.dart';

class FileContextMenu {
  static void show(BuildContext context, FileItem item) {
    final state = context.read<FileManagerState>();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // File info header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(item.icon, size: 28, color: item.iconColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                        Text(
                          item.isDirectory ? 'Klasör' : '${item.extension.toUpperCase()} • ${item.formattedSize}',
                          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0x20FFFFFF)),
            _MenuItem(icon: Icons.open_in_new_rounded, label: item.isDirectory ? 'Aç' : 'Aç', onTap: () {
              Navigator.pop(ctx);
              if (item.isDirectory) state.navigateTo(item.path);
              else OpenFile.open(item.path);
            }),
            if (!item.isDirectory)
              _MenuItem(icon: Icons.apps_rounded, label: 'Birlikte Aç', onTap: () {
                Navigator.pop(ctx);
                OpenFile.open(item.path);
              }),
            const Divider(color: Color(0x20FFFFFF)),
            _MenuItem(icon: Icons.copy_rounded, label: 'Kopyala', onTap: () {
              Navigator.pop(ctx);
              state.toggleSelection(item);
              state.copySelected();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kopyalandı'), backgroundColor: Color(0xFF16213E), behavior: SnackBarBehavior.floating));
            }),
            _MenuItem(icon: Icons.content_cut_rounded, label: 'Kes', onTap: () {
              Navigator.pop(ctx);
              state.toggleSelection(item);
              state.cutSelected();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kesildi'), backgroundColor: Color(0xFF16213E), behavior: SnackBarBehavior.floating));
            }),
            _MenuItem(icon: Icons.drive_file_rename_outline_rounded, label: 'Yeniden Adlandır', onTap: () {
              Navigator.pop(ctx);
              _showRenameDialog(context, state, item);
            }),
            _MenuItem(icon: Icons.share_rounded, label: 'Paylaş', onTap: () {
              Navigator.pop(ctx);
            }),
            _MenuItem(icon: Icons.bookmark_add_rounded, label: 'Yer İmine Ekle', onTap: () {
              Navigator.pop(ctx);
              if (item.isDirectory) {
                state.addBookmark(item.path, item.name);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yer imine eklendi'), backgroundColor: Color(0xFF16213E), behavior: SnackBarBehavior.floating));
              }
            }),
            const Divider(color: Color(0x20FFFFFF)),
            _MenuItem(icon: Icons.info_outline_rounded, label: 'Özellikler', onTap: () {
              Navigator.pop(ctx);
              _showProperties(context, item);
            }),
            _MenuItem(icon: Icons.delete_outline_rounded, label: 'Sil', color: const Color(0xFFFF6B6B), onTap: () {
              Navigator.pop(ctx);
              _showDeleteDialog(context, state, item);
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static void _showRenameDialog(BuildContext context, FileManagerState state, FileItem item) {
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
              if (newName.isNotEmpty) {
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

  static void _showDeleteDialog(BuildContext context, FileManagerState state, FileItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('Sil', style: TextStyle(color: Colors.white)),
        content: Text('"${item.name}" silinsin mi?', style: const TextStyle(color: Color(0xFF8892A4))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal', style: TextStyle(color: Color(0xFF8892A4)))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              state.toggleSelection(item);
              final msg = await state.deleteSelected();
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: const Color(0xFF16213E), behavior: SnackBarBehavior.floating));
            },
            child: const Text('Sil', style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
  }

  static void _showProperties(BuildContext context, FileItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('Özellikler', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PropRow('Ad', item.name),
            _PropRow('Tür', item.isDirectory ? 'Klasör' : '${item.extension.toUpperCase()} dosyası'),
            _PropRow('Konum', item.path),
            if (!item.isDirectory) _PropRow('Boyut', item.formattedSize),
            _PropRow('Değiştirilme', item.formattedDate),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kapat', style: TextStyle(color: Color(0xFFE94560)))),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuItem({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white.withOpacity(0.8);
    return ListTile(
      leading: Icon(icon, size: 20, color: c),
      title: Text(label, style: TextStyle(fontSize: 14, color: c)),
      dense: true,
      onTap: onTap,
    );
  }
}

class _PropRow extends StatelessWidget {
  final String label;
  final String value;
  const _PropRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF8892A4)))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12, color: Colors.white))),
        ],
      ),
    );
  }
}
