/// Model to describe apps shown in browse view
class DisplayApp {
  DisplayApp({
    required this.name,
    required this.arch,
    required this.version,
    required this.downloadUrl,
    required this.size,
    required this.releaseDate,

  });

  String name;
  String version;

  /// App architecture
  String arch;

  int size;
  DateTime releaseDate;

  String downloadUrl;
}
