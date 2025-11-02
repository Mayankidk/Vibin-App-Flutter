// lib/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:vibin/services/api_service.dart';

// Define the message data structure.
class Message {
  final String text;
  final bool isUser; // true for user messages, false for bot messages

  Message({required this.text, required this.isUser});
}

// The stateful widget for the chat screen.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Controller for the text input field.
  final TextEditingController _textController = TextEditingController();
  // List to store all the messages in the chat.
  final List<Message> _messages = [];
  // State to track if the bot is currently typing.
  bool _isLoading = false;

  // Instantiate the ApiService to use for API calls.
  final ApiService _apiService = ApiService();

  // Function to handle sending a new message.
  void _sendMessage() async {
    final String messageText = _textController.text.trim();
    if (messageText.isEmpty) return;

    // Add the user's message to the chat list.
    setState(() {
      _messages.add(Message(text: messageText, isUser: true));
      _textController.clear();
      _isLoading = true;
    });

    // Use the new ApiService to get a bot response.
    await _fetchBotResponse(messageText);
  }

  // Updated function to fetch a bot's API response using the ApiService.
  Future<void> _fetchBotResponse(String userMessage) async {
    // Initializing the variable with an empty string resolves the error.
    String botResponseText = '';
    try {
      // Call the method in the ApiService to get the response.
      botResponseText = await _apiService.getGeminiResponse(userMessage);
    } catch (e) {
      // Handle errors from the API service.
      botResponseText = 'Error: ${e.toString()}';
    } finally {
      // Add the bot's response to the chat list.
      setState(() {
        _messages.add(Message(text: botResponseText, isUser: false));
        // Stop the loading animation.
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Chatbot'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: <Widget>[
          // Chat message list.
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return MessageBubble(message: message);
              },
            ),
          ),
          // Loading indicator for bot response.
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          // Text input area.
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  // Widget for the text input field and send button.
  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration.collapsed(
                  hintText: 'Send a message',
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _isLoading ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget for a single message bubble.
class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.all(12.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue.shade600 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
