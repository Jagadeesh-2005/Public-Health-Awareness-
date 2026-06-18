import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const HealthSurveyApp());
}

class HealthSurveyApp extends StatelessWidget {
  const HealthSurveyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Takkellapadu Health Survey',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomePage(),
    );
  }
}
