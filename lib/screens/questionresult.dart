import 'package:flutter/material.dart';

// HALO
// Using the same elegant color scheme from the first code
class AppColors {
  static const Color primary = Color(0xFF3F51B5);      // Indigo
  static const Color secondary = Color(0xFF5C6BC0);    // Indigo light
  static const Color accent = Color(0xFFFF4081);       // Pink accent
  static const Color background = Color(0xFFF8F9FE);   // Light background
  static const Color card = Color(0xFFFFFFFF);         // White card
  static const Color text = Color(0xFF263238);         // Dark text
  static const Color textLight = Color(0xFF78909C);    // Light text
  static const Color divider = Color(0xFFEEEEEE);      // Light divider
  
  // Result colors
  static const Color success = Color(0xFF26A69A);      // Green/Teal
  static const Color warning = Color(0xFFFFA726);      // Orange
  static const Color error = Color(0xFFEF5350);        // Red
}

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final double percentage;

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildElegantAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _buildConfetti(),
                _buildScoreProgressIndicator(),
                const SizedBox(height: 30),
                _buildScoreDetails(),
                const SizedBox(height: 30),
                _buildFeedbackCard(),
                const SizedBox(height: 40),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildElegantAppBar() {
    return AppBar(
      backgroundColor: AppColors.card,
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.school,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Hasil Kuis',
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildConfetti() {
    // Empty space instead of confetti
    return SizedBox(height: 20);
  }

  Widget _buildScoreProgressIndicator() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Skor',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 30),
          Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.divider,
                ),
              ),
              // Progress circle
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 12,
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation<Color>(_getPercentageColor(percentage)),
                ),
              ),
              // Center content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score/$totalQuestions',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getPercentageColor(percentage).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getPercentageColor(percentage),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDetails() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            title: 'Benar',
            value: '$score',
            icon: Icons.check_circle_outline,
            color: AppColors.success,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(
            title: 'Salah',
            value: '${totalQuestions - score}',
            icon: Icons.highlight_off,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getPercentageColor(percentage).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getPercentageColor(percentage).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getPercentageIcon(percentage),
              color: _getPercentageColor(percentage),
              size: 32,
            ),
          ),
          SizedBox(height: 16),
          Text(
            _getPerformanceTitle(percentage),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _getPercentageColor(percentage),
            ),
          ),
          SizedBox(height: 12),
          Text(
            _getPerformanceMessage(percentage),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.menu_book, size: 18),
          label: Text('Kembali ke Materi'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
        SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            // Could be used to retry the quiz
            Navigator.pop(context);
          },
          icon: Icon(Icons.replay, size: 18),
          label: Text('Coba Lagi'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary),
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 50) return AppColors.warning;
    return AppColors.error;
  }

  IconData _getPercentageIcon(double percentage) {
    if (percentage >= 80) return Icons.emoji_events;
    if (percentage >= 50) return Icons.thumb_up;
    return Icons.psychology;
  }

  String _getPerformanceTitle(double percentage) {
    if (percentage >= 80) return 'Luar Biasa!';
    if (percentage >= 50) return 'Cukup Baik';
    return 'Tetap Semangat';
  }

  String _getPerformanceMessage(double percentage) {
    if (percentage >= 80) {
      return 'Penguasaan materi Anda sangat baik! Teruslah mempertahankan pemahaman ini.';
    } else if (percentage >= 50) {
      return 'Pemahaman Anda sudah cukup baik. Pelajari kembali beberapa bagian untuk hasil yang lebih baik.';
    } else {
      return 'Jangan menyerah! Cobalah pelajari kembali materi dan ulangi kuis untuk meningkatkan pemahaman Anda.';
    }
  }
}