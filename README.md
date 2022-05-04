# iKeyboard

A plugin that brings native iOS keyboard behavior to Flutter.

## Getting Started

Just put IKeyboard as MaterialApp ancestor and put IKeyboard.builder in MaterialApp builder, like this:

```dart
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
```

This is the result:

![](https://raw.githubusercontent.com/jonataslaw/ikeyboard/master/ikeyboard.gif)