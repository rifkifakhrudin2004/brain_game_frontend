import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/materi_controller.dart';
import 'controllers/question_controller.dart';
import 'screens/home_screen.dart';
import 'screens/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MateriController()),
        ChangeNotifierProvider(create: (_) => QuestionController()),
      ],
      child: MaterialApp(
        title: 'Materi & Soal App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoginScreen(), // Set initial screen as Login
        routes: {
          '/home': (context) => HomeScreen(),
          // Add other routes here if needed
        },
      ),
    );
  }
}
