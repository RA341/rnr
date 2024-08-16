import 'package:github/github.dart';
import 'package:rnr/models/display_app.dart';
import 'package:rnr/repos/irepo.dart';
import 'package:rnr/utils/services.dart';

class GmsCore extends IRepo {
  @override
  final repoName = 'GmsCore';
  @override
  final repoOwner = 'ReVanced';

  @override
  List<DisplayApp> filterReleases(Release release) {
    final assets = release.assets!;
    // example release file name: app.revanced.android.gms-240913008-hw-signed.apk
    final apps = <DisplayApp>[];

    for (final asset in assets) {
      final splits = asset.name!.split('-');

      final app = DisplayApp(
        name: 'GmsCore',
        arch: 'Standard',
        downloadUrl: asset.browserDownloadUrl!,
        // year 2000 to show that a date was not returned from the api
        releaseDate: asset.createdAt ?? DateTime.utc(2000),
        size: asset.size!,
        // remove the v from the title since it contains the version number
        version: release.name!.replaceFirst('v', ''),
      );

      // if release is 'hw-signed'
      if (splits.length == 4) {
        apps.add(
          // in case of Huawei signed app
          app..arch = 'Huawei',
        );
        continue;
      }

      if (splits.length == 3) {
        apps.add(app);
        continue;
      }

      logger
        ..w('No releases detected with the given pattern')
        ..w('skipping: ${asset.name} since length of split is ${splits.length}');
    }

    return apps;
  }
}
