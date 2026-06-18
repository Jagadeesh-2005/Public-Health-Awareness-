import 'package:flutter/material.dart';
import 'survey_form.dart';
import 'submissions_list.dart';
import 'reports_page.dart';
import 'awareness_videos_page.dart';
import 'reels_awareness_page.dart';
import 'health_guidance_page.dart';
import 'suggestions_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadLastTab();
    _pages = <Widget>[
      SurveyForm(onSurveySubmitted: (int index) => _onItemTapped(index)),
      const SubmissionsList(),
      const ReportsPage(),
      const AwarenessVideosPage(),
      const ReelsAwarenessPage(),
      const HealthGuidancePage(),
      const SuggestionsPage(),
    ];
  }

  Future<void> _loadLastTab() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedIndex = prefs.getInt('lastTab') ?? 0;
    });
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastTab', index); // save last tab
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Health Survey & Awareness")),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Survey'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Submissions'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.video_library), label: 'Videos'),
          BottomNavigationBarItem(icon: Icon(Icons.video_camera_back), label: 'Reels'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Health'),
          BottomNavigationBarItem(icon: Icon(Icons.feedback), label: 'Suggestions'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}
