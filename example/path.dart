import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:table_mind/repository/local_file/repository.dart';
import 'package:path/path.dart' as p;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final tempDir = await getTemporaryDirectory();
  final wkDir = p.join(tempDir.path, "table_mind");
  if (!Directory(wkDir).existsSync()) {
    Directory(wkDir).createSync(recursive: true);
  }
  final repo = LocalFileRepository()..path = wkDir;
  print("start to create folder");
  final folder = await repo.createFolder("/test");
  print("create folder: ${folder.path}");
  // 延迟一段时间，确保文件系统事件被触发
  await Future.delayed(Duration(seconds: 4));
  print("start to create file");
  final file = await repo.createFile("/test/file.txt");
  print("create file: ${file.path}");
  // 延迟一段时间，确保文件系统事件被触发
  await Future.delayed(Duration(seconds: 4));
  print("start to delete file");
  await repo.delete("/test/file.txt");
  print("delete file: ${file.path}");
  // 延迟一段时间，确保文件系统事件被触发
  await Future.delayed(Duration(seconds: 4));
  print("start to delete folder");
  await repo.delete("/test");
  print("delete folder: ${folder.path}");
  // 延迟一段时间，确保文件系统事件被触发
  await Future.delayed(Duration(seconds: 4));
}