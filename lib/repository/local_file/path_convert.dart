part of 'repository.dart';

@visibleForTesting
String toWsPath_(String path, String workspace) {
  if (path == workspace) return "/";
  final workspaceWithSep = workspace.endsWith(p.separator)
      ? workspace
      : workspace + p.separator;
  assert(path.startsWith(workspaceWithSep));
  // 约束一定要是子文件，要不然 substring 的逻辑是错误的
  final wsPath = path.substring(workspaceWithSep.length);
  assert(!wsPath.startsWith(p.separator));
  // force all `\` to `/`
  return '/${wsPath.replaceAll(r'\', '/')}';
}

@visibleForTesting
String fromWsPath_(String wsPath, String workspace) {
  assert(wsPath.startsWith("/"));
  // 没有 `\`
  assert(!wsPath.contains(r'\'));
  // Join workspace path with wsPath (without the leading "/")
  final path = p.join(workspace, wsPath.substring(1));
  // Return normalized path according to the platform
  return p.normalize(path);
}