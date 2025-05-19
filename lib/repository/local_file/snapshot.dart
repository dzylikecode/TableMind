part of 'repository.dart';

/// 仓库项，可以是文件或目录
sealed class RepositoryItem {
  final String wsPath;
  final FileSystemEntity entity;

  String? parentWsPath;
  
  /// 获取实体的绝对路径
  String get path => entity.path;
  
  /// 判断是否为目录
  bool get isDirectory;
  
  /// 判断是否为文件
  bool get isFile => !isDirectory;

  bool get isRoot => wsPath == "/";
  bool get isNotRoot => !isRoot;
  
  RepositoryItem({
    required this.wsPath,
    required this.entity,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RepositoryItem) return false;
    return wsPath == other.wsPath;
  }
  @override
  int get hashCode => wsPath.hashCode;
}

/// 文件项
final class RepositoryFile extends RepositoryItem {
  final File file;
  
  @override
  bool get isDirectory => false;
  
  RepositoryFile({
    required super.wsPath,
    required this.file,
  }) : super(entity: file);
}

/// 目录项
final class RepositoryDirectory extends RepositoryItem {
  final Directory directory;
  
  @override
  bool get isDirectory => true;

  List<RepositoryItem> children = [];
  
  RepositoryDirectory({
    required super.wsPath,
    required this.directory,
  }) : super(entity: directory);
}

class RepositorySnapshot {
  /// hashed table for fast lookup
  final Map<String, RepositoryItem> _itemsByPath = {};

  final String path;

  final RepositoryDirectory root;

  bool get isEmpty => _itemsByPath.isEmpty;

  RepositorySnapshot(
    this.path,
  ) : root = RepositoryDirectory(
    wsPath: "/",
    directory: Directory(path),
  ) {
    _itemsByPath[root.wsPath] = root;
  }

  /// 不考虑文件夹里面含有文件夹的情况
  /// [parentWsPath] 一定要已经存在 snapshot 里面
  /// 
  /// returns 如果 snapshot 变化了，返回 true
  bool add(RepositoryItem item, [String? parentWsPath]) {
    assert(item.isNotRoot,
        "Item cannot be root: ${item.wsPath}");
    
    if (contains(item.wsPath)) return false;

    final parent = parentWsPath == null
        ? root
        : _itemsByPath[parentWsPath];
    assert(parent is RepositoryDirectory,
        "Parent is not a directory: $parentWsPath");
    _itemsByPath[item.wsPath] = item;
    (parent as RepositoryDirectory).children.add(item);
    item.parentWsPath = parent.wsPath;
    return true;
  }

  /// 保证了文件夹里面含有文件的情况
  /// 
  /// returns 如果 snapshot 变化了，返回 true
  bool remove(String wsPath) {
    final item = get(wsPath);
    if (item == null) return false;

    if (item.isDirectory) {
      final dir = item as RepositoryDirectory;
      // 优先删除子文件
      // 直接用 children 不好，因为 children 在动态变化
      // 一定要用 toList, 要不然是惰性的, 还是会有那个问题
      for (final child in dir.children.map((e) => e.wsPath).toList()) {
        remove(child);
      }

      assert(dir.children.isEmpty,
          "Directory is not empty: ${dir.wsPath}");
    }

    // 删除当前文件
    _itemsByPath.remove(wsPath);

    // 删除父文件夹的引用
    assert(item.parentWsPath != null,
        "Item has no parent: $wsPath");
    final parent = _itemsByPath[item.parentWsPath!];
    assert(parent is RepositoryDirectory,
        "Parent is not a directory: ${item.parentWsPath}");
    (parent as RepositoryDirectory).children.remove(item);
    return true;
  }

  RepositoryItem? get(String wsPath) {
    return _itemsByPath[wsPath];
  }

  bool contains(String wsPath) {
    return _itemsByPath.containsKey(wsPath);
  }
}

/// 用于测试是否满足动态关系
/// item.parentWsPath == getParentWsPath_(item.wsPath);
String? getParentWsPath(String wsPath) {
  if (wsPath == "/") return null;
  
  final lastSlashIndex = wsPath.lastIndexOf('/');
  if (lastSlashIndex <= 0) return "/";
  
  return wsPath.substring(0, lastSlashIndex);
}