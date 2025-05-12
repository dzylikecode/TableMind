import 'package:flutter/material.dart';


import 'package:table_mind/screens/VSCode/view.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const VSCodePage(),
    );
  }
}