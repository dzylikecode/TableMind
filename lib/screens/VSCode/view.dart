import 'package:flutter/material.dart';

class VSCodePage extends StatelessWidget {
  const VSCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VSCode'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('VSCode Page'),
          ],
        ),
      ),
    );
  }
}