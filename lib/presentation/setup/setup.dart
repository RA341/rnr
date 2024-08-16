// don't really need a setup page for 1 permission
// if in the future app needs more permissions add it back



// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:rnr/services/permission_manager.dart';
//
// class SetupPage extends ConsumerWidget {
//   const SetupPage({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final buttonState = ref.read(installAppsRequestProvider);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Padding(
//           padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
//           child: Text(
//             'Lets get you setup',
//             style: TextStyle(fontSize: 40),
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.only(top: 20),
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(15),
//               child: Padding(
//                 padding: const EdgeInsets.all(15),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const SizedBox(
//                       width: 250,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Install Apps',
//                             style: TextStyle(fontSize: 20),
//                           ),
//                           Text(
//                             'Allow to install the downloaded apps',
//                             style: TextStyle(
//                               fontSize: 13,
//                               overflow: TextOverflow.visible,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     if (buttonState == 0)
//                       ElevatedButton(
//                         onPressed: () async {
//                           requestInstallPermissions(ref);
//                         },
//                         child: const Text('Grant'),
//                       )
//                     else
//                       buttonState == -1
//                           ? const CircularProgressIndicator()
//                           : const Icon(Icons.check),
//                   ],
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(20),
//         child: ElevatedButton(
//           onPressed: () {},
//           child: const Text(
//             'Next',
//             style: TextStyle(fontSize: 20),
//           ),
//         ),
//       ),
//     );
//   }
// }
