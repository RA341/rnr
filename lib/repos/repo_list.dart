import 'package:flutter/material.dart';
import 'package:rnr/repos/irepo.dart';
import 'package:rnr/repos/sources/krvstek.rvx-apks.dart';
import 'package:rnr/repos/sources/revanced.gmscore.dart';
import 'package:rnr/repos/sources/revancedapks.buildapps.dart';

// IMP: DO NOT INITIALIZE INSIDE CONSUMER WIDGET, IT WILL CAUSE A INFINITE REBUILD
final repoList = <IRepo>[
  BuildApps(),
  RvxApks(),
];

IRepo findRepo({
  required String owner,
  required String name,
}) {
  return repoList.firstWhere(
    (element) => element.repoName == name && element.repoOwner == owner,
  );
}

final gmsCore = GmsCore();

final repoWidgets = () {
  final widList = <PopupMenuItem<int>>[];

  for (var x = 0; x < repoList.length; x++) {
    final e = repoList.elementAt(x);
    widList.add(
      PopupMenuItem<int>(
        value: x,
        child: Text('${e.repoOwner}/${e.repoName}'),
      ),
    );
  }
  return widList;
}();
