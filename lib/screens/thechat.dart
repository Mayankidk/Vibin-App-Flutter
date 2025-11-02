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
  // Controller for scrolling the chat list. (UX Improvement)
  final ScrollController _scrollController = ScrollController();

  // List to store all the messages in the chat.
  final List<Message> _messages = [];
  // State to track if the bot is currently typing.
  bool _isLoading = false;

  // Instantiate the ApiService to use for API calls.
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    // 1. **Best Practice:** Clean up controllers when the widget is removed.
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Helper function to scroll to the bottom of the list.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Function to handle sending a new message.
  void _sendMessage() async {
    final String messageText = _textController.text.trim();
    if (messageText.isEmpty) return;

    // Add the user's message to the chat list and clear input.
    setState(() {
      _messages.add(Message(text: messageText, isUser: true));
      _textController.clear();
      _isLoading = true;
    });

    // Scroll immediately after user sends the message
    _scrollToBottom();

    // Use the new ApiService to get a bot response.
    await _fetchBotResponse(messageText);
  }

  // Updated function to fetch a bot's API response using the ApiService.
  Future<void> _fetchBotResponse(String userMessage) async {
    String botResponseText = '';
    try {
      // Call the method in the ApiService to get the response.
      botResponseText = await _apiService.getGeminiResponse(userMessage);
    } catch (e) {
      // Handle errors from the API service.
      botResponseText = 'Error: API request failed. Check console for details.';
      // Optionally print full error for debugging
      print(e);
    } finally {
      // Add the bot's response to the chat list and stop loading.
      setState(() {
        _messages.add(Message(text: botResponseText, isUser: false));
        _isLoading = false;
      });
      // Scroll to bottom after the bot's response is added.
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using colorScheme for better theme compatibility
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vibin Music Chatbot'),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: Column(
        children: <Widget>[
          // Chat message list.
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Attach ScrollController
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                // Added a key for better list performance
                return MessageBubble(key: ValueKey(message), message: message);
              },
            ),
          ),
          // Loading indicator for bot response.
          if (_isLoading)
            LinearProgressIndicator(
              backgroundColor: colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              minHeight: 3.0,
            ),
          // Text input area.
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: colorScheme.surface),
            child: _buildTextComposer(context),
          ),
        ],
      ),
    );
  }

  // Widget for the text input field and send button.
  Widget _buildTextComposer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              controller: _textController,
              onSubmitted: _isLoading ? null : (_) => _sendMessage(),
              decoration: InputDecoration.collapsed(
                hintText: 'Ask about music...',
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.6)),
              ),
              cursorColor: colorScheme.primary,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: Icon(Icons.send, color: colorScheme.primary),
              onPressed: _isLoading ? null : _sendMessage,
              // Color of the icon is grayed out when disabled
              disabledColor: colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
        ],
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
    final colorScheme = Theme.of(context).colorScheme;

    // Choose colors based on the role and theme
    final bubbleColor = message.isUser ? colorScheme.primary : colorScheme.surfaceVariant;
    final textColor = message.isUser ? colorScheme.onPrimary : colorScheme.onSurfaceVariant;

    return Container(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.all(12.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: bubbleColor,
          // Use different radius shapes for user vs. bot bubbles
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20.0),
            topRight: const Radius.circular(20.0),
            bottomLeft: Radius.circular(message.isUser ? 20.0 : 4.0),
            bottomRight: Radius.circular(message.isUser ? 4.0 : 20.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: textColor,
          ),
        ),
      ),
    );
  }
}
