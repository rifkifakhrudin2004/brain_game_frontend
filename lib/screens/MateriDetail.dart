import 'package:flutter/material.dart';
import 'package:tugas_resa/models/materi.dart';
import 'package:tugas_resa/screens/question.dart';

class MateriDetailScreen extends StatelessWidget {
  final Materi materi;

  MateriDetailScreen({required this.materi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(materi.title),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              materi.content,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            Divider(),
            SizedBox(height: 10),
            Text(
              'Pilih Level Kuis:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _navigateToQuiz(context, 'easy'),
              child: Text('Level Mudah'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _navigateToQuiz(context, 'medium'),
              child: Text('Level Menengah'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _navigateToQuiz(context, 'hard'),
              child: Text('Level Sulit'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToQuiz(BuildContext context, String level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(materiId: materi.id, level: level),
      ),
    );
  }
}
