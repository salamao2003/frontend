import 'package:flutter/material.dart';
import 'package:egy_metro/cubit/ChatBot_logic.dart';

// ChatMessage Widget
class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({
    Key? key,
    required this.text,
    required this.isUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: 8.0),
              child: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                ),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          if (isUser)
            Container(
              margin: const EdgeInsets.only(left: 8.0),
              child: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ChatBotPage Widget
class ChatBotPage extends StatefulWidget {
  const ChatBotPage({Key? key}) : super(key: key);

  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  List<ChatMessage> messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    messages.add(ChatMessage(
      text: ChatBotLogic.getWelcomeMessage(),
      isUser: false,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metro Assistant'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        color: Colors.blue.shade100,
        child: Column(
          children: [
            // Chat messages area
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8.0),
                itemCount: messages.length,
                itemBuilder: (context, index) => messages[index],
              ),
            ),
            
            // FAQ area with modern design
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFAQHeader(),
                      _buildQuestionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          const Icon(
            Icons.question_answer_rounded,
            color: Colors.blue,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionButtons() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: ChatBotLogic.quickQuestions.map((question) {
        return ElevatedButton(
          onPressed: () => _handleQuestionTap(question),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue[700],
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: Colors.blue[100]!,
                width: 1,
              ),
            ),
          ),
          child: Text(
            question.question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _handleQuestionTap(QuickQuestion question) {
    setState(() {
      messages.add(ChatMessage(
        text: question.question,
        isUser: true,
      ));
      
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          messages.add(ChatMessage(
            text: question.answer,
            isUser: false,
          ));
          // Auto-scroll to the bottom
          Future.delayed(const Duration(milliseconds: 100), () {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}