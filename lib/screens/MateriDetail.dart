import 'package:flutter/material.dart';
import 'package:tugas_resa/models/materi.dart';
import 'package:tugas_resa/screens/question.dart';

// Using the same elegant color scheme from HomeScreen
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
}

class MateriDetailScreen extends StatelessWidget {
  final Materi materi;

  MateriDetailScreen({required this.materi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildElegantAppBar(context),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Material Header Banner
            _buildMaterialHeaderBanner(),
            
            // Content Section
            _buildContentSection(),
            
            // Quiz Level Section
            _buildQuizLevelSection(context),
            
            // Bottom padding
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildElegantAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.card,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.all(8),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primary,
            size: 16,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        materi.title,
        style: TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildMaterialHeaderBanner() {
    return Container(
      margin: EdgeInsets.all(16),
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.card,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 16, 
            offset: Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Decorative elements
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -10,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, 
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          materi.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Pelajari materi ini dengan seksama!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.menu_book,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Materi Pembelajaran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            materi.content,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.text,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizLevelSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.science,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Pilih Level Kuis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildQuizLevelButton(
            context,
            'Level Mudah',
            'easy',
            AppColors.science,
            Icons.sentiment_satisfied_alt,
          ),
          SizedBox(height: 16),
          _buildQuizLevelButton(
            context,
            'Level Menengah',
            'medium',
            AppColors.math,
            Icons.sentiment_neutral,
          ),
          SizedBox(height: 16),
          _buildQuizLevelButton(
            context,
            'Level Sulit',
            'hard',
            AppColors.history,
            Icons.sentiment_very_dissatisfied,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizLevelButton(
    BuildContext context,
    String label,
    String level,
    Color color,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToQuiz(context, level),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                SizedBox(width: 20),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 24,
                      color: color,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: color,
                ),
                SizedBox(width: 20),
              ],
            ),
          ),
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