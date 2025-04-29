import 'package:flutter/material.dart';
import 'package:irregular_verbs/home_screen.dart';

void main() {
  runApp(IrregularVerbsGame());
}

class IrregularVerbsGame extends StatelessWidget {
  const IrregularVerbsGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Irregular Verbs Game',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
