import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart' as package_man;
import 'package:rnr/models/installed_app.dart';
import 'package:rnr/providers/browse_provider.dart';
import 'package:rnr/providers/installed_apps_provider.dart';
import 'package:rnr/repos/repo_list.dart';
import 'package:rnr/utils/services.dart';

class InstalledApps extends ConsumerWidget {
  const InstalledApps({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installedDbApps = ref.watch(installedDbProvider);

    return Flexible(
      flex: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: SearchBar(
              enabled: installedDbApps.hasValue,
              hintText: 'Search apps',
              onChanged: (value) {
                ref.read(queryProvider.notifier).state = value;
              },
              // trailing: [
              //   IconButton(
              //     onPressed: () {
              //       ref.read(queryProvider.notifier).state = '';
              //     },
              //     icon: const Icon(Icons.cancel_outlined),
              //   ),
              // ],
              leading: const Icon(Icons.search_outlined),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: installedDbApps.when(
                data: (data) {
                  return RefreshIndicator(
                    displacement: 1,
                    triggerMode: RefreshIndicatorTriggerMode.anywhere,
                    onRefresh: () async {
                      ref.invalidate(installedDbProvider);
                    },
                    child: data.isEmpty
                        ? const Center(child: Text('No apps are being tracked'))
                        : ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              final (dbApp, appInfo) = data[index];
                              return Padding(
                                padding: const EdgeInsets.all(8),
                                child: InstalledAppTile(
                                  appInfo: appInfo,
                                  dbApp: dbApp,
                                ),
                              );
                            },
                          ),
                  );
                },
                error: (error, stackTrace) => Center(child: ErrorWidget(error)),
                loading: () =>
                    const Center(child: Text('No apps are being tracked')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InstalledAppTile extends ConsumerWidget {
  const InstalledAppTile({
    required this.appInfo,
    required this.dbApp,
    super.key,
  });

  final AppInfo? appInfo;
  final InstalledApp dbApp;

  static const iconSize = 40.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAppInfo = appInfo != null;

    final gnNo = ref.watch(
      repoProvider(
        findRepo(
          name: dbApp.repoName,
          owner: dbApp.repoOwner,
        ),
      ),
    );

    var updateAvailable = 0;

    if (gnNo.isNotEmpty) {
      updateAvailable = dbApp.releaseDate.compareTo(
        gnNo[0].release.publishedAt!,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: hasAppInfo
            ? updateAvailable == -1
                ? const Color.fromRGBO(36, 110, 38, 100)
                : Colors.blueAccent
            : Colors.deepPurple,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              height: iconSize,
              width: iconSize,
              child: hasAppInfo && appInfo!.icon != null
                  ? Image.memory(appInfo!.icon!)
                  : const Icon(Icons.warning_rounded, size: iconSize),
            ),
          ),
          // const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: SizedBox(
              width: 250,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasAppInfo) ...[
                      Text(
                        '${appInfo!.name} v${appInfo!.versionName}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        appInfo?.packageName ?? '',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else ...[
                      Text(
                        dbApp.appName,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Not found installed on device',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    Text(
                      'Source: ${dbApp.repoOwner}/${dbApp.repoName}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: iconSize,
            width: iconSize,
            child: IconButton(
              onPressed: () async {
                await showAppDeleteDialog(context, ref, dbApp);
              },
              icon: const Icon(Icons.delete),
            ),
          )
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 300));
  }
}

Future<void> showAppDeleteDialog(
  BuildContext context,
  WidgetRef ref,
  InstalledApp app,
) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Remove app ?'),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: <Widget>[
          TextButton(
            child: const Text('Uninstall and remove'),
            onPressed: () async {
              await package_man.InstalledApps.uninstallApp(app.packageName);
              await database.deleteInstalledAppInfo(app: app);
              ref.invalidate(installedDbProvider);
              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Only remove from database'),
            onPressed: () async {
              await database.deleteInstalledAppInfo(app: app);
              ref.invalidate(installedDbProvider);
              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
