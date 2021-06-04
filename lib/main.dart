import 'package:flutter/material.dart';

import 'widgets/MyMapArea.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Police App';
    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: Text(appTitle),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            MyMapArea(),
          ],
        ),
      ),
    );
  }
}
