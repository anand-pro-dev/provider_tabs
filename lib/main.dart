import 'package:flutter/material.dart';
import 'package:web_provider_api/app/views/bottom.dart';
import 'package:provider/provider.dart';
import 'app/controllers/character_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ChangeNotifierProvider(create: (_) => DashBoardProvider()),
        ChangeNotifierProvider(create: (_) => CharacterController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Character App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // home: const MyHomePage(),
        home: const MyStatefulWidget(),
      ),
    );
  }
}
