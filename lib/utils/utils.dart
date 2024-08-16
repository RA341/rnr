import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:rnr/utils/services.dart';

double convertBytes(int bytes) => bytes / (1024 * 1024);

Future<bool> testToken(String token) async {
  final headers = {
    'Authorization': 'Bearer $token',
    'User-Agent': 'rnr-app',
  };
  try {
    final res = await Dio()
        // ignore: inference_failure_on_function_invocation
        .get('https://api.github.com/meta', options: Options(headers: headers));

    if (res.statusCode != 200) {
      logger.d(
          'Failed to test new github PAT error: statusCode= ${res.statusCode}'
          ', reason=${res.statusMessage}, body:${res.data}');
      return false;
    }
    return true;
  } catch (e) {
    logger.e(e);
    return false;
  }
}

final deviceMan = DeviceManager.i;

class DeviceManager {
  DeviceManager._();

  static DeviceManager get i => _dev ??= DeviceManager._();

  static DeviceManager? _dev;

  String? supportedArch;

  Future<void> getDeviceInfo() async {
    final info = DeviceInfoPlugin();
    final androidInfo = await info.androidInfo;

    // get the supported arch
    // eg [arm64-v8a] -> v8a
    supportedArch = androidInfo.supported64BitAbis[0].split('-')[0];
  }
}
