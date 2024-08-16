/// Initializes singletons in services/
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rnr/services/database.dart';
import 'package:rnr/services/file_manager.dart';
import 'package:rnr/services/github.dart';
import 'package:rnr/services/settings_manager.dart';
import 'package:rnr/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getI = GetIt.instance;

final reg = getI.registerLazySingleton;
final get = getI.get;

final logger = get<Logger>();
final settings = get<SettingsManager>();
final git = get<GithubManger>();
final database = get<DatabaseManager>();

Future<void> initServices() async {
  await initLogger();

  // db
  final database = DatabaseManager();
  await database.init();
  reg<DatabaseManager>(() => database);

  // prefs
  final prefs = await SharedPreferences.getInstance();
  reg<SettingsManager>(() => SettingsManager(prefs));

  // github
  reg<GithubManger>(GithubManger.new);

  // dev arch
  await DeviceManager.i.getDeviceInfo();

  // file manager init
  await fileMan.init();

  if (git.gitI.auth.bearerToken != null &&
      !await testToken(git.gitI.auth.bearerToken!)) {
    logger.d('Invalid Github token detected removing token');
    await settings.clearGithubToken();
  }
}

Future<void> initLogger() async {
  final extDir = await getExternalStorageDirectory();
  final logFile = await File('${extDir!.path}/rnr.log').create(recursive: true);

  // todo make 2 loggers for dev and prod
  final logger = Logger(
    level: Level.all,
    filter: kDebugMode ? DevelopmentFilter() : ProductionFilter(),
    output: kDebugMode ? ConsoleOutput() : FileOutput(file: logFile),
    printer: PrettyPrinter(
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );
  // get it register
  reg<Logger>(() => logger);
}
