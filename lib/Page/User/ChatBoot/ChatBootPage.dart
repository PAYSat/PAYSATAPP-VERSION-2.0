import 'package:flutter/material.dart';
import 'dart:async';

import 'package:proyectos_flutter/Provider/ChatBootProvider.dart';

// Colors
const Color mainColor = Color(0xFF04F4F0);
const Color navyBlue = Color(0xFF000080);
const Color softTomatoColor = Color(0xFFFF6347);
const Color lightTurquoise = Color(0xFFE0FFFF);

class ChatBotPage extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [];
  final ChatBotProvider _chatBotProvider = ChatBotProvider();
  final ScrollController _scrollController = ScrollController();
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    // No initial message
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isNotEmpty) {
      setState(() {
        messages.add({
          'sender': 'user',
          'message': userMessage,
          'isTyping': false,
        });
        isTyping = true;
      });
      _controller.clear();
      _scrollToBottom();

      setState(() {
        messages.add({
          'sender': 'bot',
          'message': '',
          'isTyping': true,
        });
      });
      _scrollToBottom();

      await Future.delayed(Duration(seconds: 3));

      String botResponse =
          await _chatBotProvider.getChatBotResponse(userMessage);

      setState(() {
        messages.removeLast();
        messages.add({
          'sender': 'bot',
          'message': botResponse,
          'isTyping': false,
        });
        isTyping = false;
      });
      _scrollToBottom();
    }
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: mainColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Escribiendo',
            style: TextStyle(color: navyBlue),
          ),
          SizedBox(width: 8),
          _buildDot(0),
          _buildDot(1),
          _buildDot(2),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: TweenAnimationBuilder(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 600),
        builder: (context, double value, child) {
          return Transform.translate(
            offset: Offset(0, -4 * value),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: navyBlue,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              'ChatBot PAYSat',
              style: TextStyle(
                color: navyBlue,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Tu Asistente Virtual',
              style: TextStyle(
                color: navyBlue.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        backgroundColor: mainColor,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [lightTurquoise, Colors.white],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isUser = message['sender'] == 'user';

                  if (message['isTyping'] == true) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(right: 64, bottom: 8),
                        child: _buildTypingIndicator(),
                      ),
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: 8,
                      left: isUser ? 64 : 0,
                      right: isUser ? 0 : 64,
                    ),
                    child: Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isUser ? softTomatoColor : mainColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          message['message'],
                          style: TextStyle(
                            color: isUser ? Colors.white : navyBlue,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !isTyping,
                      style: TextStyle(color: navyBlue),
                      decoration: InputDecoration(
                        hintText: isTyping
                            ? 'Espera la respuesta...'
                            : 'Escribe tu mensaje...',
                        hintStyle: TextStyle(color: navyBlue.withOpacity(0.4)),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: isTyping ? null : (_) => sendMessage(),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: isTyping ? Colors.grey : mainColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.send,
                        color: isTyping ? Colors.white : navyBlue,
                      ),
                      onPressed: isTyping ? null : sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
