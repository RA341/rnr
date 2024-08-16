import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rnr/models/installed_app.dart';
import 'package:rnr/utils/services.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseManager {
  late final Database db;
  late final StoreRef<String, List<Object?>> installedAppStore;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    final dbPath = join(dir.path, 'rnr.db');
    db = await databaseFactoryIo.openDatabase(dbPath);

    installedAppStore = StoreRef<String, List<Object?>>('installedapps');
  }

  Future<void> dispose() async {
    await db.close();
  }

  Stream<InstalledApp> listenToInstalledApps(String query) {
    Filter? filter;
    if (query != '') {
      // TODO add more filters like searching version or repo
      filter = Filter.custom(
        (record) {
          return (record.key! as String)
              .toLowerCase()
              .contains(query.toLowerCase());
        },
      );
    }

    return installedAppStore.stream(db, filter: filter).map(
      (event) {
        logger.i(event.key);
        final d = event.value.map((e) => e! as String).toList();
        return InstalledApp.fromList(event.key, d);
      },
    );
  }

  Future<void> updateInstalledAppInfo({required InstalledApp app}) async {
    final (key, value) = app.toList();
    final updatedData = await installedAppStore.record(key).put(
          db,
          value,
        );

    if (updatedData != value) {
      logger.w('Data was not updated');
    }

    logger.d('updated db with ${app.appName}:${app.packageName} with key $key');
  }

  Future<void> deleteInstalledAppInfo({required InstalledApp app}) async {
    final res = await installedAppStore.record(app.packageName).delete(db);
    if (res == null) {
      logger.e('Could not delete ${app.appName}:${app.packageName}');
    }
    logger.d('Deleted ${app.appName}:${app.packageName}');
  }
}
