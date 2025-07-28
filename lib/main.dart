import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(BibleQuizApp());
}

class BibleQuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bible Quiz',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class Question {
  final String question;
  final List<String> options;
  final int correctIndex;

  Question({required this.question, required this.options, required this.correctIndex});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      options: List<String>.from(json['options']),
      correctIndex: json['correct_index'],
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bible Quiz')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Start Quiz'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuizScreen()),
                );
              },
            ),
            ElevatedButton(
              child: Text('View Scores'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScoreScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> questions = [];
  int currentIndex = 0;
  int score = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    final String jsonString = await rootBundle.loadString('assets/questions.json');
    final List<dynamic> data = json.decode(jsonString);
    setState(() {
      questions = data.map((e) => Question.fromJson(e)).toList();
      isLoading = false;
    });
  }

  void answerQuestion(int selectedIndex) {
    if (selectedIndex == questions[currentIndex].correctIndex) {
      score++;
    }

    if (currentIndex < questions.length - 1) {
      setState(() => currentIndex++);
    } else {
      saveScore();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ResultScreen(score: score, total: questions.length)),
      );
    }
  }

  Future<void> saveScore() async {
    final prefs = await SharedPreferences.getInstance();
    final scores = prefs.getStringList('scores') ?? [];
    scores.add('$score/${questions.length}');
    await prefs.setStringList('scores', scores);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Quiz')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Quiz')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Question ${currentIndex + 1}/${questions.length}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text(question.question, style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ...List.generate(question.options.length, (i) {
              return ElevatedButton(
                onPressed: () => answerQuestion(i),
                child: Text(question.options[i]),
              );
            })
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;

  ResultScreen({required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Results')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You scored $score out of $total!', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Play Again'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => QuizScreen()),
                );
              },
            ),
            ElevatedButton(
              child: Text('Go Home'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ScoreScreen extends StatelessWidget {
  Future<List<String>> getScores() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('scores') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scores')),
      body: FutureBuilder<List<String>>(
        future: getScores(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final scores = snapshot.data!;

          if (scores.isEmpty) return Center(child: Text('No scores yet.'));

          return ListView.builder(
            itemCount: scores.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(Icons.star),
                title: Text('Attempt ${index + 1}: ${scores[index]}'),
              );
            },
          );
        },
      ),
    );
  }
}
