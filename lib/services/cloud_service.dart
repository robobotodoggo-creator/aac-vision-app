import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudService {
  String? _apiKey;
  DateTime? _lastRequest;
  List<String>? _cachedSuggestions;
  static const _cacheDuration = Duration(seconds: 30);
  static const _timeout = Duration(seconds: 5);

  void setApiKey(String key) {
    _apiKey = key;
  }

  bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;

  Future<List<String>?> getSuggestions({
    required List<String> detectedObjects,
    required List<String> recentPhrases,
  }) async {
    if (!isConfigured) return null;

    if (_lastRequest != null &&
        _cachedSuggestions != null &&
        DateTime.now().difference(_lastRequest!) < _cacheDuration) {
      return _cachedSuggestions;
    }

    try {
      final now = DateTime.now();
      final timeOfDay = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

      final response = await http
          .post(
            Uri.parse('https://api.anthropic.com/v1/messages'),
            headers: {
              'Content-Type': 'application/json',
              'x-api-key': _apiKey!,
              'anthropic-version': '2023-06-01',
            },
            body: json.encode({
              'model': 'claude-sonnet-4-5-20250929',
              'max_tokens': 200,
              'messages': [
                {
                  'role': 'user',
                  'content':
                      'You are an AAC communication assistant. The user is nonverbal and uses '
                          'symbol-based communication. Based on their environment and recent '
                          'communication, suggest 4-6 relevant words/phrases they might want to say.\n\n'
                          'Detected objects in view: ${detectedObjects.join(", ")}\n'
                          'Recent phrases spoken: ${recentPhrases.join(", ")}\n'
                          'Time of day: $timeOfDay\n\n'
                          'Return ONLY a JSON array of suggestion strings, nothing else.\n'
                          'Example: ["I want to eat", "more please", "all done", "drink water"]',
                }
              ],
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final content = data['content'] as List?;
        if (content == null || content.isEmpty) return null;
        final text = (content[0] as Map<String, dynamic>?)?['text'] as String?;
        if (text == null) return null;
        final suggestions = List<String>.from(json.decode(text) as List);
        _cachedSuggestions = suggestions;
        _lastRequest = DateTime.now();
        return suggestions;
      }
    } catch (_) {
      // Fail silently — fall back to on-device suggestions
    }
    return null;
  }
}
