import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rnr/presentation/browse/browse.dart';
import 'package:rnr/presentation/home/home.dart';
import 'package:rnr/presentation/settings/settings.dart';

const pages = [HomePage(), BrowsePage(), SettingsPage()];

final bottomNavProvider = StateProvider<int>((ref) {
  return 0;
});

