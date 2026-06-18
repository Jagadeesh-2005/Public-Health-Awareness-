import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class SurveyForm extends StatefulWidget {
  final Function(int index) onSurveySubmitted;

  const SurveyForm({super.key, required this.onSurveySubmitted});

  @override
  _SurveyFormState createState() => _SurveyFormState();
}

class _SurveyFormState extends State<SurveyForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String name = "";
  int age = 0;
  String healthIssue = "";

  Future<void> _saveSubmission() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> submissions = prefs.getStringList('submissions') ?? <String>[];
      Map<String, dynamic> submission = <String, dynamic>{
        'name': name,
        'age': age,
        'healthIssue': healthIssue,
      };
      submissions.add(jsonEncode(submission));
      await prefs.setStringList('submissions', submissions);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Survey Submitted Successfully!')));
        // Navigate to SubmissionsList (index 1)
        widget.onSurveySubmitted(1);
      }
      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(labelText: "Name"),
              onSaved: (String? value) => name = value ?? "",
              validator: (String? value) =>
                  value == null || value.isEmpty ? "Please enter name" : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Age"),
              keyboardType: TextInputType.number,
              onSaved: (String? value) => age = int.tryParse(value ?? '0') ?? 0,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return "Please enter age";
                }
                if (int.tryParse(value) == null) {
                  return "Please enter a valid number";
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Health Issue"),
              onSaved: (String? value) => healthIssue = value ?? "",
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSubmission,
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
