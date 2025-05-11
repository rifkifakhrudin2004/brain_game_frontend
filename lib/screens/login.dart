import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tugas_resa/services/auth_services.dart';
import 'home_screen.dart';
import 'register.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _transformAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _transformAnimation = Tween<double>(begin: -0.2, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    print('Mulai proses login...');
    try {
      final response = await http.post(
        Uri.parse('http://192.168.141.249:8000/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final AuthService authService = AuthService();
        await authService.saveToken(responseData['token']);
        
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 800),
            pageBuilder: (_, __, ___) => HomeScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        _showError(errorData['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('Error during login: $e');
      _showError('An error occurred. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade800,
              Colors.indigo.shade900,
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _transformAnimation.value * size.height),
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: child,
              ),
            );
          },
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'logo',
                      child: Icon(
                        Icons.account_circle,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 40),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          children: [
                            TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: 20),
                            TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // Forgot password functionality
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 5,
                                ),
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: Duration(milliseconds: 500),
                                pageBuilder: (_, __, ___) => RegisterScreen(),
                                transitionsBuilder: (_, animation, __, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: Offset(1, 0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          child: Text(
                            'Register',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}