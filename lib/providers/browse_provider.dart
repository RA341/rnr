import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rnr/models/display_release.dart';
import 'package:rnr/repos/irepo.dart';
import 'package:rnr/utils/services.dart';

final repoIndexProvider = StateProvider<int>((ref) => 0);

final repoProvider = StateNotifierProvider.family<GithubReleaseNotifier,
    List<DisplayRelease>, IRepo>(
  (ref, arg) {
    return GithubReleaseNotifier(arg);
  },
);

class GithubReleaseNotifier extends StateNotifier<List<DisplayRelease>> {
  GithubReleaseNotifier(this.repo) : super([]) {
    _listenToReleaseStream(_page);
    _page++;
  }

  final IRepo repo;

  int _page = 1;
  FetchState fetchState = FetchState.idle;

  Object? errM;

  Future<void> fetchMore() async {
    if (fetchState == FetchState.idle) {
      _listenToReleaseStream(_page++);
    }
  }

  @override
  void dispose() {
    _page = 1;
    super.dispose();
  }

  void _listenToReleaseStream(int page) {
    fetchState = FetchState.loading;
    git.getReleases(repo, page: page).listen(
      (event) {
        state = [...state, event];
      },
      onError: (Object err, StackTrace st) {
        logger.e('Stream error', error: err, stackTrace: st);
        errM = err;
        fetchState = FetchState.error;
      },
      onDone: () {
        if (fetchState != FetchState.error) {
          fetchState = FetchState.idle;
        }
      },
    );
  }
}

enum FetchState {
  idle,
  loading,
  error,
}
