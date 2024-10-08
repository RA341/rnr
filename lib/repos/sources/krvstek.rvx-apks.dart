import 'package:github/src/common/model/repos_releases.dart';
import 'package:rnr/models/display_app.dart';
import 'package:rnr/repos/irepo.dart';

class RvxApks implements IRepo {
  @override
  final repoName = 'rvx-apks';

  @override
  final repoOwner = 'krvstek';

  @override
  List<DisplayApp> filterReleases(Release release) {
    final apps = <DisplayApp>[];

    for (final e in release.assets!) {
      if (_isNotApk(e.name!)) {
        // file extension must be a apk
        // ignore magisk files
        continue;
      }

      final (name, version, arch) = _collectMetaData(e.name!);

      apps.add(
        DisplayApp(
          name: name,
          arch: arch,
          version: version,
          downloadUrl: e.browserDownloadUrl ?? '',
          size: e.size ?? 0,
          releaseDate: e.createdAt ?? DateTime(69),
        ),
      );
    }

    return apps;
  }

  bool _isNotApk(String assetName) {
    if (assetName.split('.').last == 'apk') {
      return false;
    }
    return true;
  }

  (String, String, String) _collectMetaData(String assetName) {
    final splits = assetName.split('-');

    var name = '';
    var arch = '';
    var version = '';

    var archIndex = 0;
    for (final (ind, split) in splits.indexed) {
      // version must start with v followed by a number
      if (split.startsWith('v') && num.tryParse(split[1]) != null) {
        version = split;
        archIndex = ind + 1;
        break;
      } else {
        name += '$split ';
      }
    }

    // rest of the elements are part of the architecture scheme
    // e.g
    // 0 = "music"
    // 1 = "revanced"
    // 2 = "extended"
    // 3 = "v7.10.52"
    // 4 = "arm" <----- archIndex
    // 5 = "v7a.apk"
    // join from arch-index and remove '.apk;
    arch = splits.sublist(archIndex).join('-').replaceFirst('.apk','');
    name = name.trim();

    return (name, version, arch);
  }
}
