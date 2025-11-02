import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ApiService class handles all communication with the Gemini API.
class ApiService {
  // Method to fetch a response from the Gemini API.
  Future<String> getGeminiResponse(String userMessage) async {
    // Retrieve the API key from the environment variables.
    final String apiKey = dotenv.env['API_KEY'] ?? '';

    // Check if the API key is missing and throw an error if so.
    if (apiKey.isEmpty) {
      throw Exception('API Key not found in .env file!');
    }

    // The Gemini API endpoint for the 'gemini-2.5-flash-preview-05-20' model.
    final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent?key=$apiKey');

    // The request body for the API call.
    final payload = {
      'contents': [
        {
          'parts': [
            {'text': userMessage}
          ]
        }
      ]
    };

    try {
      // Make the POST request to the API.
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      // Check if the request was successful (status code 200).
      if (response.statusCode == 200) {
        // Parse the JSON response.
        final jsonResponse = jsonDecode(response.body);
        // Extract the generated text from the response.
        return jsonResponse['candidates'][0]['content']['parts'][0]['text']
        as String;
      } else {
        // Throw an exception for a non-successful response.
        throw Exception(
            'Failed to get a response from the bot. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Catch and rethrow any network or parsing errors.
      throw Exception('An error occurred: $e');
    }
  }
}