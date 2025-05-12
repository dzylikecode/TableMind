## 实现一个内置的 VSCode 查看器

time: 2025-05-12 01:21:36

Android 上面没有一个好的文件查看器，为了便于观察的App的存储的数据，因此实现一个简单的，仿照 VSCode。

- [ ] 有一个文件浏览器 explorer

### explorer

![](file_explorer.excalidraw.svg)

```
event
  | newProject path
  | newFolder path
  | newFile path
  | rename path
  | delete path
  | move path
  | select file/folder
```