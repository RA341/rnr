import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github/github.dart';
import 'package:rnr/models/display_app.dart';
import 'package:rnr/models/display_release.dart';
import 'package:rnr/presentation/browse/browse_header.dart';
import 'package:rnr/presentation/shared/error_widget.dart';
import 'package:rnr/providers/browse_provider.dart';
import 'package:rnr/providers/installed_apps_provider.dart';
import 'package:rnr/repos/repo_list.dart';
import 'package:rnr/services/source_manager.dart';
import 'package:rnr/utils/services.dart';
import 'package:rnr/utils/utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class BrowsePage extends ConsumerWidget {
  const BrowsePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return repoList.isEmpty
        ? const Center(child: Text('No Repos configured'))
        : const Column(
            children: [
              BrowseRepoHeader(),
              Expanded(child: ReleaseList()),
            ],
          );
  }
}

// main list

class ReleaseList extends ConsumerWidget {
  const ReleaseList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repoIndex = ref.watch(repoIndexProvider);
    final repo = ref.watch(repoProvider(repoList[repoIndex]));

    final fullListLength = repo.length + 1;
    return ListView.builder(
      itemCount: fullListLength,
      itemBuilder: (context, index) => fullListLength - 1 == index
          ? const FetchMoreFooter()
          : ReleaseView(
              rel: repo[index],
              expandAssets: index == 0, // expand the latest result
            ),
    );
  }
}

class FetchMoreFooter extends ConsumerWidget {
  const FetchMoreFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repoIndex = ref.watch(repoIndexProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 50,
      ),
      child: switch (
          ref.read(repoProvider(repoList[repoIndex]).notifier).fetchState) {
        FetchState.error => AppErrorWidget(
            headerText:
                'Error occurred while fetching releases. Try refreshing again',
            errText: ref
                .read(repoProvider(repoList[repoIndex]).notifier)
                .errM
                .toString(),
          ),
        FetchState.idle => ElevatedButton(
            onPressed:
                ref.read(repoProvider(repoList[repoIndex]).notifier).fetchMore,
            child: const Text(
              'Fetch more releases',
              style: TextStyle(fontSize: 16),
            ),
          ),
        FetchState.loading => const Center(
            child: SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(),
            ),
          ),
      },
    );
  }
}

class ReleaseView extends ConsumerWidget {
  const ReleaseView({
    required this.rel,
    this.expandAssets = false,
    super.key,
  });

  final DisplayRelease rel;
  final bool expandAssets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final releaseDate = rel.release.publishedAt ?? rel.release.createdAt;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(rel.release.name ?? 'No release name'),
                if (releaseDate != null || releaseDate!.year == 69)
                  Text('Released ${timeago.format(
                    releaseDate,
                    locale: 'en_short',
                  )} ago'),
              ],
            ),
            ActionButtons(
              rel: rel,
              expandAssets: expandAssets,
            ),
          ],
        ),
      ),
    );
  }
}

class ActionButtons extends ConsumerStatefulWidget {
  const ActionButtons({
    required this.rel,
    this.expandAssets = false,
    super.key,
  });

  final DisplayRelease rel;
  final bool expandAssets;

  @override
  ConsumerState createState() => _ActionButtonsState();
}

class _ActionButtonsState extends ConsumerState<ActionButtons>
    with SingleTickerProviderStateMixin {
  late final rel = widget.rel;

  @override
  void initState() {
    assetAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    if (showAssets) {
      assetAnimController.forward();
    }

    super.initState();
  }

  @override
  void dispose() {
    assetAnimController.dispose();
    super.dispose();
  }

  void _expandAssets() {
    showAssets = !showAssets;
    if (showAssets) {
      assetAnimController.forward();
    } else {
      assetAnimController.reverse();
    }
    setState(() {});
  }

  late final AnimationController assetAnimController;

  late bool showAssets = widget.expandAssets;

  @override
  Widget build(BuildContext context) {
    final releaseUrl = rel.release.htmlUrl;
    final readme = rel.release.body;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: _expandAssets,
              icon: AnimatedIcon(
                icon: AnimatedIcons.menu_close,
                progress: assetAnimController,
              ),
              tooltip: 'assets',
            ),
            if (releaseUrl != null)
              IconButton(
                onPressed: () async {
                  final url = Uri.parse(releaseUrl);
                  if (!await launchUrl(url)) {
                    logger.e('Could not launch $url');
                  }
                },
                icon: const Icon(Icons.open_in_new_rounded),
                tooltip: 'Release url',
              ),
            IconButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  barrierColor: Colors.black,
                  builder: (context) {
                    return Markdown(
                      data: readme ?? 'No release notes found',
                      selectable: true,
                    );
                  },
                );
              },
              icon: const Icon(Icons.edit_note_sharp),
              tooltip: 'Readme',
            ),
          ],
        ),
        if (showAssets) AssetView(rel: rel),
      ],
    );
  }
}

class AssetView extends ConsumerWidget {
  const AssetView({required this.rel, super.key});

  final DisplayRelease rel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assets = rel.assets!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: Column(
        children: assets.entries
            .map((e) => AssetTile(release: rel.release, asset: e.value))
            .toList(),
      ),
    );
  }
}

class AssetTile extends ConsumerStatefulWidget {
  const AssetTile({
    required this.release,
    required this.asset,
    super.key,
  });

  final Release release;
  final List<DisplayApp> asset;

  @override
  ConsumerState createState() => _AssetTileState();
}

class _AssetTileState extends ConsumerState<AssetTile> {
  int selectedArch = 0;

  List<DisplayApp> get assets => widget.asset;

  String? get arch => DeviceManager.i.supportedArch;

  @override
  void initState() {
    if (arch != null && assets.length != 1) {
      final res = assets.indexWhere(
        (element) {
          return element.arch.toLowerCase().contains(
                arch!.toLowerCase(),
              );
        },
      );
      if (res != -1) {
        selectedArch = res;
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(assets[selectedArch].name),
                Text(assets[selectedArch].version),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                PopupMenuButton(
                  initialValue: selectedArch,
                  onSelected: _changeArch,
                  itemBuilder: (BuildContext context) => assets
                      .mapIndexed(
                        (index, element) => PopupMenuItem(
                          value: index,
                          child: Text(element.arch),
                        ),
                      )
                      .toList(),
                  child: Text(
                    'Arch: ${assets[selectedArch].arch}',
                    style: const TextStyle(
                      height: 3,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      backgroundColor: Colors.blueGrey,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  '${convertBytes(assets[selectedArch].size).toStringAsPrecision(4)} MB',
                ),
                IconButton(
                  onPressed: () async {
                    await sourceMan.installNewApp(
                      widget.release,
                      assets[selectedArch],
                      repoList[ref.watch(repoIndexProvider)],
                    );
                    ref.invalidate(installedDbProvider);
                  },
                  icon: const Icon(Icons.download),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _changeArch(int value) {
    selectedArch = value;
    setState(() {});
  }
}
