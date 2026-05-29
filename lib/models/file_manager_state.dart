import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

enum ViewMode { grid, list }
enum SortBy { name, size, date, type }
enum SortOrder { asc, desc }

class FileItem {
  final String path;
  final String name;
  final bool isDirectory;
  final int size;
  final DateTime modified;
  bool isSelected;

  FileItem({
    required this.path,
    required this.name,
    required this.isDirectory,
    required this.size,
    required this.modified,
    this.isSelected = false,
  });

  String get extension => isDirectory ? '' : name.contains('.') ? name.split('.').last.toLowerCase() : '';

  String get formattedSize {
    if (isDirectory) return '';
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String get formattedDate => DateFormat('dd MMM yyyy').format(modified);

  IconData get icon {
    if (isDirectory) return Icons.folder_rounded;
    switch (extension) {
      case 'jpg': case 'jpeg': case 'png': case 'gif': case 'webp': case 'bmp':
        return Icons.image_rounded;
      case 'mp4': case 'mkv': case 'avi': case 'mov': case 'webm':
        return Icons.video_file_rounded;
      case 'mp3': case 'flac': case 'ogg': case 'wav': case 'aac':
        return Icons.audio_file_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc': case 'docx':
        return Icons.article_rounded;
      case 'xls': case 'xlsx': case 'csv':
        return Icons.table_chart_rounded;
      case 'ppt': case 'pptx':
        return Icons.slideshow_rounded;
      case 'zip': case 'rar': case 'tar': case 'gz': case '7z':
        return Icons.folder_zip_rounded;
      case 'apk':
        return Icons.android_rounded;
      case 'txt': case 'md':
        return Icons.text_snippet_rounded;
      case 'json': case 'xml': case 'dart': case 'py': case 'js': case 'html': case 'css':
        return Icons.code_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color get iconColor {
    if (isDirectory) return const Color(0xFF4FC3F7);
    switch (extension) {
      case 'jpg': case 'jpeg': case 'png': case 'gif': case 'webp': case 'bmp':
        return const Color(0xFF26C6DA);
      case 'mp4': case 'mkv': case 'avi': case 'mov': case 'webm':
        return const Color(0xFFFFB74D);
      case 'mp3': case 'flac': case 'ogg': case 'wav': case 'aac':
        return const Color(0xFFCE93D8);
      case 'pdf':
        return const Color(0xFFEF5350);
      case 'doc': case 'docx':
        return const Color(0xFF42A5F5);
      case 'xls': case 'xlsx': case 'csv':
        return const Color(0xFF66BB6A);
      case 'ppt': case 'pptx':
        return const Color(0xFFFFA726);
      case 'zip': case 'rar': case 'tar': case 'gz': case '7z':
        return const Color(0xFFFFA726);
      case 'apk':
        return const Color(0xFF3DDC84);
      default:
        return const Color(0xFF90CAF9);
    }
  }
}

class Bookmark {
  final String path;
  final String name;
  Bookmark({required this.path, required this.name});
}

class FileManagerState extends ChangeNotifier {
  List<FileItem> _items = [];
  List<FileItem> get items => _filteredItems;

  String _currentPath = '';
  String get currentPath => _currentPath;

  List<String> _pathHistory = [];
  int _historyIndex = -1;

  ViewMode _viewMode = ViewMode.grid;
  ViewMode get viewMode => _viewMode;

  SortBy _sortBy = SortBy.name;
  SortOrder _sortOrder = SortOrder.asc;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<FileItem> get selectedItems => _items.where((f) => f.isSelected).toList();
  int get selectedCount => selectedItems.length;
  bool get hasSelection => selectedCount > 0;

  List<Bookmark> _bookmarks = [];
  List<Bookmark> get bookmarks => _bookmarks;

  List<FileItem> _clipboardItems = [];
  bool _isCutOperation = false;

  List<String> get breadcrumbs {
    if (_currentPath.isEmpty) return [];
    final parts = _currentPath.split('/').where((p) => p.isNotEmpty).toList();
    return ['/', ...parts];
  }

  List<FileItem> get _filteredItems {
    if (_searchQuery.isEmpty) return _items;
    return _items.where((f) => f.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  Future<void> init() async {
    await requestPermissions();
    final dir = await getExternalStorageDirectory();
    String root = dir?.path ?? '/storage/emulated/0';
    // Navigate up to actual root storage
    while (root.contains('/Android')) {
      root = File(root).parent.path;
    }
    await navigateTo(root);
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        await Permission.storage.request();
      }
    }
    return true;
  }

  Future<void> navigateTo(String path) async {
    _isLoading = true;
    notifyListeners();

    try {
      final dir = Directory(path);
      if (!dir.existsSync()) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final entities = dir.listSync();
      final fileItems = <FileItem>[];

      for (final entity in entities) {
        try {
          final stat = entity.statSync();
          final name = entity.path.split('/').last;
          if (name.startsWith('.')) continue; // skip hidden

          fileItems.add(FileItem(
            path: entity.path,
            name: name,
            isDirectory: entity is Directory,
            size: stat.size,
            modified: stat.modified,
          ));
        } catch (_) {}
      }

      _sortItems(fileItems);
      _items = fileItems;
      _currentPath = path;

      if (_historyIndex < 0 || _pathHistory[_historyIndex] != path) {
        _pathHistory = _pathHistory.sublist(0, _historyIndex + 1);
        _pathHistory.add(path);
        _historyIndex++;
      }
    } catch (e) {
      debugPrint('Error navigating to $path: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void _sortItems(List<FileItem> items) {
    items.sort((a, b) {
      // Folders first
      if (a.isDirectory && !b.isDirectory) return -1;
      if (!a.isDirectory && b.isDirectory) return 1;

      int cmp;
      switch (_sortBy) {
        case SortBy.name:
          cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case SortBy.size:
          cmp = a.size.compareTo(b.size);
          break;
        case SortBy.date:
          cmp = a.modified.compareTo(b.modified);
          break;
        case SortBy.type:
          cmp = a.extension.compareTo(b.extension);
          break;
      }
      return _sortOrder == SortOrder.asc ? cmp : -cmp;
    });
  }

  bool get canGoBack => _historyIndex > 0;
  bool get canGoForward => _historyIndex < _pathHistory.length - 1;

  Future<void> goBack() async {
    if (canGoBack) {
      _historyIndex--;
      await navigateTo(_pathHistory[_historyIndex]);
    }
  }

  Future<void> goForward() async {
    if (canGoForward) {
      _historyIndex++;
      await navigateTo(_pathHistory[_historyIndex]);
    }
  }

  Future<void> goUp() async {
    final parent = File(_currentPath).parent.path;
    if (parent != _currentPath) {
      await navigateTo(parent);
    }
  }

  void setViewMode(ViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  void setSortBy(SortBy sortBy) {
    if (_sortBy == sortBy) {
      _sortOrder = _sortOrder == SortOrder.asc ? SortOrder.desc : SortOrder.asc;
    } else {
      _sortBy = sortBy;
      _sortOrder = SortOrder.asc;
    }
    _sortItems(_items);
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleSelection(FileItem item) {
    item.isSelected = !item.isSelected;
    notifyListeners();
  }

  void selectAll() {
    for (final item in _items) {
      item.isSelected = true;
    }
    notifyListeners();
  }

  void clearSelection() {
    for (final item in _items) {
      item.isSelected = false;
    }
    notifyListeners();
  }

  void copySelected() {
    _clipboardItems = List.from(selectedItems);
    _isCutOperation = false;
    clearSelection();
  }

  void cutSelected() {
    _clipboardItems = List.from(selectedItems);
    _isCutOperation = true;
    clearSelection();
  }

  Future<String> paste() async {
    if (_clipboardItems.isEmpty) return 'Pano boş';
    int count = 0;
    for (final item in _clipboardItems) {
      final dest = '$_currentPath/${item.name}';
      try {
        if (item.isDirectory) {
          await _copyDirectory(Directory(item.path), Directory(dest));
        } else {
          await File(item.path).copy(dest);
        }
        if (_isCutOperation) {
          if (item.isDirectory) {
            await Directory(item.path).delete(recursive: true);
          } else {
            await File(item.path).delete();
          }
        }
        count++;
      } catch (e) {
        debugPrint('Paste error: $e');
      }
    }
    _clipboardItems.clear();
    await refresh();
    return '$count öğe yapıştırıldı';
  }

  Future<void> _copyDirectory(Directory source, Directory dest) async {
    await dest.create(recursive: true);
    await for (final entity in source.list(recursive: false)) {
      final name = entity.path.split('/').last;
      if (entity is Directory) {
        await _copyDirectory(entity, Directory('${dest.path}/$name'));
      } else if (entity is File) {
        await entity.copy('${dest.path}/$name');
      }
    }
  }

  Future<String> deleteSelected() async {
    final toDelete = List.from(selectedItems);
    int count = 0;
    for (final item in toDelete) {
      try {
        if (item.isDirectory) {
          await Directory(item.path).delete(recursive: true);
        } else {
          await File(item.path).delete();
        }
        count++;
      } catch (e) {
        debugPrint('Delete error: $e');
      }
    }
    clearSelection();
    await refresh();
    return '$count öğe silindi';
  }

  Future<String> renameItem(FileItem item, String newName) async {
    final newPath = '${File(item.path).parent.path}/$newName';
    try {
      if (item.isDirectory) {
        await Directory(item.path).rename(newPath);
      } else {
        await File(item.path).rename(newPath);
      }
      await refresh();
      return 'Yeniden adlandırıldı';
    } catch (e) {
      return 'Hata: $e';
    }
  }

  Future<String> createFolder(String name) async {
    final path = '$_currentPath/$name';
    try {
      await Directory(path).create();
      await refresh();
      return 'Klasör oluşturuldu';
    } catch (e) {
      return 'Hata: $e';
    }
  }

  Future<void> refresh() async {
    await navigateTo(_currentPath);
  }

  void addBookmark(String path, String name) {
    _bookmarks.removeWhere((b) => b.path == path);
    _bookmarks.add(Bookmark(path: path, name: name));
    notifyListeners();
  }

  void removeBookmark(String path) {
    _bookmarks.removeWhere((b) => b.path == path);
    notifyListeners();
  }

  bool isBookmarked(String path) => _bookmarks.any((b) => b.path == path);
}
