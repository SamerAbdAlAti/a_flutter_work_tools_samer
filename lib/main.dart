import 'package:flutter/material.dart';

import 'featurs/create_new_flutter_project.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Create Flutter Project Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CreateFlutterProjectScreen(),
    );
  }
}
