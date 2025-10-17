import 'package:flutter/material.dart';
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

  Question({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
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
  late List<Question> questions;
  int currentIndex = 0;
  int score = 0;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  void loadQuestions() {
    questions = [
      Question(
        question: "Who built the ark?",
        options: ["Moses", "Noah", "Abraham", "David"],
        correctIndex: 1,
      ),
      Question(
        question: "Where was Jesus born?",
        options: ["Nazareth", "Bethlehem", "Jerusalem", "Capernaum"],
        correctIndex: 1,
      ),
      Question(
        question: "How many disciples did Jesus have?",
        options: ["10", "11", "12", "13"],
        correctIndex: 2,
      ),
      Question(
        question: "What was the first miracle Jesus performed?",
        options: [
          "Healing the blind man",
          "Feeding 5,000 people",
          "Turning water into wine",
          "Walking on water"
        ],
        correctIndex: 2,
      ),
      Question(
        question: "Who was swallowed by a great fish?",
        options: ["Jonah", "Elijah", "Job", "Paul"],
        correctIndex: 0,
      ),
      Question(
        question: "Who led the Israelites out of Egypt?",
        options: ["Abraham", "Moses", "Joshua", "Joseph"],
        correctIndex: 1,
      ),
      Question(
        question: "What did David use to defeat Goliath?",
        options: ["A sword", "A spear", "A sling and a stone", "A bow"],
        correctIndex: 2,
      ),
      Question(
        question: "Who denied Jesus three times?",
        options: ["Peter", "John", "James", "Judas"],
        correctIndex: 0,
      ),
      Question(
        question: "In what city did Jesus perform His first miracle?",
        options: ["Bethlehem", "Nazareth", "Cana", "Jericho"],
        correctIndex: 2,
      ),
      Question(
        question: "What is the last book of the Bible?",
        options: ["Genesis", "Psalms", "Matthew", "Revelation"],
        correctIndex: 3,
      ),
      Question(
        question: "Who was the first man created?",
        options: ["Abel", "Adam", "Seth", "Cain"],
        correctIndex: 1,
      ),
      Question(
        question: "Who was thrown into the lions’ den?",
        options: ["Daniel", "Elijah", "Moses", "Paul"],
        correctIndex: 0,
      ),
      Question(
        question: "Who betrayed Jesus with a kiss?",
        options: ["Peter", "Thomas", "Judas", "Matthew"],
        correctIndex: 2,
      ),
      Question(
        question: "Who was the mother of Samuel?",
        options: ["Hannah", "Rachel", "Mary", "Sarah"],
        correctIndex: 0,
      ),
      Question(
        question: "What did God create on the first day?",
        options: ["Man", "Animals", "Light", "Plants"],
        correctIndex: 2,
      ),
      Question(
        question: "Who was the strongest man in the Bible?",
        options: ["David", "Moses", "Samson", "Elijah"],
        correctIndex: 2,
      ),
      Question(
        question: "How many days did God take to create the world?",
        options: ["5", "6", "7", "8"],
        correctIndex: 1,
      ),
      Question(
        question: "What did Jesus feed the 5,000 with?",
        options: [
          "5 loaves and 2 fish",
          "2 loaves and 5 fish",
          "10 loaves and 1 fish",
          "7 loaves and 3 fish"
        ],
        correctIndex: 0,
      ),
      Question(
        question: "Who wrote most of the Psalms?",
        options: ["Moses", "David", "Solomon", "Isaiah"],
        correctIndex: 1,
      ),
      Question(
        question: "Which disciple walked on water with Jesus?",
        options: ["John", "Peter", "James", "Andrew"],
        correctIndex: 1,
      ),
    ];
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
        MaterialPageRoute(
          builder: (context) => ResultScreen(score: score, total: questions.length),
        ),
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
    final question = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Question ${currentIndex + 1}/${questions.length}')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question.question, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
