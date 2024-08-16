import 'dart:async';
import 'package:github/github.dart';
import 'package:rnr/models/display_app.dart';
import 'package:rnr/models/display_release.dart';
import 'package:rnr/repos/irepo.dart';
import 'package:rnr/utils/services.dart';

class GithubManger {
  GithubManger() {
    final tk = settings.getGithubToken();
    gitI = tk == null ? GitHub() : GitHub(auth: Authentication.bearerToken(tk));
  }

  late final GitHub gitI;

  void dispose() {
    gitI.dispose();
  }

  Future<void> collectRepoInfo(IRepo repo) async {
    // final repoUrl = 'https://github.com/${repo.repoOwner}/${repo.repoName}';
  }

  (int?, int?, DateTime?) getGithubApiLimits() {
    return (gitI.rateLimitRemaining, gitI.rateLimitLimit, gitI.rateLimitReset);
  }

  Stream<DisplayRelease> getReleases(
    IRepo repo, {
    int page = 1,
    int perPage = 3,
  }) async* {
    final slug = RepositorySlug(
      repo.repoOwner,
      repo.repoName,
    );

    final releases = gitI.listReleasesWithPagination(
      slug,
      page: page,
      perPage: perPage,
    );

    await for (final release in releases) {
      logRateLimits();
      try {
        if (release.assets == null) {
          logger.w('No assets found for tag:${release.id}');
          yield DisplayRelease(
            release: release,
            assets: null,
          );
        }

        try {
          yield DisplayRelease(
            release: release,
            assets: convertListToMap(repo.filterReleases(release)),
          );
        } catch (e) {
          logger.e(
            'Failed to filter release ${release.name}: ${release.url}',
            error: e,
          );

          yield DisplayRelease(
            release: release,
            assets: null,
          );
        }
      } catch (e) {
        logger.e(
          'Failed to get release {tag.name}: {tag.commit}',
          error: e,
        );

        yield* Stream.error('Failed to get release {tag.name}');
      }
    }
  }

  Map<String, List<DisplayApp>> convertListToMap(List<DisplayApp> input) {
    final result = <String, List<DisplayApp>>{};

    for (var element in input) {
      result.update(
        element.name,
        (value) => value..add(element),
        ifAbsent: () => [element],
      );
    }
    return result;
  }

  Stream<Tag> collectTags(
    RepositorySlug slug,
    int page, {
    int perPage = 3,
  }) async* {
    // VERY IMPORTANT ALWAYS PASS IN THE PAGES ARG ELSE IT WILL FETCH ALL PAGES
    yield* gitI.repositories.listTags(
      slug,
      page: page,
      pages: 1,
      perPage: perPage,
    );
  }

  void logRateLimits() {
    logger.i(
      'rateLimitLimit: ${gitI.rateLimitLimit ?? 0}\n'
      'rateLimitRemaining: ${gitI.rateLimitRemaining ?? 0}\n'
      'rateLimitReset: ${gitI.rateLimitReset ?? 0}',
    );
  }
}

extension ListReleasesWithPagination on GitHub {
  /// Lists releases for the specified
  /// repository, with pagination since the package does not support pagination
  /// API docs: https://developer.github.com/v3/repos/releases/#list-releases-for-a-repository
  Stream<Release> listReleasesWithPagination(
    RepositorySlug slug, {
    int page = 1,
    int perPage = 3,
    int pages = 1,
  }) {
    ArgumentError.checkNotNull(slug);
    return PaginationHelper(this.git.github)
        .objects<Map<String, dynamic>, Release>(
      'GET',
      '/repos/${slug.fullName}/releases',
      Release.fromJson,
      pages: pages,
      params: {'page': page, 'per_page': perPage},
    );
  }
}
