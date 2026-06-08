final class PlannedFile {
  const PlannedFile({
    required this.relativePath,
    required this.contents,
  });

  final String relativePath;
  final String contents;
}

final class ScaffoldPlan {
  const ScaffoldPlan({
    required this.root,
    required this.files,
    this.projectEdits = const [],
  });

  final String root;
  final List<PlannedFile> files;
  final List<String> projectEdits;
}
