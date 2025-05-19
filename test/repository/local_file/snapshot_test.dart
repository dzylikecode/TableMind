import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:table_mind/repository/local_file/repository.dart';

void main() {
  late String testBasePath;
  
  setUp(() {
    // Using a fixed path for testing equality
    testBasePath = '/test/path';
  });
  
  test('RepositoryFile equality should compare by wsPath', () {
    // Create file objects with the same wsPath but different File instances
    final file1 = RepositoryFile(
      wsPath: '/test_file.txt',
      file: File('${testBasePath}/test_file.txt'),
    );
    
    final file2 = RepositoryFile(
      wsPath: '/test_file.txt',
      file: File('${testBasePath}/test_file.txt'),
    );
    
    final file3 = RepositoryFile(
      wsPath: '/different_file.txt',
      file: File('${testBasePath}/different_file.txt'),
    );
    
    // Test equality
    expect(file1 == file2, isTrue, reason: 'Files with same wsPath should be equal');
    expect(file1 == file3, isFalse, reason: 'Files with different wsPath should not be equal');
    
    // Test hashCode
    expect(file1.hashCode == file2.hashCode, isTrue, reason: 'Equal files should have equal hashCodes');
  });
  
  test('RepositoryDirectory equality should compare by wsPath', () {
    // Create directory objects with the same wsPath but different Directory instances
    final dir1 = RepositoryDirectory(
      wsPath: '/test_dir',
      directory: Directory('${testBasePath}/test_dir'),
    );
    
    final dir2 = RepositoryDirectory(
      wsPath: '/test_dir',
      directory: Directory('${testBasePath}/test_dir'),
    );
    
    final dir3 = RepositoryDirectory(
      wsPath: '/different_dir',
      directory: Directory('${testBasePath}/different_dir'),
    );
    
    // Test equality
    expect(dir1 == dir2, isTrue, reason: 'Directories with same wsPath should be equal');
    expect(dir1 == dir3, isFalse, reason: 'Directories with different wsPath should not be equal');
    
    // Test hashCode
    expect(dir1.hashCode == dir2.hashCode, isTrue, reason: 'Equal directories should have equal hashCodes');
  });
  
  test('Different RepositoryItem subclasses with same wsPath should be equal', () {
    // Create a file and directory with the same path
    final file = RepositoryFile(
      wsPath: '/same_path',
      file: File('${testBasePath}/same_path'),
    );
    
    final dir = RepositoryDirectory(
      wsPath: '/same_path',
      directory: Directory('${testBasePath}/same_path'),
    );
    
    // Test equality - in the implementation, they should be equal if they have the same wsPath,
    // regardless of their concrete types
    expect(file == dir, isTrue, reason: 'Items with same wsPath should be equal regardless of type');
    expect(file.hashCode == dir.hashCode, isTrue, reason: 'Equal items should have equal hashCodes');
  });
  
  test('RepositoryItem equality with different types should return false', () {
    final file = RepositoryFile(
      wsPath: '/test_path',
      file: File('${testBasePath}/test_path'),
    );
    
    // Test with non-RepositoryItem object
    expect(file == 'not an item', isFalse, reason: 'RepositoryItem should not equal non-RepositoryItem');
    expect(file == null, isFalse, reason: 'RepositoryItem should not equal null');
  });
  
  test('Identical RepositoryItem instances should be equal', () {
    final file = RepositoryFile(
      wsPath: '/test_file.txt',
      file: File('${testBasePath}/test_file.txt'),
    );
    
    // Test identity comparison
    expect(file == file, isTrue, reason: 'Identical instances should be equal');
  });
}
