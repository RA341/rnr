import 'package:flutter/material.dart';
import 'package:rnr/utils/services.dart';
import 'package:rnr/utils/utils.dart';

class GithubPatInput extends StatefulWidget {
  const GithubPatInput({super.key});

  @override
  State<GithubPatInput> createState() => _GithubPatInputState();
}

class _GithubPatInputState extends State<GithubPatInput> {
  late TextEditingController githubTokenController;

  @override
  void initState() {
    super.initState();
    githubTokenController = TextEditingController();
  }

  @override
  void dispose() {
    githubTokenController.dispose();
    super.dispose();
  }

  bool reqState = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Update Github personal access token'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
          child: SizedBox(
            width: double.maxFinite,
            child: TextField(
              controller: githubTokenController,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: updateToken,
              child: reqState
                  ? const CircularProgressIndicator()
                  : const Text('Update'),
            ),
            ElevatedButton(
              onPressed: () async {
                await settings.clearGithubToken();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Github token cleared!, APP RESTART IS REQUIRED'),
                  ),
                );
              },
              child: const Text('Clear token'),
            ),
          ],
        ),
      ],
    );
  }

  void updateToken() async {
    updateState(true);
    final token = githubTokenController.text;
    if (await testToken(token)) {
      try {
        await settings.updateGithubToken(token);
        githubTokenController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Github token updated!, APP RESTART IS REQUIRED'),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        await showAlert(
          context,
          'Error updating Github token!, try again',
          'Something went wrong try again, if the issue persists open a issue on github'
              '\n$e',
        );
        logger.e('Failed to write github token', error: e);
      }
      updateState(false);
      return;
    }

    updateState(false);
    if (!context.mounted) return;
    await showAlert(
      context,
      'Error verifying Github token!',
      'The github token was incorrect, verify it and try again',
    );
  }

  void updateState(bool newState) {
    setState(() {
      reqState = newState;
    });
  }
}

Future<void> showAlert(
    BuildContext context, String headerText, String moreInfoText) async {
  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(headerText),
        content: Text(
          moreInfoText,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
