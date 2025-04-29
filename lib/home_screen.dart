// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:irregular_verbs/verb_game_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  int bestScore = 0;

  @override
  void initState() {
    super.initState();
    loadBestScore();
  }

  Future<void> loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bestScore = prefs.getInt('bestScore') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Irregular Verbs',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.amber),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Image.asset("assets/logo.png"),
              SizedBox(height: 50),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: StadiumBorder(),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => VerbGameScreen(trainingMode: false)),
                  );
                },
                child: Text('Start Game', style: TextStyle(fontSize: 20)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: StadiumBorder(),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => VerbGameScreen(trainingMode: true)),
                  );
                },
                child: Text('Training Mode', style: TextStyle(fontSize: 18)),
              ),
              SizedBox(height: 40),
              Text(
                '🏆 Best Score: $bestScore',
                style: TextStyle(fontSize: 18, color: Colors.greenAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
