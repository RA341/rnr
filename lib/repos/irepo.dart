import 'package:github/github.dart';
import 'package:rnr/models/display_app.dart';

abstract class IRepo {
  String get repoOwner;

  String get repoName;

  List<DisplayApp> filterReleases(Release release);

  @override
  @override
  bool operator ==(Object other) {
    return other is IRepo &&
        other.runtimeType == runtimeType &&
        other.repoName == repoName &&
        other.repoOwner == repoOwner;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
}
