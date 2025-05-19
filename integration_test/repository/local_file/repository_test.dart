import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:table_mind/repository/local_file/repository.dart';

import 'dsl.dart';

void main() {
  testRepo(
    'Verify initial state and empty repository structure',
    expectStates:
        () => [RepoInitial(), RepoLoadInProgress(repoPath), RepoLoaded({})],
  );

  testRepo(
    'Create file and verify state',
    act: (repo) => repo.createFile('/file.txt'),
    skip: 3,
    expectStates:
        () => [
          RepoLoaded({'file.txt': null}),
        ],
  );

  testRepo(
    'Create nested folders and verify parent directory creation',
    act: (repo) => repo.createFile('/folder/subfolder/file.txt'),
    skip: 3,
    expectStates:
        () => [
          RepoLoaded({
            'folder': {
              'subfolder': {'file.txt': null},
            },
          }),
        ],
  );

  testRepo(
    'Delete file and verify empty repository',
    seed:
        (path) async => await File(p.join(path, 'file_to_delete.txt')).create(),
    act: (repo) => repo.delete('/file_to_delete.txt'),
    skip: 3,
    expectStates: () => [RepoLoaded({})],
  );

  group(
    "snapshot is data class",
    () {
      testRepo(
        'Delete folder with child files and verify recursive deletion',
        act: (repo) async {
          // Create first file and wait for state update
          await repo.createFile('/folder_to_delete/file1.txt');
          // Create second file and wait for state update
          await repo.createFile('/folder_to_delete/subfolder/file2.txt');
          // Delete folder
          await repo.delete('/folder_to_delete');
        },
        skip: 3,
        expectStates:
            () => [
              RepoLoaded({
                'folder_to_delete': {
                  'file1.txt': null,
                  'subfolder': {'file2.txt': null},
                },
              }),
              RepoLoaded({
                'folder_to_delete': {
                  'file1.txt': null,
                  'subfolder': {'file2.txt': null},
                },
              }),
              RepoLoaded({}),
            ],
      );

      testRepo(
        'Create multiple files and verify final repository state',
        act: (repo) async {
          // Create first file
          await repo.createFile('/file1.txt');
          // Create second file
          await repo.createFile('/file2.txt');
          // Create third file
          await repo.createFile('/folder/file3.txt');
        },
        skip: 3,
        expectStates:
            () => [
              RepoLoaded({'file1.txt': null}),
              RepoLoaded({'file1.txt': null, 'file2.txt': null}),
              RepoLoaded({
                'file1.txt': null,
                'file2.txt': null,
                'folder': {'file3.txt': null},
              }),
            ],
      );
    },
    skip: "These tests are expected to fail due to shared snapshot state.",
  );

  group(
    "path setting is not synchronous",
    () {
      testRepo(
        'Refresh repository and detect external file system changes',
        seed: (path) async {
          // Create a file directly in the file system (bypassing the repository)
          final filePath = p.join(path, 'external_file.txt');
          await File(filePath).create();
        },
        act: (repo) => repo.refresh(),
        expectStates:
            () => [
              RepoInitial(),
              RepoLoadInProgress(repoPath),
              RepoLoaded({'external_file.txt': null}),
              RepoLoadInProgress(repoPath),
              RepoLoaded({'external_file.txt': null}),
            ],
      );
    },
    skip:
        "This test is expected to fail due to path setting not being synchronous.",
  );

  group("snapshot is shared by state", () {
    testRepo(
      'Delete folder with child files and verify recursive deletion',
      act: (repo) async {
        // Create first file and wait for state update
        await repo.createFile('/folder_to_delete/file1.txt');
        // Create second file and wait for state update
        await repo.createFile('/folder_to_delete/subfolder/file2.txt');
        // Delete folder
        await repo.delete('/folder_to_delete');
      },
      skip: 3,
      expectStates: () => [RepoLoaded({}), RepoLoaded({}), RepoLoaded({})],
    );

    testRepo(
      'Create multiple files and verify final repository state',
      act: (repo) async {
        // Create first file
        await repo.createFile('/file1.txt');
        // Create second file
        await repo.createFile('/file2.txt');
        // Create third file
        await repo.createFile('/folder/file3.txt');
      },
      skip: 3,
      expectStates:
          () => [
            RepoLoaded({
              'file1.txt': null,
              'file2.txt': null,
              'folder': {'file3.txt': null},
            }),
            RepoLoaded({
              'file1.txt': null,
              'file2.txt': null,
              'folder': {'file3.txt': null},
            }),
            RepoLoaded({
              'file1.txt': null,
              'file2.txt': null,
              'folder': {'file3.txt': null},
            }),
          ],
    );
  });
}
