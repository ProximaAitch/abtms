import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as genai;
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Message {
  final int id;
  final bool isUser;
  final String message;
  final DateTime date;

  const Message({
    required this.id,
    required this.isUser,
    required this.message,
    required this.date,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      isUser: map['isUser'],
      message: map['message'],
      date: map['timestamp'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isUser': isUser,
      'message': message,
      'timestamp': Timestamp.fromDate(date),
    };
  }
}

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({Key? key}) : super(key: key);

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  static const apiKey = 'AIzaSyDlZMRly2BTsUK1c4OhfTBrKKrw15UREL0';
  final genai.GenerativeModel _model =
      genai.GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  final TextEditingController _userInput = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];

  String formatChatbotResponse(String text) {
    // Handle bullet points with bold subtopics and make the bold text all caps
    text = text.replaceAllMapped(RegExp(r'\* \*\*(.*?)\*\*'),
        (match) => '<br><br><b>${match[1]?.toUpperCase()}</b><br>');

    // Add a line break before every bold item, format bullets properly, and make bold text all caps
    text = text.replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'),
        (match) => '<br><br><b>${match[1]?.toUpperCase()}</b><br>');
    text = text.replaceAllMapped(
        RegExp(r'\*(.*?)\n'), (match) => '<ul><li>${match[1]}</li></ul><br>');

    text = text.replaceAllMapped(RegExp(r'([^\*]*?)(\*\*|\* )'), (match) {
      return '${match[1]}<br>${match[2]}';
    });
    return text;
  }

  bool _isLoading = false;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _userInput.addListener(_updateButtonState);
    _loadPreviousChats();
  }

  @override
  void dispose() {
    _userInput.removeListener(_updateButtonState);
    _userInput.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _userInput.text.isNotEmpty;
    });
  }

  Future<void> _loadPreviousChats() async {
    final userUid = FirebaseAuth.instance.currentUser!.uid;
    final chatSnapshot = await FirebaseFirestore.instance
        .collection('patients')
        .doc(userUid)
        .collection('chats')
        .orderBy('id', descending: false)
        .get();

    setState(() {
      _messages.clear();
      _messages
          .addAll(chatSnapshot.docs.map((doc) => Message.fromMap(doc.data())));
    });

    _scrollToBottom();
  }

  Future<void> _scrollToBottom() async {
    await Future.delayed(Duration(milliseconds: 300));
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  Future<void> _sendPrompt() async {
    final message = _userInput.text;
    _userInput.clear();

    final DateTime now = DateTime.now();
    final userMessageId = _messages.length * 2 + 1;
    final chatbotMessageId = userMessageId + 1;

    final userMessage = Message(
      id: userMessageId,
      isUser: true,
      message: message,
      date: now,
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    final content = [genai.Content.text(message)];
    final response = await _model.generateContent(content);

    final chatbotMessage = Message(
      id: chatbotMessageId,
      isUser: false,
      message: response.text ?? "",
      date: now,
    );

    setState(() {
      _isLoading = false;
      _messages.add(chatbotMessage);
    });

    await _saveMessagesToFirestore([userMessage, chatbotMessage]);
    _scrollToBottom();
  }

  Future<void> _saveMessagesToFirestore(List<Message> messages) async {
    final userUid = FirebaseAuth.instance.currentUser!.uid;
    final batch = FirebaseFirestore.instance.batch();
    final chatCollection = FirebaseFirestore.instance
        .collection('patients')
        .doc(userUid)
        .collection('chats');

    for (var message in messages) {
      batch.set(chatCollection.doc(), message.toMap());
    }

    await batch.commit();
  }

  Future<void> _clearChats() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Chats"),
          content: Text("Are you sure you want to delete all chats?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.black)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteAllChats();
    }
  }

  Future<void> _deleteAllChats() async {
    final userUid = FirebaseAuth.instance.currentUser!.uid;
    final chatCollection = FirebaseFirestore.instance
        .collection('patients')
        .doc(userUid)
        .collection('chats');
    final chatDocs = await chatCollection.get();

    final batch = FirebaseFirestore.instance.batch();
    for (var doc in chatDocs.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildInputArea(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.grey[50],
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        "ChatBot",
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.delete, size: 27, color: Colors.red),
          onPressed: _clearChats,
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final formattedDate =
            DateFormat('EEE, d MMMM yyyy h:mma').format(message.date);
        return MessageBubble(
          id: message.id,
          isUser: message.isUser,
          message: message.isUser
              ? message.message
              : formatChatbotResponse(message.message),
          date: formattedDate,
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _userInput,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: Color.fromARGB(255, 79, 94, 234),
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Color(0xFF343F9B),
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                    fontSize: 16),
                hintText: "Ask your question",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
          SizedBox(width: 5),
          _isLoading
              ? SizedBox(
                  width: 25,
                  height: 25,
                  child: CupertinoActivityIndicator(
                    color: Color(0xFF343F9B),
                  ),
                )
              : _isButtonEnabled
                  ? IconButton(
                      onPressed: _sendPrompt,
                      icon: Icon(
                        Icons.send_rounded,
                        color: Color(0xFF343F9B),
                      ),
                    )
                  : Icon(Icons.send_rounded, color: Colors.grey),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final int id;
  final bool isUser;
  final String message;
  final String date;

  const MessageBubble({
    Key? key,
    required this.id,
    required this.isUser,
    required this.message,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          margin: EdgeInsets.only(
            bottom: 5,
            top: 20,
            right: isUser ? 10 : 60,
            left: isUser ? 60 : 10,
          ),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(1, 2),
              ),
            ],
            color: isUser ? Colors.blue[50] : Colors.blueGrey[50],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(isUser ? 15 : 0),
              topRight: Radius.circular(15),
              bottomRight: Radius.circular(isUser ? 0 : 15),
            ),
          ),
          child: isUser
              ? Text(
                  message,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                )
              : Html(
                  data: message,
                  style: {
                    "body": Style(
                      fontSize: FontSize(16),
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    "b": Style(
                      fontWeight: FontWeight.w600,
                      fontSize: FontSize(15),
                      color: Color(0xFF3E4D99),
                    ),
                    "ul": Style(
                      padding: HtmlPaddings.symmetric(vertical: 2),
                      margin: Margins.symmetric(vertical: 5),
                    ),
                    "li": Style(
                      fontSize: FontSize(15),
                      padding: HtmlPaddings.zero,
                    ),
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            date,
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
        ),
      ],
    );
  }
}
