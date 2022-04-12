extension StringExt on String {
  bool isGitHubUrl() {
    return contains("github.com");
  }

  bool isGitHubRawUrl() {
    return contains("raw.githubusercontent.com");
  }
}