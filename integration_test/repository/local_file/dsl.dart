import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:meta/meta.dart';

import 'package:table_mind/repository/local_file/repository.dart';


sealed class RepoState {
  const RepoState();

  dynamic get match;
}

final class RepoInitial extends RepoState {
  const RepoInitial();

  @override
  dynamic get match => isA<LocalFileRepositoryInitial>();
}

final class RepoLoadInProgress extends RepoState {
  final String path;
  const RepoLoadInProgress(this.path);

  @override
  dynamic get match => isA<LocalFileRepositoryLoadInProgress>()
      .having((state) => state.path, 'path', path);
}

final class RepoLoaded extends RepoState {
  final Map<String, dynamic> snapshot;
  const RepoLoaded(this.snapshot);

  @override
  dynamic get match => isA<LocalFileRepositoryLoaded>()
      .having((state) => _snapshotToMap(state.snapshot), 'snapshot', equals(snapshot));
}



class _RepoTest {
  late String repoPath;

  Future<void> setUpNewRepo() async {
    // Create a random directory in the temp folder as test repository
    final systemTempDir = Directory.systemTemp;
    final timestamp = DateTime.now().microsecondsSinceEpoch.toString();
    final tempDirPath = p.join(systemTempDir.path, 'table_mind_test_$timestamp');

    // Ensure the directory doesn't exist, then create it
    final tempDir = Directory(tempDirPath);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
    await tempDir.create();
    
    repoPath = tempDirPath;
  }

  Future<void> deleteRepo() async {
    final repoDir = Directory(repoPath);
    if (await repoDir.exists()) {
      await repoDir.delete(recursive: true);
    }
  }

  Future<void> testPattern({
    Future<void> Function(String path)? seed,
    Future<void> Function(LocalFileRepository repo)? act,
    List<RepoState> Function()? expectStates,
    int skip = 0
  }) async {
    // 比如创建一个不为空的目录
    if (seed != null) await seed(repoPath);
    // 创建仓库
    final repo = LocalFileRepository()..path = repoPath;
    // 运行操作
    if (act != null) await act(repo);
    // 监听状态
    expectStates ??= () => [];
    await expectLater(
      repo.status.skip(skip),
      emitsInOrder(expectStates().map((s) => s.match)),
    );
    // 获取实际的文件结构
    final realMap = await _dirToMap(repoPath);
    // 实际结构与仓库状态一致
    expect(realMap, equals(_snapshotToMap(repo.currentSnapshot_)));
  }
  
}

final _repoTest = _RepoTest();

String get repoPath => _repoTest.repoPath;

@isTest
void testRepo(
  Object description, {
  Future<void> Function(String path)? seed,
  Future<void> Function(LocalFileRepository repo)? act,
  List<RepoState> Function()? expectStates,
  int skip = 0,
}) {
  test(
    description,
    () async {
      await _repoTest.setUpNewRepo();
      await _repoTest.testPattern(
        seed: seed,
        act: act,
        expectStates: expectStates,
        skip: skip,
      );
      await _repoTest.deleteRepo();
    },
  );
}




// Helper function to convert repository snapshot to a map structure
Map<String, dynamic> _snapshotToMap(RepositorySnapshot snapshot) {
  Map<String, dynamic> result = {};

  // Helper function to process directory recursively
  void processDirectoryRecursively(
    RepositoryDirectory dir,
    Map<String, dynamic> target,
  ) {
    for (var child in dir.children) {
      if (child is RepositoryFile) {
        var fileName = p.basename(child.wsPath);
        target[fileName] = null;
      } else if (child is RepositoryDirectory) {
        var dirName = p.basename(child.wsPath);
        var nestedMap = <String, dynamic>{};
        target[dirName] = nestedMap;
        processDirectoryRecursively(child, nestedMap);
      }
    }
  }

  // Process the repository structure starting from root
  for (var child in snapshot.root.children) {
    if (child is RepositoryFile) {
      // Get file name without leading slash
      var fileName = p.basename(child.wsPath);
      result[fileName] = null;
    } else if (child is RepositoryDirectory) {
      // Get folder name without leading slash
      var dirName = p.basename(child.wsPath);
      var nestedMap = <String, dynamic>{};
      result[dirName] = nestedMap;
      processDirectoryRecursively(child, nestedMap);
    }
  }

  return result;
}

// Helper function to generate nested map structure from actual file system
Future<Map<String, dynamic>> _dirToMap(String dirPath) async {
  Map<String, dynamic> result = {};

  Future<void> processDir(
    Directory dir,
    String basePath,
    Map<String, dynamic> currentMap,
  ) async {
    await for (var entity in dir.list(recursive: false)) {
      String relativePath = p.relative(entity.path, from: basePath);

      if (entity is File) {
        currentMap[relativePath] = null;
      } else if (entity is Directory) {
        var childMap = <String, dynamic>{};
        currentMap[relativePath] = childMap;
        await processDir(entity, p.join(basePath, relativePath), childMap);
      }
    }
  }

  await processDir(Directory(dirPath), dirPath, result);
  return result;
}