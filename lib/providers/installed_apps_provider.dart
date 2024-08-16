import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:rnr/models/installed_app.dart';
import 'package:rnr/services/app_manager.dart';
import 'package:rnr/utils/services.dart';

final queryProvider = StateProvider<String>((ref) {
  return '';
});

final installedDbProvider =
    StreamProvider<List<(InstalledApp, AppInfo?)>>((ref) async* {
  final query = ref.watch(queryProvider);
  var results = <(InstalledApp, AppInfo?)>[];

    ref.onDispose(() {
    results.clear();
  });

  final appStream = database.listenToInstalledApps(query);

  await for (final app in appStream) {
    logger.i('from stream ${app.packageName}');
    AppInfo? appInfo;

    try {
      appInfo = await InstalledApps.getAppInfo(app.packageName);
    } catch (e) {
      logger.i('App not found with package name: ${app.packageName}', error: e);
    }

    results = [...results, (app, appInfo)];

    yield results
      ..sort((a, b) {
        if (a.$2 == null) return 1;
        if (b.$2 == null) return -1;
        return 0;
      });
  }
});

// searching all apps
final installedAppsProvider = FutureProvider<List<AppInfo>>((ref) async {
  return appMan.getAllApps();
});

final searchAppsAsyncProvider = FutureProvider<List<AppInfo>>((ref) async {
  try {
    final apps = await ref.watch(installedAppsProvider.future);
    final query = ref.watch(queryProvider);
    if (query.isEmpty) {
      return apps;
    }

    return searchApps(query, apps);
  } catch (e) {
    logger
      ..e(e)
      ..d(
        'Search provider errored out, this is expected '
        'probably trying to read searchProvider before results are retrieved',
      );
    return [];
  }
});

List<AppInfo> searchApps(String query, List<AppInfo> apps) {
  assert(
      query.isNotEmpty, 'Query should not be empty, if (searchApps) is called');

  final results = <AppInfo>[];

  for (final app in apps) {
    if (app.packageName.toLowerCase().contains(query.toLowerCase()) ||
        app.name.toLowerCase().contains(query.toLowerCase())) {
      results.add(app);
    }
  }

  return results;
}
