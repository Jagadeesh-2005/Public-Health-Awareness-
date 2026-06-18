import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  int _totalSubmissions = 0;
  Map<String, int> _healthIssueCounts = <String, int>{};
  Map<String, int> _ageGroupCounts = <String, int>{};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedSubmissions = prefs.getStringList('submissions') ?? <String>[];

    List<Map<String, dynamic>> submissions = storedSubmissions
        .map<Map<String, dynamic>>((String e) =>
            Map<String, dynamic>.from(jsonDecode(e) as Map<String, dynamic>))
        .toList();

    _totalSubmissions = submissions.length;
    _healthIssueCounts = _calculateHealthIssueCounts(submissions);
    _ageGroupCounts = _calculateAgeGroupCounts(submissions);

    setState(() {
      _isLoading = false;
    });
  }

  Map<String, int> _calculateHealthIssueCounts(
      List<Map<String, dynamic>> submissions) {
    Map<String, int> counts = <String, int>{};
    for (final Map<String, dynamic> submission in submissions) {
      String issue = (submission['healthIssue'] as String?)?.trim() ?? 'Unknown';
      if (issue.isEmpty) {
        issue = 'Unknown';
      }
      counts[issue] = (counts[issue] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> _calculateAgeGroupCounts(
      List<Map<String, dynamic>> submissions) {
    Map<String, int> counts = <String, int>{
      '0-18': 0,
      '19-45': 0,
      '46+': 0,
      'Unknown': 0,
    };
    for (final Map<String, dynamic> submission in submissions) {
      int age = submission['age'] as int? ?? 0;
      if (age >= 0 && age <= 18) {
        counts['0-18'] = (counts['0-18'] ?? 0) + 1;
      } else if (age >= 19 && age <= 45) {
        counts['19-45'] = (counts['19-45'] ?? 0) + 1;
      } else if (age >= 46) {
        counts['46+'] = (counts['46+'] ?? 0) + 1;
      } else {
        counts['Unknown'] = (counts['Unknown'] ?? 0) + 1;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_totalSubmissions == 0) {
      return const Center(
          child: Text("No survey data available for reports yet."));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    "Total Submissions:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$_totalSubmissions',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700]),
                  ),
                ],
              ),
            ),
          ),
          const Text(
            "Health Issues Breakdown:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _healthIssueCounts.isEmpty
              ? const Text("No specific health issues recorded.")
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _healthIssueCounts.length,
                  itemBuilder: (BuildContext context, int index) {
                    String issue = _healthIssueCounts.keys.elementAt(index);
                    int count = _healthIssueCounts[issue]!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(issue, style: const TextStyle(fontSize: 16)),
                          Text('$count',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  },
                ),
          const Divider(height: 30),
          const Text(
            "Age Group Distribution:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _ageGroupCounts.isEmpty
              ? const Text("No age distribution data available.")
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _ageGroupCounts.length,
                  itemBuilder: (BuildContext context, int index) {
                    String ageGroup = _ageGroupCounts.keys.elementAt(index);
                    int count = _ageGroupCounts[ageGroup]!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(ageGroup, style: const TextStyle(fontSize: 16)),
                          Text('$count',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
