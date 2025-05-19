import 'dart:io';
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

part 'path_convert.dart';
part 'snapshot.dart';
part 'state.dart';


/// 所有的文件操作都限制在一个目录下
/// `/`代表所选的文件夹
class LocalFileRepository {
  // 就采用冷流
  final _controller = StreamController<LocalFileRepositoryState>();

  Stream<LocalFileRepositoryState> get status async* {
    yield LocalFileRepositoryInitial();
    yield* _controller.stream;
  }

  RepositorySnapshot? _snapshot;

  String _path = "";
  String get path => _path;
  set path(String value) {
    _path = value;
    assert(Directory(path).existsSync(), "Path does not exist");
    refresh();
  }

  Future<void> refresh() async {
    _controller.add(LocalFileRepositoryLoadInProgress(_path));
    _controller.add(LocalFileRepositoryLoaded(
      await _fetchSnapshot(_path),
    ));
  }

  String toWsPath(String path) => toWsPath_(path, _path);
  String fromWsPath(String wsPath) => fromWsPath_(wsPath, _path);

  // 合并信息为一个
  Future<RepositoryDirectory> createFolder(String wsPath) async {
    final path = fromWsPath(wsPath);
    var dir = Directory(path);
    if (await dir.exists()) {
      final item = _snapshot!.get(wsPath) as RepositoryDirectory;
      assert(_addDirectoryRecursively(_snapshot!, wsPath) == false,
          "snapshot should not change");
      // 保持沉默，不发送事件
      return item;
    }
    dir = await dir.create(recursive: true);
    final item = RepositoryDirectory(
      wsPath: wsPath,
      directory: dir,
    );
    final snapshotChanged = _addDirectoryRecursively(_snapshot!, wsPath);
    assert(snapshotChanged, "snapshot should change");
    _controller.add(LocalFileRepositoryLoaded(_snapshot!));
    return item;
  }

  Future<RepositoryFile> createFile(String wsPath) async {
    final path = fromWsPath(wsPath);
    var file = File(path);
    if (await file.exists()) {
      final item = _snapshot!.get(wsPath) as RepositoryFile;
      assert(_addFileRecursively(_snapshot!, wsPath) == false,
          "snapshot should not change");
      // 不发送发送事件
      return item;
    }
    file = await file.create(recursive: true);
    final item = RepositoryFile(
      wsPath: wsPath,
      file: file,
    );
    final snapshotChanged = _addFileRecursively(_snapshot!, wsPath);
    assert(snapshotChanged, "snapshot should change");
    _controller.add(LocalFileRepositoryLoaded(_snapshot!));
    return item;
  }

  Future<void> delete(String wsPath) async {
    final path = fromWsPath(wsPath);
    final type = await FileSystemEntity.type(path);
    assert(type != FileSystemEntityType.notFound,
        "File not found: $wsPath");
    
    switch (type) {
      case FileSystemEntityType.directory:
        await Directory(path).delete(recursive: true);
      case FileSystemEntityType.file:
        await File(path).delete();
      default:
        throw Exception("Unsupported file system entity: $wsPath");
    }
    _snapshot!.remove(wsPath);
    _controller.add(LocalFileRepositoryLoaded(_snapshot!));
  }

  Future<RepositorySnapshot> _fetchSnapshot(String path) async {
    _snapshot = RepositorySnapshot(path);
    _guardChildren(_snapshot!.root);
    return _snapshot!;
  }

  Future<void> _guardChildren(RepositoryDirectory parent) async {
    final dir = parent.directory;
    assert(await dir.exists(), "Directory does not exist: ${parent.wsPath}");
    await for (final entity in dir.list(recursive: false)) {
      switch (entity) {
        case Directory(path: var path):
          final dirItem = RepositoryDirectory(
            wsPath: toWsPath(path),
            directory: entity,
          );
          _snapshot!.add(dirItem, parent.wsPath);
          _guardChildren(dirItem);
        case File(path: var path):
          final fileItem = RepositoryFile(
            wsPath: toWsPath(path),
            file: entity,
          );
          _snapshot!.add(fileItem, parent.wsPath);
        default:
          throw Exception("Unsupported file system entity: ${entity.path}");
      }
    }
  }

  /// 相当于 createFolder(recursive: true)
  bool _addDirectoryRecursively(RepositorySnapshot snapshot, String wsPath) {
    if (snapshot.contains(wsPath)) return false;
    
    final parentWsPath = getParentWsPath(wsPath);
    assert(parentWsPath != null, "Parent path cannot be null");
    _addDirectoryRecursively(snapshot, parentWsPath!);
    final item = RepositoryDirectory(
      wsPath: wsPath,
      directory: Directory(fromWsPath(wsPath)),
    );
    return snapshot.add(item, parentWsPath);
  }

  bool _addFileRecursively(RepositorySnapshot snapshot, String wsPath) {
    if (snapshot.contains(wsPath)) return false;
    
    final parentWsPath = getParentWsPath(wsPath);
    assert(parentWsPath != null, "Parent path cannot be null");
    _addDirectoryRecursively(snapshot, parentWsPath!);
    final item = RepositoryFile(
      wsPath: wsPath,
      file: File(fromWsPath(wsPath)),
    );
    return snapshot.add(item, parentWsPath);
  }

  @visibleForTesting
  RepositorySnapshot get currentSnapshot_ => _snapshot!;
}

