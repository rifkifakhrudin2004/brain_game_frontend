class Question {
  final int id;
  final int materiId;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;
  final String level;

  Question({
    required this.id,
    required this.materiId,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    required this.level,
  });

  // Tambahkan method toJson()
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'materi_id': materiId,
      'question': question,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'option_d': optionD,
      'correct_answer': correctAnswer,
      'level': level,
    };
  }

  // Method fromJson tetap ada
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      materiId: json['materi_id'],
      question: json['question'],
      optionA: json['option_a'],
      optionB: json['option_b'],
      optionC: json['option_c'],
      optionD: json['option_d'],
      correctAnswer: json['correct_answer'],
      level: json['level'],
    );
  }
}