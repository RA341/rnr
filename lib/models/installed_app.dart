/// Model to describe apps shown in browse view
class InstalledApp {
  InstalledApp({
    required this.appName,
    required this.packageName,
    required this.releaseDate,
    required this.arch,
    required this.repoOwner,
    required this.repoName,
  });

  factory InstalledApp.fromList(
    String packageName,
    List<String> info,
  ) {
    if (info.length != 5) {
      ArgumentError('Invalid list length need 5 got ${info.length}');
    }

    return InstalledApp(
      packageName: packageName,
      appName: info[0],
      releaseDate: DateTime.parse(info[1]),
      arch: info[2],
      repoName: info[3],
      repoOwner: info[4],
    );
  }

  (String, List<String>) toList() => (
        packageName,
        [appName, releaseDate.toIso8601String(), arch, repoName, repoOwner],
      );

  /// app name from the repo
  String appName;

  /// app package name when its installed
  String packageName;

  /// version retrieved from asset name (NOT THE ACTUAL VERSION INSTALLED)
  DateTime releaseDate;

  /// App architecture
  String arch;

  String repoName;
  String repoOwner;
}
