import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rnr/providers/browse_provider.dart';
import 'package:rnr/repos/repo_list.dart';
import 'package:rnr/utils/services.dart';
import 'package:url_launcher/url_launcher.dart';

class BrowseRepoHeader extends ConsumerWidget {
  const BrowseRepoHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repoIndex = ref.watch(repoIndexProvider);
    final repo = repoList[repoIndex];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          color: Colors.black45,
          height: 110,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const RepoPopUp(),
              IconButton(
                onPressed: () async {
                  final url = Uri.parse(
                    'https://github.com/${repo.repoOwner}/${repo.repoName}',
                  );
                  if (!await launchUrl(url)) {
                    logger.e('Could not launch $url');
                  }
                },
                icon: const Icon(Icons.link),
              ),
              IconButton(
                onPressed: () async {
                  ref.invalidate(repoProvider(repoList[repoIndex]));
                },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RepoPopUp extends ConsumerWidget {
  const RepoPopUp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repoIndex = ref.watch(repoIndexProvider);

    return PopupMenuButton<int>(
      onSelected: (value) {
        ref.read(repoIndexProvider.notifier).state = value;
      },
      itemBuilder: (BuildContext context) => repoWidgets,
      child: Text(
        repoList[repoIndex].repoName,
        style: const TextStyle(
          height: 3,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.blueGrey,
          color: Colors.white,
        ),
      ),
    );
  }
}
