import 'package:flutter/material.dart';
import 'package:ikeyboard/ikeyboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const IKeyboard(
      child: MaterialApp(
        home: Home(),
        builder: IKeyboard.builder,
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: const [
                ChatBubble(
                  text: 'Hello!',
                  isMe: false,
                ),
                ChatBubble(
                  text: 'Awesome! The iOS keyboard move with your fingers',
                  isMe: true,
                ),
                ChatBubble(
                  text: 'Oh, yeah, it is the interactive keyboard',
                  isMe: false,
                ),
                ChatBubble(
                  text: 'iKeyboard brings the interactive keyboard to Flutter',
                  isMe: true,
                ),
                ChatBubble(
                  text: 'Let\'s try it!',
                  isMe: false,
                ),
              ],
            ),
          ),
          TextFormField(
            autocorrect: false,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              fillColor: Colors.grey,
              border: InputBorder.none,
              suffixIcon: Icon(
                Icons.send,
                color: Colors.purple,
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  borderSide: BorderSide(color: Colors.purple)),
              filled: true,
              contentPadding:
                  EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    Key? key,
    required this.text,
    required this.isMe,
  }) : super(key: key);
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: isMe ? 60.0 : 20.0,
        right: isMe ? 20.0 : 60.0,
        bottom: 5,
      ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isMe ? Colors.purple : Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: isMe ? Colors.white : Colors.black87,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
