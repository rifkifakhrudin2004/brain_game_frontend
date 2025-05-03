import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/api_services.dart';

class QuestionController with ChangeNotifier {
  List<Question> _questions = [];

  List<Question> get questions => _questions;

  Future<void> fetchQuestions(int materiId) async {
    try {
      final response = await ApiService().getQuestions(materiId);
      _questions = response.map<Question>((json) => Question.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print("Error fetching questions: $e");
    }
  }
}
