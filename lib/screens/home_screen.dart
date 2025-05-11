import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:tugas_resa/controllers/materi_controller.dart';
import 'package:tugas_resa/services/auth_services.dart';
import 'login.dart';
import 'MateriDetail.dart';

// Elegant color scheme
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
  static const Color matematika = Color(0xFF42A5F5);   // Blue
  static const Color biologi = Color(0xFFEC407A);      // Pink
  static const Color bahasa = Color(0xFF7E57C2);       // Purple
  static const Color other = Color(0xFF26A69A);        // Teal
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final List<String> _quizCategories = ['matematika dasar', 'biologi', 'bahasa inggris', 'other'];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();
  bool _isRefreshing = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );
    
    _animationController.forward();
    
    // Initial data fetch - SAFELY
    // Delayed to ensure the widget is properly mounted
    Future.delayed(Duration.zero, () {
      if (mounted) {
        final materiController = Provider.of<MateriController>(context, listen: false);
        if (!materiController.isLoading) {
          materiController.fetchMateri();
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildElegantAppBar(),
      body: SafeArea(
        child: Consumer<MateriController>(
          builder: (context, materiController, child) {
            // Simple loading state when first loading
            if (materiController.isLoading && !_isRefreshing) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 25),
                    Text(
                      'Loading content...',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Always wrap with RefreshIndicator for pull-to-refresh
            return RefreshIndicator(
              key: _refreshKey,
              onRefresh: _refreshMateri,
              color: AppColors.primary,
              backgroundColor: AppColors.card,
              displacement: 40,
              strokeWidth: 3,
              // Use any edge for trigger to make it more responsive
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              child: _buildContentWithScrollPhysics(materiController),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContentWithScrollPhysics(MateriController materiController) {
    // Using ListView instead of CustomScrollView for better performance and simpler structure
    return ListView(
      // This physics ensures pull-to-refresh always works
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        // Welcome Banner
        _buildElegantBanner(),
        
        // Quiz Challenge section
        _buildElegantQuizSection(),
        
        // Category Title with improved styling and refresh indicator
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 28.0, 16.0, 16.0),
          child: Row(
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
                'Kategori Mapel',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                  letterSpacing: 0.2,
                ),
              ),
              Spacer(),
              // Only show if refreshing and still mounted
              if (_isRefreshing && mounted)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                ),
            ],
          ),
        ),
        
        // Quiz Categories - THIS IS THE FIXED FUNCTION
        _buildQuizCategories(materiController),
        
        // Add some bottom padding
        SizedBox(height: 80), // Extra padding for floating action button
      ],
    );
  }

  Future<void> _refreshMateri() async {
    // Check if widget is still mounted before updating state
    if (!mounted) return;
    
    setState(() {
      _isRefreshing = true;
    });
    
    try {
      // Reference the controller outside the try block to prevent context issues
      final materiController = Provider.of<MateriController>(context, listen: false);
      await materiController.fetchMateri();
    } catch (e) {
      // Only show error if still mounted
      if (mounted) {
        // Use a post-frame callback to avoid build-time errors
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to refresh data'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    if (mounted && _refreshKey.currentState != null) {
                      _refreshKey.currentState?.show();
                    }
                  },
                ),
              ),
            );
          }
        });
      }
    } finally {
      // When done, update the state if still mounted
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  PreferredSizeWidget _buildElegantAppBar() {
    return AppBar(
      backgroundColor: AppColors.card,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'R',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Text(
            'ruangguru',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElegantBanner() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
      height: 130,
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
            AppColors.primary.withOpacity(0.9),
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
                          'Selamat Datang, Orely!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Mulai perjalanan belajarmu hari ini',
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
                        Icons.school,
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

  Widget _buildElegantQuizSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 12, 16, 8),
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                Icons.lightbulb_outline,
                size: 32,
                color: AppColors.accent,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quiz Challenge',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Test your knowledge with random questions',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textLight,
                  ),
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    final random = Random();
                    final randomCategory = _quizCategories[random.nextInt(_quizCategories.length)];
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Starting a random $randomCategory quiz!'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        action: SnackBarAction(
                          label: 'OK',
                          textColor: Colors.white,
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Random Quiz',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // FIXED FUNCTION - Ensuring proper category display
  Widget _buildQuizCategories(MateriController materiController) {
    if (materiController.materiList.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.textLight,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'No categories available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textLight,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Pull down to refresh or tap the refresh button',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLight.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                _refreshKey.currentState?.show();
              },
              icon: Icon(Icons.refresh, size: 18),
              label: Text('Refresh Now'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      );
    }
    
    final int itemCount = materiController.materiList.length;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.78,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final materi = materiController.materiList[index];
          final String categoryName = materi.title;
          
          // FIX: Improved category matching with more precise matching
          String mappedCategory = 'other';
          
          // Check for specific category keywords in the title
          if (categoryName.toLowerCase().contains('matemat')) {
            mappedCategory = 'matematika dasar';
          } else if (categoryName.toLowerCase().contains('biologi')) {
            mappedCategory = 'biologi';
          } else if (categoryName.toLowerCase().contains('bahasa') || 
                    categoryName.toLowerCase().contains('inggris')) {
            mappedCategory = 'bahasa inggris';
          }
          
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MateriDetailScreen(materi: materi),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _getCategoryColor(mappedCategory).withOpacity(0.15),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: _getCategoryColor(mappedCategory).withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(mappedCategory).withOpacity(0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getCategoryColor(mappedCategory).withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getCategoryIcon(mappedCategory),
                      color: _getCategoryColor(mappedCategory),
                      size: 36,
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(mappedCategory).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      categoryName,
                      style: TextStyle(
                        color: _getCategoryColor(mappedCategory),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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

  // Updated with more precise category matching
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'matematika dasar':
        return AppColors.matematika;
      case 'biologi':
        return AppColors.biologi;
      case 'bahasa inggris':
        return AppColors.bahasa;
      default:
        return AppColors.other; // Use the dedicated "other" color instead of primary
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'matematika dasar':
        return Icons.calculate;
      case 'biologi':
        return Icons.science;
      case 'bahasa inggris':
        return Icons.menu_book;
      default:
        return Icons.quiz;
    }
  }
}