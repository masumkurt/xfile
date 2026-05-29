import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/file_manager_state.dart';
import '../widgets/file_grid_view.dart';
import '../widgets/file_list_view.dart';
import '../widgets/sidebar_drawer.dart';
import '../widgets/breadcrumb_bar.dart';
import '../widgets/bottom_action_bar.dart';
import '../widgets/sort_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FileManagerState>().init();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FileManagerState>();
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF1A1A2E),
      drawer: const SidebarDrawer(),
      appBar: _buildAppBar(state, theme),
      body: Column(
        children: [
          const BreadcrumbBar(),
          _buildToolbar(state, theme),
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE94560)),
                  )
                : state.items.isEmpty
                    ? _buildEmpty()
                    : state.viewMode == ViewMode.grid
                        ? const FileGridView()
                        : const FileListView(),
          ),
          if (state.hasSelection) const BottomActionBar(),
          _buildStatusBar(state),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(FileManagerState state, ThemeData theme) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Dosya ara...',
                hintStyle: TextStyle(color: Color(0xFF8892A4)),
                border: InputBorder.none,
              ),
              onChanged: (v) => context.read<FileManagerState>().setSearch(v),
            )
          : Row(
              children: [
                const Text(
                  '⚡ XFile',
                  style: TextStyle(
                    color: Color(0xFFE94560),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                context.read<FileManagerState>().setSearch('');
              }
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.wifi_rounded),
          onPressed: () {},
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          color: const Color(0xFF16213E),
          onSelected: (v) {
            switch (v) {
              case 'select_all':
                context.read<FileManagerState>().selectAll();
                break;
              case 'new_folder':
                _showNewFolderDialog();
                break;
              case 'refresh':
                context.read<FileManagerState>().refresh();
                break;
              case 'sort':
                showDialog(context: context, builder: (_) => const SortDialog());
                break;
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'new_folder', child: Text('Yeni Klasör')),
            const PopupMenuItem(value: 'select_all', child: Text('Tümünü Seç')),
            const PopupMenuItem(value: 'sort', child: Text('Sırala')),
            const PopupMenuItem(value: 'refresh', child: Text('Yenile')),
          ],
        ),
      ],
    );
  }

  Widget _buildToolbar(FileManagerState state, ThemeData theme) {
    return Container(
      height: 44,
      color: const Color(0xFF16213E),
      child: Row(
        children: [
          _ToolbarBtn(
            icon: Icons.arrow_back_rounded,
            enabled: state.canGoBack,
            onTap: () => state.goBack(),
          ),
          _ToolbarBtn(
            icon: Icons.arrow_forward_rounded,
            enabled: state.canGoForward,
            onTap: () => state.goForward(),
          ),
          _ToolbarBtn(
            icon: Icons.arrow_upward_rounded,
            onTap: () => state.goUp(),
          ),
          const _Divider(),
          _ToolbarBtn(
            icon: Icons.create_new_folder_rounded,
            onTap: _showNewFolderDialog,
          ),
          _ToolbarBtn(
            icon: Icons.copy_rounded,
            enabled: state.hasSelection,
            onTap: state.hasSelection ? () { state.copySelected(); _showSnack('Kopyalandı'); } : null,
          ),
          _ToolbarBtn(
            icon: Icons.content_cut_rounded,
            enabled: state.hasSelection,
            onTap: state.hasSelection ? () { state.cutSelected(); _showSnack('Kesildi'); } : null,
          ),
          _ToolbarBtn(
            icon: Icons.content_paste_rounded,
            onTap: () async {
              final msg = await state.paste();
              _showSnack(msg);
            },
          ),
          const _Divider(),
          const Spacer(),
          _ToolbarBtn(
            icon: Icons.sort_rounded,
            onTap: () => showDialog(context: context, builder: (_) => const SortDialog()),
          ),
          _ToolbarBtn(
            icon: state.viewMode == ViewMode.grid
                ? Icons.view_list_rounded
                : Icons.grid_view_rounded,
            onTap: () => state.setViewMode(
              state.viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_rounded, size: 56, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 12),
          Text(
            'Bu klasör boş',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(FileManagerState state) {
    final folders = state.items.where((f) => f.isDirectory).length;
    final files = state.items.where((f) => !f.isDirectory).length;

    return Container(
      height: 30,
      color: const Color(0xFF0F3460),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(Icons.folder_rounded, size: 12, color: Colors.white.withOpacity(0.5)),
          const SizedBox(width: 4),
          Text('$folders klasör', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))),
          const SizedBox(width: 12),
          Icon(Icons.insert_drive_file_rounded, size: 12, color: Colors.white.withOpacity(0.5)),
          const SizedBox(width: 4),
          Text('$files dosya', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))),
          const Spacer(),
          if (state.hasSelection)
            Text(
              '${state.selectedCount} seçili',
              style: const TextStyle(fontSize: 11, color: Color(0xFFE94560)),
            ),
        ],
      ),
    );
  }

  void _showNewFolderDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('Yeni Klasör', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Klasör adı',
            hintStyle: TextStyle(color: Color(0xFF8892A4)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF533483)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE94560)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal', style: TextStyle(color: Color(0xFF8892A4))),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(ctx);
                final msg = await context.read<FileManagerState>().createFolder(name);
                _showSnack(msg);
              }
            },
            child: const Text('Oluştur', style: TextStyle(color: Color(0xFFE94560))),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF16213E),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _ToolbarBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  const _ToolbarBtn({required this.icon, this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final color = enabled ? Colors.white.withOpacity(0.7) : Colors.white.withOpacity(0.2);
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Container(width: 0.5, height: 20, color: Colors.white.withOpacity(0.1), margin: const EdgeInsets.symmetric(horizontal: 2));
  }
}
