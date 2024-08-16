import 'package:permission_handler/permission_handler.dart';
import 'package:rnr/utils/services.dart';

Future<void> requestInstallPermissions() async {
  try {
    await Permission.requestInstallPackages.onDeniedCallback(
      () {
        logger.i('User has denied permission');
      },
    ).request();
  } catch (e) {
    logger.e(
      'Error while accepting install apps permissions',
      error: e,
    );
  }
}
