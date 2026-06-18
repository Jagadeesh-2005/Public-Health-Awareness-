import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
class AwarenessVideosPage extends StatefulWidget {
  const AwarenessVideosPage({super.key});

  @override
  _AwarenessVideosPageState createState() => _AwarenessVideosPageState();
}

class _AwarenessVideosPageState extends State<AwarenessVideosPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _urlController = TextEditingController();
  List<String> _videoUrls = <String>[];

  @override
  void initState() {
    super.initState();
    _loadVideoUrls();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadVideoUrls() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Provide a default video URL if none are saved
    _videoUrls = prefs.getStringList('awarenessVideoUrls') ?? <String>[
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    ];
    setState(() {}); // Trigger rebuild to display loaded videos
  }

  Future<void> _addVideoUrl() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String newUrl = _urlController.text.trim();
      if (!_videoUrls.contains(newUrl)) {
        setState(() {
          _videoUrls.insert(0, newUrl); // Add new URL to the top
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('awarenessVideoUrls', _videoUrls);
        _urlController.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Video URL added successfully!')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('This video URL already exists.')));
        }
      }
    }
  }

  Future<void> _removeVideoUrl(int index) async {
    setState(() {
      _videoUrls.removeAt(index);
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('awarenessVideoUrls', _videoUrls);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video URL removed.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: "Video URL",
                      hintText: "Enter YouTube or other video URL",
                      border: OutlineInputBorder(),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a URL";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addVideoUrl,
                  child: const Text("Add"),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _videoUrls.isEmpty
              ? const Center(child: Text("No awareness videos added yet."))
              : ListView.builder(
                  itemCount: _videoUrls.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String videoUrl = _videoUrls[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        children: <Widget>[
                          AwarenessVideoPlayer(url: videoUrl),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    videoUrl,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeVideoUrl(index),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
