import 'package:flutter/material.dart';
import 'package:rnr/utils/services.dart';

class EnableGmsCore extends StatefulWidget {
  const EnableGmsCore({super.key});

  @override
  State<EnableGmsCore> createState() => _EnableGmsCoreState();
}

class _EnableGmsCoreState extends State<EnableGmsCore> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text('Enable GmsCore'),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Switch(
                value: settings.isGmsEnabled(),
                onChanged: (value) async {
                  await settings.toggleGmsCore(value: value);
                  setState(() {});
                },
              ),
            )
          ],
        ),
        const Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Icon(Icons.info),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              child: SizedBox(
                width: 300,
                child: Text(
                  'Gms core is only needed if you are using youtube or google apps in general, it spoofs google services for revanced google apps',
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
