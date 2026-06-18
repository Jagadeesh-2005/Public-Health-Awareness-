import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
class SubmissionsList extends StatefulWidget {
  const SubmissionsList({super.key});

  @override
  _SubmissionsListState createState() => _SubmissionsListState();
}

class _SubmissionsListState extends State<SubmissionsList> {
  List<Map<String, dynamic>> _submissions = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> stored = prefs.getStringList('submissions') ?? <String>[];
    setState(() {
      _submissions = stored
          .map<Map<String, dynamic>>((String e) =>
              Map<String, dynamic>.from(jsonDecode(e) as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_submissions.isEmpty) {
      return const Center(child: Text("No survey submissions yet."));
    }
    return ListView.builder(
      itemCount: _submissions.length,
      itemBuilder: (BuildContext context, int index) {
        final Map<String, dynamic> item = _submissions[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListTile(
            title: Text(item['name'] as String),
            subtitle: Text(
                "Age: ${item['age']}, Issue: ${item['healthIssue'] as String? ?? 'N/A'}"),
          ),
        );
      },
    );
  }
}
