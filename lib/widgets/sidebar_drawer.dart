import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import '../models/file_manager_state.dart';

class SidebarDrawer extends StatefulWidget {
  const SidebarDrawer({super.key});

  @override
  State<SidebarDrawer> createState() => _SidebarDrawerState();
}

class _SidebarDrawerState extends State<SidebarDrawer> {
  String _internalStorage = '/storage/emulated/0';
  String _downloadPath = '/storage/emulated/0/Download';

  @override
  void initState() {
    super.initState();
    _loadPaths();
  }

  Future<void> _loadPaths() async {
    final extDir = await getExternalStorageDirectory();
    if (extDir != null) {
      String root = extDir.path;
      while (root.contains('/Android')) root = root.substring(0, root.lastIndexOf('/'));
      setState(() {
        _internalStorage = root;
        _downloadPath = '$root/Download';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FileManagerState>();

    return Drawer(
      backgroundColor: const Color(0xFF16213E),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE94560).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.bolt_rounded, color: Color(0xFFE94560), size: 22),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'XFile',
                        style: TextStyle(
                          color: Color(0xFFE94560),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Storage bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Dahili Depolama', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))),
                          Text('47.2 / 128 GB', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.37,
                          backgroundColor: Colors.white.withOpacity(0.08),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE94560)),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0x14FFFFFF), height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _SectionHeader('Hızlı Erişim'),
                  _DrawerItem(
                    icon: Icons.home_rounded,
                    label: 'Ana Dizin',
                    onTap: () { Navigator.pop(context); state.navigateTo(_internalStorage); },
                    isActive: state.currentPath == _internalStorage,
                  ),
                  _DrawerItem(
                    icon: Icons.download_rounded,
                    label: 'İndirilenler',
                    badge: '12',
                    onTap: () { Navigator.pop(context); state.navigateTo(_downloadPath); },
                    isActive: state.currentPath == _downloadPath,
                  ),
                  _DrawerItem(
                    icon: Icons.photo_library_rounded,
                    label: 'Fotoğraflar',
                    onTap: () { Navigator.pop(context); state.navigateTo('$_internalStorage/DCIM'); },
                  ),
                  _DrawerItem(
                    icon: Icons.music_note_rounded,
                    label: 'Müzik',
                    onTap: () { Navigator.pop(context); state.navigateTo('$_internalStorage/Music'); },
                  ),
                  _DrawerItem(
                    icon: Icons.video_library_rounded,
                    label: 'Videolar',
                    onTap: () { Navigator.pop(context); state.navigateTo('$_internalStorage/Movies'); },
                  ),
                  _DrawerItem(
                    icon: Icons.description_rounded,
                    label: 'Belgeler',
                    onTap: () { Navigator.pop(context); state.navigateTo('$_internalStorage/Documents'); },
                  ),
                  _DrawerItem(
                    icon: Icons.android_rounded,
                    label: 'APK Dosyaları',
                    onTap: () { Navigator.pop(context); state.navigateTo('$_internalStorage/Download'); },
                  ),
                  const SizedBox(height: 4),
                  _SectionHeader('Depolama'),
                  _DrawerItem(
                    icon: Icons.phone_android_rounded,
                    label: 'Dahili Depolama',
                    onTap: () { Navigator.pop(context); state.navigateTo(_internalStorage); },
                  ),
                  _DrawerItem(
                    icon: Icons.sd_card_rounded,
                    label: 'SD Kart',
                    onTap: () {},
                    subtitle: 'Takılı değil',
                  ),
                  _DrawerItem(
                    icon: Icons.usb_rounded,
                    label: 'USB / OTG',
                    onTap: () {},
                    subtitle: 'Bağlı değil',
                  ),
                  const SizedBox(height: 4),
                  _SectionHeader('Yer İmleri'),
                  if (state.bookmarks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Henüz yer imi yok',
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.3)),
                      ),
                    ),
                  ...state.bookmarks.map((b) => _DrawerItem(
                    icon: Icons.bookmark_rounded,
                    label: b.name,
                    onTap: () { Navigator.pop(context); state.navigateTo(b.path); },
                    trailing: IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16),
                      color: Colors.white.withOpacity(0.4),
                      onPressed: () => state.removeBookmark(b.path),
                    ),
                  )),
                  const SizedBox(height: 4),
                  _SectionHeader('Araçlar'),
                  _DrawerItem(
                    icon: Icons.delete_rounded,
                    label: 'Çöp Kutusu',
                    onTap: () {},
                  ),
                  _DrawerItem(
                    icon: Icons.settings_rounded,
                    label: 'Ayarlar',
                    onTap: () {},
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          color: Colors.white.withOpacity(0.35),
          letterSpacing: 1.2,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isActive;
  final Widget? trailing;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.subtitle,
    this.isActive = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE94560).withOpacity(0.15) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isActive ? const Color(0xFFE94560) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? const Color(0xFFE94560) : Colors.white.withOpacity(0.55),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: isActive ? const Color(0xFFE94560) : Colors.white.withOpacity(0.8),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.3)),
                    ),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE94560),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(badge!, style: const TextStyle(fontSize: 10, color: Colors.white)),
              ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
