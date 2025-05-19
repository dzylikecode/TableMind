part of 'repository.dart';

sealed class LocalFileRepositoryState {
  const LocalFileRepositoryState();
}

final class LocalFileRepositoryInitial extends LocalFileRepositoryState {
  const LocalFileRepositoryInitial();
}

final class LocalFileRepositoryLoadInProgress extends LocalFileRepositoryState {
  final String path;
  const LocalFileRepositoryLoadInProgress(this.path);
}

final class LocalFileRepositoryLoaded extends LocalFileRepositoryState {
  final RepositorySnapshot snapshot;
  const LocalFileRepositoryLoaded(this.snapshot);
}
