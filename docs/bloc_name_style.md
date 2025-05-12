## 🧩 事件命名约定（Event Conventions）

### 命名结构

事件应使用过去式命名，因为从 Bloc 的角度来看，事件是已经发生的事情。

推荐的命名格式：

`BlocSubject` + `Noun（可选）` + `Verb（事件）`

* 初始加载事件应命名为：`BlocSubjectStarted`
* 基础事件类应命名为：`BlocSubjectEvent`

### 示例

✅ 推荐命名：

```dart
sealed class CounterEvent {}

final class CounterStarted extends CounterEvent {}

final class CounterIncrementPressed extends CounterEvent {}

final class CounterDecrementPressed extends CounterEvent {}

final class CounterIncrementRetried extends CounterEvent {}
```



❌ 不推荐命名：

```dart
sealed class CounterEvent {}

final class Initial extends CounterEvent {}

final class CounterInitialized extends CounterEvent {}

final class Increment extends CounterEvent {}

final class DoIncrement extends CounterEvent {}

final class IncrementCounter extends CounterEvent {}
```



---

## 🧩 状态命名约定（State Conventions）

### 命名结构

状态应使用名词命名，因为状态表示某一特定时刻的快照。

有两种常见的状态表示方式：

#### 1. 使用子类表示不同状态

命名格式：`BlocSubject` + `Verb（动作）` + `State`

常见的状态子类包括：`Initial`、`Success`、`Failure`、`InProgress`

* 初始状态应命名为：`BlocSubjectInitial`

#### 2. 使用单一类表示状态

命名格式：`BlocSubjectState`

在这种情况下，通常使用一个枚举（enum）来表示状态的不同阶段，命名为：`BlocSubjectStatus`

枚举值包括：`initial`、`success`、`failure`、`loading`

* 基础状态类应始终命名为：`BlocSubjectState`

### 示例

✅ 推荐命名（使用子类）：

```dart
sealed class CounterState {}

final class CounterInitial extends CounterState {}

final class CounterLoadInProgress extends CounterState {}

final class CounterLoadSuccess extends CounterState {}

final class CounterLoadFailure extends CounterState {}
```



✅ 推荐命名（使用单一类）：

```dart
enum CounterStatus { initial, loading, success, failure }

final class CounterState {
  final CounterStatus status;
  final int count;

  const CounterState({required this.status, required this.count});
}
```

