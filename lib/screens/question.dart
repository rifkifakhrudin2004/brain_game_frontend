import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/question.dart';
import '../services/auth_services.dart';
import 'package:tugas_resa/widget/QuestionCard_widget.dart';
import 'package:tugas_resa/screens/questionresult.dart';

// HALO
// Using the same elegant color scheme as HomeScreen and MateriDetailScreen
class AppColors {
  static const Color primary = Color(0xFF3F51B5);      // Indigo
  static const Color secondary = Color(0xFF5C6BC0);    // Indigo light
  static const Color accent = Color(0xFFFF4081);       // Pink accent
  static const Color background = Color(0xFFF8F9FE);   // Light background
  static const Color card = Color(0xFFFFFFFF);         // White card
  static const Color text = Color(0xFF263238);         // Dark text
  static const Color textLight = Color(0xFF78909C);    // Light text
  static const Color divider = Color(0xFFEEEEEE);      // Light divider
  
  // Subject colors
  static const Color science = Color(0xFF42A5F5);      // Blue
  static const Color history = Color(0xFFEC407A);      // Pink
  static const Color math = Color(0xFF7E57C2);         // Purple
  static const Color english = Color(0xFF26A69A);      // Teal
  
  // Quiz level colors
  static const Color easy = Color(0xFF4CAF50);         // Green
  static const Color medium = Color(0xFFFFA726);       // Orange
  static const Color hard = Color(0xFFF44336);         // Red
}

class QuizScreen extends StatefulWidget {
  final int materiId;
  final String level;

  const QuizScreen({Key? key, required this.materiId, required this.level})
      : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  late Future<List<Question>> _questionsFuture;
  final AuthService _authService = AuthService();
  Map<int, String?> _userAnswers = {}; // Menyimpan jawaban user {question_id: answer}
  bool _isSubmitting = false;
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _fetchQuestions();
    
    // Configure animation for progress indicator
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<List<Question>> _fetchQuestions() async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse(
          'http://192.168.141.249:8000/api/materi/${widget.materiId}/questions/${widget.level}'),
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
      final url ='http://192.168.141.249:8000/api/materi/${widget.materiId}/submit-quiz';
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(16),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
  
  Color _getLevelColor() {
    switch(widget.level.toLowerCase()) {
      case 'easy': return AppColors.science;
      case 'medium': return AppColors.math; 
      case 'hard': return AppColors.history;
      default: return AppColors.primary;
    }
  }
  
  String _getLevelEmoji() {
    switch(widget.level.toLowerCase()) {
      case 'easy': return '😊';
      case 'medium': return '😐'; 
      case 'hard': return '😰';
      default: return '🎓';
    }
  }
  
  IconData _getLevelIcon() {
    switch(widget.level.toLowerCase()) {
      case 'easy': return Icons.sentiment_satisfied_alt;
      case 'medium': return Icons.sentiment_neutral; 
      case 'hard': return Icons.sentiment_very_dissatisfied;
      default: return Icons.quiz;
    }
  }
  
  
  PreferredSizeWidget _buildElegantAppBar(BuildContext context, Color levelColor) {
    return AppBar(
      backgroundColor: AppColors.card,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          decoration: BoxDecoration(
            color: levelColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.all(8),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: levelColor,
            size: 16,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Kuis - ${widget.level.toUpperCase()}',
        style: TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
    );
  }
  
  Widget _buildQuizHeader(Color levelColor) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: levelColor.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            levelColor,
            levelColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                _getLevelIcon(),
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level ${widget.level.toUpperCase()} ${_getLevelEmoji()}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                FutureBuilder<List<Question>>(
                  future: _questionsFuture,
                  builder: (context, snapshot) {
                    int total = snapshot.hasData ? snapshot.data!.length : 0;
                    return Text(
                      'Jawab semua $total pertanyaan di bawah ini',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuizContent() {
    return FutureBuilder<List<Question>>(
      future: _questionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(_getLevelColor()),
                  strokeWidth: 3,
                ),
                SizedBox(height: 16),
                Text(
                  'Memuat pertanyaan...',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _questionsFuture = _fetchQuestions();
                    });
                  },
                  icon: Icon(Icons.refresh),
                  label: Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.quiz,
                  color: AppColors.textLight,
                  size: 60,
                ),
                SizedBox(height: 16),
                Text(
                  'Tidak ada pertanyaan tersedia',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        // Update progress animation
        _animationController.value = _userAnswers.length / snapshot.data!.length;

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Progress:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textLight,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _userAnswers.length / snapshot.data!.length,
                        backgroundColor: AppColors.divider,
                        valueColor: AlwaysStoppedAnimation<Color>(_getLevelColor()),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${_userAnswers.length}/${snapshot.data!.length}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getLevelColor(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 100), // Extra bottom padding for the submit button
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final question = snapshot.data![index];
                  // Here we're assuming QuestionCard is a custom widget
                  // You may need to update QuestionCard widget as well to match the style
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: QuestionCard(
                      question: question,
                      selectedAnswer: _userAnswers[question.id],
                      onAnswerSelected: (answer) {
                        setState(() {
                          _userAnswers[question.id] = answer;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = _getLevelColor();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildElegantAppBar(context, levelColor),
      body: SafeArea(
        child: Column(
          children: [
            _buildQuizHeader(levelColor),
            Expanded(
              child: _buildQuizContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildSubmitButton(),
    );
  }
  
  Widget _buildSubmitButton() {
    return Container(
      color: AppColors.card,
      padding: EdgeInsets.all(16),
      child: FutureBuilder<List<Question>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          bool isComplete = snapshot.hasData && 
                          _userAnswers.length == snapshot.data!.length &&
                          snapshot.data!.isNotEmpty;
          
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: isComplete ? [
                BoxShadow(
                  color: _getLevelColor().withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ] : [],
            ),
            child: ElevatedButton(
              onPressed: isComplete && !_isSubmitting ? _submitQuiz : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _getLevelColor(),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                disabledBackgroundColor: AppColors.divider,
                disabledForegroundColor: AppColors.textLight,
              ),
              child: _isSubmitting
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Selesai & Lihat Hasil',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}