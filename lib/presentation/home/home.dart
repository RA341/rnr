import 'package:flutter/material.dart';
import 'package:rnr/presentation/home/gmscore_widget.dart';
import 'package:rnr/presentation/home/installed_apps.dart';
import 'package:rnr/utils/services.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (settings.isGmsEnabled()) const GmsCoreWidget(),
          const InstalledApps(),
        ],
      ),
    );
  }
}
