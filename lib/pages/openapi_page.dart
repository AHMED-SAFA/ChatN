import 'package:chat_gpt_flutter/chat_gpt_flutter.dart';
import 'package:flutter/material.dart';

class OpenapiPage extends StatefulWidget {
  const OpenapiPage({super.key});

  @override
  State<OpenapiPage> createState() => _OpenapiPageState();
}

class _OpenapiPageState extends State<OpenapiPage> {
  //TODO: put your own apiKey here
  final chatGpt = ChatGpt(
      apiKey:
          'ssk-proj-kZSy_Vjd1B8WJHiPtQ1BcYHJCDRtQJglV2ssD2xHx7YUqo4T-BscdSkaFmMYG8R8t52l01wP-1T3BlbkFJA7ntqvuPKaLTa2gN5szM0ZscoF4iFTJiTMjiQIJjHHmVNibqCemjkN_m5I-AYl25w2c3sR-5cA');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatGPT Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ChatGPT'),
        ),
        body: ChatCompletionPage(
            chatGpt: chatGpt), // Single chat page for simplicity
      ),
    );
  }
}

class ChatCompletionPage extends StatefulWidget {
  final ChatGpt chatGpt;
  const ChatCompletionPage({required this.chatGpt, Key? key}) : super(key: key);

  @override
  State<ChatCompletionPage> createState() => _ChatCompletionPageState();
}

class _ChatCompletionPageState extends State<ChatCompletionPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages =
      []; // List to store user and bot messages
  bool _isLoading = false;

  Future<void> _sendMessage(String message) async {
    setState(() {
      _isLoading = true;
      _messages.add({"user": message});
    });

    try {
      // Use chatGPT API to get the bot response
      // final response = await widget.chatGpt.createChatCompletion(
      //   model: "gpt-3.5-turbo", // Specify the model you're using
      //   messages: [
      //     {
      //       "role": "user",
      //       "content": message,
      //     },
      //   ],
      //   maxTokens: 100, // Adjust max tokens based on your use case
      // );
      //
      // // Extract bot's reply
      // final botMessage = response.choices.first.message.content;
      //
      // setState(() {
      //   _messages.add({"bot": botMessage});
      //   _isLoading = false;
      // });
    } catch (e) {
      print("Error: $e");
      setState(() {
        _messages.add({"bot": "Sorry, something went wrong."});
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return _buildMessageBubble(
                message: message.values.first,
                isUser: message.keys.first == "user",
              );
            },
          ),
        ),
        if (_isLoading) const LinearProgressIndicator(),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildMessageBubble({required String message, required bool isUser}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7),
            decoration: BoxDecoration(
              color: isUser ? Colors.blue : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              style: TextStyle(color: isUser ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter your message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                _sendMessage(_controller.text);
                _controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
