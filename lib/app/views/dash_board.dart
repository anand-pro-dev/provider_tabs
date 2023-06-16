// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../controllers/character_controller.dart';

// class DashBoardPage extends StatelessWidget {
//   const DashBoardPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final controller = Provider.of<DashBoardProvider>(context);
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF2c3e50),
//         elevation: 0,
//         title: Text(controller.isLoading ? 'Loading...' : 'Characters'),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           controller.isLoading
//               ? const Center(
//                   child: CircularProgressIndicator(
//                     color: Color(0xFF2c3e50),
//                   ),
//                 )
//               : Expanded(
//                   child: ListView.builder(
//                       // key: PageStorageKey<String>('son'),
//                       itemCount: controller.characters.length,
//                       physics: const BouncingScrollPhysics(),
//                       itemBuilder: (context, index) {
//                         final character = controller.characters[index];
//                         return Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 10),
//                             child: Text(character.remark.toString()));
//                       }),
//                 ),
//         ],
//       ),
//     );
//   }
// }
