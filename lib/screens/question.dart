import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/question.dart';
import '../services/auth_services.dart';
import 'package:tugas_resa/widget/QuestionCard_widget.dart';
import 'package:tugas_resa/screens/questionresult.dart';

class QuizScreen extends StatefulWidget {
  final int materiId;
  final String level;

  const QuizScreen({Key? key, required this.materiId, required this.level})
      : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<List<Question>> _questionsFuture;
  final AuthService _authService = AuthService();
  Map<int, String?> _userAnswers =
      {}; // Menyimpan jawaban user {question_id: answer}
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _fetchQuestions();
  }

 Future<List<Question>> _fetchQuestions() async {
  final token = await _authService.getToken();
  final response = await http.get(
    Uri.parse(
        'http://192.168.0.126:8000/api/materi/${widget.materiId}/questions/${widget.level}'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    // Tambahkan logging untuk melihat format respons
    debugPrint('RESPONSE BODY: ${response.body}');
    
    // Periksa format respons dan ekstrak data dengan benar
    final jsonResponse = jsonDecode(response.body);
    
    List<dynamic> questionsData;
    
    if (jsonResponse is List) {
      // Jika respons langsung berupa array
      questionsData = jsonResponse;
    } else if (jsonResponse is Map && jsonResponse.containsKey('data')) {
      // Jika respons berupa objek dengan kunci 'data'
      if (jsonResponse['data'] is List) {
        questionsData = jsonResponse['data'];
      } else {
        throw Exception('Format data tidak valid: data bukan array');
      }
    } else if (jsonResponse is Map && jsonResponse.containsKey('success') && jsonResponse['success'] == true) {
      // Struktur lain yang mungkin
      if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
        questionsData = jsonResponse['data'];
      } else {
        throw Exception('Format data tidak valid: ${response.body}');
      }
    } else {
      throw Exception('Format respons tidak didukung: ${response.body}');
    }
    
    return questionsData.map((item) => Question.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load questions: ${response.statusCode}');
  }
}

  Future<void> _submitQuiz() async {
    setState(() => _isSubmitting = true);

    try {
      // 1. Log Token
      final token = await _authService.getToken();
      debugPrint('🟢 TOKEN: ${token ?? "NULL"}');
      if (token == null) throw Exception('Token tidak tersedia');

      // 2. Log Request Data
      final requestBody = {
        'level': widget.level,
        'answers': _userAnswers.entries
            .map((e) => {'question_id': e.key, 'answer': e.value})
            .toList(),
      };
      debugPrint('📤 REQUEST BODY: ${jsonEncode(requestBody)}');

      // 3. Log URL
      final url ='http://192.168.0.126:8000/api/materi/${widget.materiId}/submit-quiz';
      debugPrint('🌐 URL: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
try {
      final jsonResponse = jsonDecode(response.body);
      debugPrint('📊 RESPONSE TYPE: ${jsonResponse.runtimeType}');
      
      // Pendekatan yang lebih defensif untuk mengekstrak data
      int score = 0;
      int totalQuestions = 0; 
      double percentage = 0.0;
      
      // Cek apakah respons adalah objek dengan kunci data
      if (jsonResponse is Map && jsonResponse.containsKey('data')) {
        final data = jsonResponse['data'];
        
        if (data is Map) {
          score = data['score'] ?? 0;
          totalQuestions = data['total_questions'] ?? 0;
          percentage = (data['percentage'] ?? 0.0).toDouble();
        }
      } 
      // Jika data tidak ada dalam format yang diharapkan, coba ekstrak dari root
      else if (jsonResponse is Map) {
        score = jsonResponse['score'] ?? 0;
        totalQuestions = jsonResponse['total_questions'] ?? 0;
        percentage = (jsonResponse['percentage'] ?? 0.0).toDouble();
      }
      
      // Log nilai yang diekstrak
      debugPrint('📈 EXTRACTED: score=$score, totalQuestions=$totalQuestions, percentage=$percentage');
      
      // Navigasi ke screen hasil
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(
            score: score,
            totalQuestions: totalQuestions,
            percentage: percentage,
          ),
        ),
      );
    } catch (jsonError) {
      // Error khusus untuk parsing JSON
      debugPrint('❌ JSON PARSE ERROR: $jsonError');
      throw Exception('Format respons tidak valid (JSON parsing error): ${response.body}');
    }
  } catch (e) {
    // Error handling yang sudah ada
    debugPrint('‼️ ERROR DETAIL: $e');
    debugPrintStack(stackTrace: StackTrace.current);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gagal mengirim: ${e.toString()}'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );
  } finally {
    setState(() => _isSubmitting = false);
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kuis - ${widget.level.toUpperCase()}')),
      body: FutureBuilder<List<Question>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada pertanyaan tersedia'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final question = snapshot.data![index];
                    return QuestionCard(
                      question: question,
                      selectedAnswer: _userAnswers[question.id],
                      onAnswerSelected: (answer) {
                        setState(() {
                          _userAnswers[question.id] = answer;
                        });
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _userAnswers.length == snapshot.data!.length
                      ? _submitQuiz
                      : null,
                  child: _isSubmitting
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Selesai & Lihat Hasil'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
