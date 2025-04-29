// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:irregular_verbs/global.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerbGameScreen extends StatefulWidget {
  final bool trainingMode;

  const VerbGameScreen({super.key, required this.trainingMode});

  @override
  _VerbGameScreenState createState() => _VerbGameScreenState();
}

class _VerbGameScreenState extends State<VerbGameScreen> with SingleTickerProviderStateMixin {
  

  int score = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  int secondsLeft = 20;
  int streak = 0;
  int bestScore = 0;

  Timer? timer;
  late Map<String, String> currentVerb;
  late String missingField;
  final TextEditingController answerController = TextEditingController();

  bool? lastAnswerCorrect;
  int lastPoints = 0;
  String feedbackMessage = '';
  double opacity = 1.0;

  @override
  void initState() {
    super.initState();
    loadBestScore();
    loadNewVerb();
  }

  Future<void> loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    bestScore = prefs.getInt('bestScore') ?? 0;
  }

  Future<void> saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (score > bestScore) {
      await prefs.setInt('bestScore', score);
    }
  }

  void loadNewVerb() {
    if (timer != null) timer!.cancel();

    final random = Random();
    currentVerb = VERBS[random.nextInt(VERBS.length)];
    final fields = ['present', 'past', 'perfect', 'spanish'];
    missingField = fields[random.nextInt(fields.length)];

    secondsLeft = widget.trainingMode ? 999 : 20;
    answerController.clear();
    lastAnswerCorrect = null;
    lastPoints = 0;
    feedbackMessage = '';

    setState(() {
      opacity = 0.0;
    });

    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          opacity = 1.0;
        });
      }
    });

    if (!widget.trainingMode) {
      timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
        setState(() {
          if (secondsLeft > 0) {
            secondsLeft--;
          } else {
            t.cancel();
            checkAnswer(timeout: true);
          }
        });
      });
    }
  }
void checkAnswer({bool timeout = false}) async {
  final userAnswer = answerController.text.trim().toLowerCase();
  final correctAnswer = currentVerb[missingField]!.toLowerCase();

  bool isCorrect = !timeout;

  if (correctAnswer.contains('/')) {
    final options = correctAnswer.split('/').map((e) => e.trim()).toList();
    isCorrect = options.contains(userAnswer);
  } else {
    isCorrect = userAnswer == correctAnswer;
  }

  setState(() {
    lastAnswerCorrect = isCorrect;
    lastPoints = isCorrect ? 3 : -1;
    score += lastPoints;

    if (isCorrect) {
      correctAnswers++;
      streak++;
      feedbackMessage = streak >= 5 ? '🔥 Streak x$streak!' : 'Perfect!';
    } else {
      wrongAnswers++;
      streak = 0;
      feedbackMessage = timeout 
        ? '⏳ Time\'s up!' 
        : '❌ Wrong! The correct answer is: $correctAnswer';
    }
  });

  await saveBestScore();
  timer?.cancel();

  Future.delayed(Duration(seconds: 2), () {
    if (mounted) {
      loadNewVerb();
    }
  });
}

  @override
  void dispose() {
    timer?.cancel();
    answerController.dispose();
    super.dispose();
  }

  Widget buildVerbField(String field) {
    Color? fieldColor;
    if (field == missingField && lastAnswerCorrect != null) {
      fieldColor = lastAnswerCorrect! ? Colors.green : Colors.red;
    }

    if (field == missingField) {
      return TextField(
        controller: answerController,
        autofocus: lastAnswerCorrect == null,
        enabled: lastAnswerCorrect == null,
        decoration: InputDecoration(
          labelText: field.toUpperCase(),
          filled: fieldColor != null,
          fillColor: fieldColor?.withOpacity(0.3),
          border: OutlineInputBorder(),
        ),
        onSubmitted: (value) {
          if (lastAnswerCorrect == null) {
            checkAnswer();
          }
        },
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          '${field.toUpperCase()}: ${currentVerb[field]}',
          style: TextStyle(fontSize: 18),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Score: $score  (Best: $bestScore)'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 500),
            opacity: opacity,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildVerbField('present'),
                    SizedBox(height: 10),
                    buildVerbField('past'),
                    SizedBox(height: 10),
                    buildVerbField('perfect'),
                    SizedBox(height: 10),
                    buildVerbField('spanish'),
                    SizedBox(height: 20),
                    Text(
                      widget.trainingMode ? '🏋️ Training' : '⏳ Time: $secondsLeft s',
                      style: TextStyle(fontSize: 20, color: Colors.amber),
                    ),
                    SizedBox(height: 20),
                    if (lastAnswerCorrect == null)
                      ElevatedButton(
                        onPressed: checkAnswer,
                        child: Text('Check answer'),
                      ),
                    if (lastAnswerCorrect != null)
                      Column(
                        children: [
                          Text(
                            feedbackMessage,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: lastAnswerCorrect! ? Colors.green : Colors.red,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            lastPoints > 0 ? '+$lastPoints points' : '$lastPoints points',
                            style: TextStyle(
                              fontSize: 20,
                              color: lastAnswerCorrect! ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 20),
                    Divider(),
                    Text('✔️ Correct: $correctAnswers    ❌ Wrong: $wrongAnswers'),
                    Text('🔥 Current streak: $streak'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
