import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static Future<String> sendMessage(String message) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    print("API Key: $apiKey");

    // ✅ Check if API key exists
    if (apiKey == null || apiKey.isEmpty) {
      return "OpenAI API key not found! Please check your .env file.";
    }

    try {
      final response = await http
          .post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "system",
              "content":
              "You are a helpful chatbot inside a student music app called Vibin'."
            },
            {"role": "user", "content": message}
          ],
        }),
      )
          .timeout(const Duration(seconds: 10)); // ✅ timeout to avoid hang

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? "No response";
      } else {
        return "Error ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      return "Failed to connect to OpenAI: $e";
    }
  }
}
