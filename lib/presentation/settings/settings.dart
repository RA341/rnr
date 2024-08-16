import 'package:flutter/material.dart';
import 'package:rnr/presentation/settings/github_pat_input.dart';
import 'package:rnr/presentation/settings/gms_toggle.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Text('Settings', style: TextStyle(fontSize: 25),),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: GithubPatInput(),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: EnableGmsCore(),
            ),
          ],
        ),
      ),
    );
  }
}
