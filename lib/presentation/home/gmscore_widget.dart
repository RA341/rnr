import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rnr/presentation/browse/browse.dart';
import 'package:rnr/providers/browse_provider.dart';
import 'package:rnr/repos/repo_list.dart';

class GmsCoreWidget extends ConsumerWidget {
  const GmsCoreWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repoProvider(gmsCore));

    // final fullListLength = repo.length + 1;

    final releases = repo.map((e) => ActionButtons(rel: e)).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 30,
      ),
      child: ColoredBox(
        color: Colors.grey,
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'GmsCore',
                  style: TextStyle(fontSize: 23),
                ),
                Text('Installed Version NoVer'),
              ],
            ),
            ...releases,
          ],
        ),
      ),
    );
  }
}
