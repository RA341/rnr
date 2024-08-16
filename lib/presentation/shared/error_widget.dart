import 'package:flutter/material.dart';

class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    required this.headerText,
    required this.errText,
    super.key,
  });

  final String headerText;
  final String errText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.error),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      headerText,
                      overflow: TextOverflow.visible,
                      maxLines: 10,
                      softWrap: true,
                      style: const TextStyle(fontSize: 17),
                    ),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 15)),
              Text(errText),
            ],
          ),
        ),
      ),
    );
  }
}
