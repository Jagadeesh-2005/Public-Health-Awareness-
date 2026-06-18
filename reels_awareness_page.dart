import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
class ReelsAwarenessPage extends StatelessWidget {
  const ReelsAwarenessPage({super.key});

  final List<Map<String, String>> reels = const <Map<String, String>>[
    {
      'title': 'Handwashing Awareness',
      'url': 'https://www.instagram.com/reel/CoTj1u9D9qZ/'
    },
    {
      'title': 'Nutrition for Children',
      'url': 'https://www.instagram.com/reel/Cm8DkCdjH9r/'
    },
    {
      'title': 'Sanitation & Hygiene',
      'url': 'https://www.instagram.com/reel/CkWJ9uTj8kH/'
    },
  ];

  Future<void> _launchReel(String url) async {
    final Uri reelUri = Uri.parse(url);
    try {
      if (await canLaunchUrl(reelUri)) {
        await launchUrl(reelUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (reels.isEmpty) {
      return const Center(child: Text("No reels available for awareness."));
    }
    return ListView.builder(
      itemCount: reels.length,
      itemBuilder: (BuildContext context, int index) {
        final Map<String, String> reel = reels[index];
        return Card(
          margin: const EdgeInsets.all(10),
          child: ListTile(
            leading: const Icon(Icons.play_circle_fill, color: Colors.purple, size: 36),
            title: Text(reel['title']!),
            onTap: () => _launchReel(reel['url']!),
          ),
        );
      },
    );
  }
}
