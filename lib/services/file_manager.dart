import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rnr/utils/services.dart';

final fileMan = FileManager.i;



class FileManager {
  FileManager._();

  late final Directory downloads;
  late final Dio dio;

  static FileManager? _instance;

  static FileManager get i => _instance ??= FileManager._();

  Future<void> init() async {
    dio = Dio();
    downloads = (await getDownloadsDirectory())!;
  }

  Uri generateDownloadPath(String appName) => Uri.file('${downloads.path}/$appName');

  Future<void> deleteApk(
    Uri filePath,
  ) async {
    final file = File.fromUri(filePath);
    try {
      await file.delete();
    } on Exception catch (e) {
      logger.e('Failed to delete file', error: e);
    }
  }

  Future<void> downloadApk(
    String filePath,
    String uri,
    void Function(int, int)? onReceiveProgress,
    CancelToken cancel,
  ) async {
    await dio.download(
      uri,
      filePath,
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancel,
    );
  }
}
