import 'package:archive_info/archive_info.dart';
import 'package:dio/dio.dart';
import 'package:github/github.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:rnr/models/display_app.dart';
import 'package:rnr/models/installed_app.dart';
import 'package:rnr/repos/irepo.dart';
import 'package:rnr/services/app_manager.dart';
import 'package:rnr/services/file_manager.dart';
import 'package:rnr/utils/services.dart';

final sourceMan = AppSourceManager.i;

class AppSourceManager {
  AppSourceManager._();

  static AppSourceManager? inst;

  static AppSourceManager get i => inst ??= AppSourceManager._();

  Future<void> installNewApp(
    Release release,
    DisplayApp app,
    IRepo repo,
  ) async {
    final fileName = '${app.name}_${app.arch}.apk';
    final savePath = fileMan.generateDownloadPath(fileName);

    final cancelToken = CancelToken();

    // download app
    await fileMan.downloadApk(
      savePath.path,
      app.downloadUrl,
      (p0, p1) {
        print('Downloading $p0/$p1');
      },
      cancelToken,
    );

    await appMan.installApk(savePath);

    // run archive info
    final packageName = await ArchiveInfo().getPackageName(savePath.path);

    if (packageName != null) {
      final iApp = InstalledApp(
        appName: app.name,
        packageName: packageName,
        releaseDate: release.publishedAt!,
        arch: app.arch,
        repoOwner: repo.repoOwner,
        repoName: repo.repoName,
      );
      await database.updateInstalledAppInfo(app: iApp);

      logger.i('App $fileName installed, with packagename: $packageName');
    } else {
      logger
        ..e('Could not find package name from apk file: ${savePath.path}')
        ..i('add the app will not be tracked');
    }

    // todo make this into a proper try catch
    // for now both onerror and oncompleted are called
    await fileMan.deleteApk(savePath).then(
      (value) {
        logger.d('deleted apk: ${savePath.path}');
      },
    ).onError(
      (error, stackTrace) {
        logger.e(
          'Failed to delete apk: ${savePath.path}',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  void updateExistingApp(String packageName, Release release, DisplayApp app) {
    // download app

    // run archive info

    // store metadata info
    //  ~get installed package name~

    // install app

    // store to db
  }
}
