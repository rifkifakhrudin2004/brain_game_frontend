import 'package:flutter/material.dart';
import 'package:tugas_resa/models/question.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final String? selectedAnswer;
  final Function(String) onAnswerSelected;

  const QuestionCard({
    required this.question,
    this.selectedAnswer,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question.question, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ..._buildOptions(),
          ],
        ),
      ),
    );
  }

 List<Widget> _buildOptions() {
  final options = {
    'A': question.optionA,
    'B': question.optionB,
    'C': question.optionC,
    'D': question.optionD,
  };

  return options.entries.map((entry) {
    return RadioListTile<String>(
      title: Text('${entry.key}. ${entry.value}'),
      value: entry.key,
      groupValue: selectedAnswer,
      onChanged: (value) => onAnswerSelected(value!),
    );
  }).toList();
}
}