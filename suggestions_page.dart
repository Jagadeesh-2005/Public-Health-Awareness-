import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
class SuggestionsPage extends StatefulWidget {
  const SuggestionsPage({super.key});

  @override
  _SuggestionsPageState createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  final TextEditingController _suggestionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _suggestions = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  @override
  void dispose() {
    _suggestionController.dispose();
    super.dispose();
  }

  Future<void> _loadSuggestions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> stored = prefs.getStringList('suggestions') ?? <String>[];
    setState(() {
      _suggestions = stored
          .map<Map<String, dynamic>>((String e) {
            final Map<String, dynamic> decoded = jsonDecode(e) as Map<String, dynamic>;
            return <String, dynamic>{
              'text': decoded['text'] as String,
              'timestamp': decoded['timestamp'] as String,
              'isActioned': decoded['isActioned'] as bool? ?? false,
              'actionNote': decoded['actionNote'] as String? ?? '',
            };
          })
          .toList();
      _suggestions.sort((Map<String, dynamic> a, Map<String, dynamic> b) =>
          (b['timestamp'] as String).compareTo(a['timestamp'] as String));
    });
  }

  Future<void> _saveSuggestion() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> currentSuggestions =
          prefs.getStringList('suggestions') ?? <String>[];

      Map<String, dynamic> newSuggestion = <String, dynamic>{
        'text': _suggestionController.text,
        'timestamp': DateTime.now().toIso8601String(),
        'isActioned': false,
        'actionNote': '',
      };

      currentSuggestions.add(jsonEncode(newSuggestion));
      await prefs.setStringList('suggestions', currentSuggestions);

      _suggestionController.clear();
      await _loadSuggestions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Suggestion Submitted!')),
        );
      }
    }
  }

  Future<void> _updateSuggestionStatus(
      int index, bool isActioned, String actionNote) async {
    setState(() {
      _suggestions[index]['isActioned'] = isActioned;
      _suggestions[index]['actionNote'] = actionNote;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> updatedStoredSuggestions = _suggestions.map<String>((Map<String, dynamic> e) => jsonEncode(e)).toList();
    await prefs.setStringList('suggestions', updatedStoredSuggestions);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Suggestion ${isActioned ? 'actioned' : 'updated'}!')),
      );
    }
  }

  Future<void> _showActionDialog(int index) async {
    Map<String, dynamic> currentSuggestion = _suggestions[index];
    bool isActioned = currentSuggestion['isActioned'] as bool;
    String actionNote = currentSuggestion['actionNote'] as String;

    TextEditingController actionNoteController = TextEditingController(text: actionNote);

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text("Take Action on Suggestion"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Checkbox(
                          value: isActioned,
                          onChanged: (bool? newValue) {
                            if (newValue != null) {
                              setState(() {
                                isActioned = newValue;
                              });
                            }
                          },
                        ),
                        const Text("Mark as Actioned"),
                      ],
                    ),
                    TextField(
                      controller: actionNoteController,
                      decoration: const InputDecoration(
                        labelText: "Action Note (Optional)",
                        hintText: "e.g., 'Forwarded to health committee'",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _updateSuggestionStatus(index, isActioned, actionNoteController.text);
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text("Save Action"),
                ),
              ],
            );
          },
        );
      },
    );
    actionNoteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _suggestionController,
              decoration: const InputDecoration(
                labelText: "Your Suggestion",
                hintText: "Enter your feedback or suggestion here...",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return "Suggestion cannot be empty";
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _saveSuggestion,
            icon: const Icon(Icons.send),
            label: const Text("Submit Suggestion"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Recent Suggestions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          Expanded(
            child: _suggestions.isEmpty
                ? const Center(child: Text("No suggestions yet. Be the first to add one!"))
                : ListView.builder(
                    itemCount: _suggestions.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Map<String, dynamic> suggestion = _suggestions[index];
                      final DateTime timestamp =
                          DateTime.parse(suggestion['timestamp'] as String);
                      final String formattedTime =
                          "${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";
                      final bool isActioned = suggestion['isActioned'] as bool;
                      final String actionNote = suggestion['actionNote'] as String;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        color: isActioned ? Colors.green.shade50 : null,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                suggestion['text'] as String,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              if (isActioned)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(Icons.check_circle, color: Colors.green[700], size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Actioned!",
                                        style: TextStyle(
                                            color: Colors.green[700],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              if (actionNote.isNotEmpty && isActioned)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0, left: 26.0),
                                  child: Text(
                                    "Note: $actionNote",
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey[700],
                                        fontSize: 13),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "Submitted: $formattedTime",
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => _showActionDialog(index),
                                    icon: Icon(isActioned ? Icons.edit : Icons.check),
                                    label: Text(isActioned ? "Edit Action" : "Take Action"),
                                    style: ElevatedButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
