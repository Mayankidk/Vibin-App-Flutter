import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  Future<String> getGeminiResponse(String userMessage) async {
    final String apiKey = dotenv.env['API_KEY'] ?? '';

    if (apiKey.isEmpty) {
      throw Exception('API Key not found in .env file!');
    }

    // UPDATED MODEL
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
    );

    final payload = {
      'systemInstruction': {
        'parts': [
          {
            'text':
            "You are a helpful music assistant. Only answer questions about music. "
                "If the user asks something unrelated, politely say you only answer music questions."
          },
        ]
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': userMessage}
          ]
        }
      ],
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception(
            'Status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
