import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:table_mind/repository/local_file/repository.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('LocalFileRepository path conversion tests', () {
    late String rootDir;
    late String userWorkspace;
    
    setUp(() {
      rootDir = Platform.isWindows ? 'C:\\' : '/';
      
      // Create paths using p.join to make them platform-independent
      final home = 'home';
      final user = 'user';
      final workspace = 'workspace';
      
      userWorkspace = p.join(rootDir, home, user, workspace);
    });
    
    group('User workspace with file in workspace root', () {
      test('toWsPath_ converts path to workspace path for file in workspace root', () {
        // Create the path using p.join
        final path = p.join(userWorkspace, 'file.txt');
            
        final result = toWsPath_(path, userWorkspace);
        expect(result, '/file.txt');
      });
      
      test('fromWsPath_ converts workspace path to absolute path for file in workspace root', () {
        final wsPath = '/file.txt';
        final result = fromWsPath_(wsPath, userWorkspace);
        
        final expected = p.join(userWorkspace, 'file.txt');
        expect(result, expected);
      });
    });
    
    group('User workspace with file in subfolder', () {
      test('toWsPath_ converts path to workspace path for file in subfolder', () {
        // Create the path using p.join
        final path = p.join(userWorkspace, 'folder', 'file.txt');
            
        final result = toWsPath_(path, userWorkspace);
        expect(result, '/folder/file.txt');
      });
      
      test('fromWsPath_ converts workspace path to absolute path for file in subfolder', () {
        final wsPath = '/folder/file.txt';
        final result = fromWsPath_(wsPath, userWorkspace);
        
        final expected = p.join(userWorkspace, 'folder', 'file.txt');
        expect(result, expected);
      });
    });
    
    group('Root directory as workspace with file in root', () {
      test('toWsPath_ converts path to workspace path for file in root directory', () {
        // Create the path using p.join
        final path = p.join(rootDir, 'file.txt');
            
        final result = toWsPath_(path, rootDir);
        expect(result, '/file.txt');
      });
      
      test('fromWsPath_ converts workspace path to absolute path for file in root directory', () {
        final wsPath = '/file.txt';
        final result = fromWsPath_(wsPath, rootDir);
        
        final expected = p.join(rootDir, 'file.txt');
        expect(result, expected);
      });
    });
    
    group('Root directory as workspace with file in subfolder', () {
      test('toWsPath_ converts path to workspace path for file in subfolder of root', () {
        // Create the path using p.join
        final path = p.join(rootDir, 'folder', 'file.txt');
            
        final result = toWsPath_(path, rootDir);
        expect(result, '/folder/file.txt');
      });
      
      test('fromWsPath_ converts workspace path to absolute path for file in subfolder of root', () {
        final wsPath = '/folder/file.txt';
        final result = fromWsPath_(wsPath, rootDir);
        
        final expected = p.join(rootDir, 'folder', 'file.txt');
        expect(result, expected);
      });
    });
    
    // Additional edge cases
    group('Edge cases and error conditions', () {
      test('toWsPath_ returns / for workspace root path', () {
        final result = toWsPath_(userWorkspace, userWorkspace);
        expect(result, '/');
      });
      
      test('fromWsPath_ handles root workspace path', () {
        final wsPath = '/';
        final result = fromWsPath_(wsPath, userWorkspace);
        expect(result, userWorkspace);
      });
      
      test('toWsPath_ throws assertion error when path is not prefixed correctly', () {
        // Create a path with a different workspace
        final otherWorkspace = p.join(rootDir, 'home', 'user', 'other_workspace');
        final invalidPath = p.join(otherWorkspace, 'file.txt');
        
        expect(() => toWsPath_(invalidPath, userWorkspace), throwsA(isA<AssertionError>()));
      });
      
      test('toWsPath_ throws assertion error for path with similar prefix but not a subfolder', () {
        // Create a path with a similar prefix but not a subfolder
        final workspaceSuffix = userWorkspace + '_suffix';
        final prefixPath = p.join(workspaceSuffix, 'file.txt');
        
        expect(() => toWsPath_(prefixPath, userWorkspace), throwsA(isA<AssertionError>()));
      });
      
      test('fromWsPath_ throws assertion error for paths without leading /', () {
        final invalidWsPath = 'file.txt'; // Missing leading '/'
        
        expect(() => fromWsPath_(invalidWsPath, userWorkspace), throwsA(isA<AssertionError>()));
      });
      
      test('fromWsPath_ throws assertion error for paths with backslash', () {
        final invalidWsPath = '/folder\\file.txt'; // Contains backslash
        
        expect(() => fromWsPath_(invalidWsPath, userWorkspace), throwsA(isA<AssertionError>()));
      });
    });
  });
}
