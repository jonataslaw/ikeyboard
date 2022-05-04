import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

const Duration _kKeyboardTransition = Duration(milliseconds: 300);
const Curve _kKeyboardCurve = Curves.easeInOut;

const Curve _kKeyboardReverseCurve = Curves.easeInToLinear;

const _methodChannel = MethodChannel('ikeyboard');

extension KeyPaddingExt on Widget? {
  Widget keyboard() {
    return KeyboardPadding(
      child: this ?? const Material(),
    );
  }
}

class KeyboardPadding extends StatelessWidget {
  final Widget child;
  const KeyboardPadding({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final insets = media.viewInsets;
    final height = IKeyboard.of(context).height;
    return MediaQuery(
      data: media.copyWith(
        viewInsets: insets.copyWith(
          bottom: height,
        ),
      ),
      child: child,
    );
  }
}

class IKeyboard extends StatefulWidget {
  final Widget child;
  const IKeyboard({Key? key, required this.child}) : super(key: key);

  @override
  IKeyboardState createState() => IKeyboardState();

  static IKeyboardData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<IKeyboardData>()!;

  static Widget builder(BuildContext context, Widget? widget) {
    return widget.keyboard();
  }
}

class IKeyboardData extends InheritedWidget {
  final double kbHeight;
  final double animationValue;

  const IKeyboardData({
    Key? key,
    required this.kbHeight,
    required this.animationValue,
    required Widget child,
  }) : super(key: key, child: child);

  double get height => animationValue * kbHeight;

  @override
  bool updateShouldNotify(IKeyboardData oldWidget) {
    return oldWidget.height != height;
  }

  static IKeyboardData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<IKeyboardData>()!;
  }
}

class IKeyboardState extends State<IKeyboard>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final _animationController = AnimationController(
    vsync: this,
    duration: _kKeyboardTransition,
    reverseDuration: _kKeyboardTransition,
    value: _kbHeight,
  );
  late Animation _animation =
      Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    parent: _animationController,
    curve: _kKeyboardCurve,
    reverseCurve: _kKeyboardReverseCurve,
  ));
  var _kbHeight = 0.0;
  bool isClosing = true;

  bool get isKeyboardOpen => _animation.value > 0.0;

  double get kbHeight => _kbHeight;

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    if (!GetPlatform.isIOS) {
      return child;
    }
    return Listener(
      onPointerMove: (details) => onPointMove(details),
      onPointerUp: (details) => onPointUp(details),
      child: IKeyboardData(
        kbHeight: kbHeight,
        animationValue: _animation.value,
        child: child,
      ),
    );
  }

  @mustCallSuper
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResumed();
        break;
      case AppLifecycleState.inactive:
        onInactive();
        break;
      case AppLifecycleState.paused:
        onPaused();
        break;
      case AppLifecycleState.detached:
        onDetached();
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    FocusManager.instance.primaryFocus!.unfocus();
    _animationController.removeListener(notifySwiftKeyboard);
    _animationController.dispose();
    WidgetsBinding.instance!.removeObserver(this);
  }

  void forceCloseKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    notifySwiftKeyboard();
  }

  void fromCurrentToClose() {
    _animation =
        Tween(begin: 0.0, end: _animation.value).animate(CurvedAnimation(
      parent: _animationController,
      curve: _kKeyboardCurve,
      reverseCurve: _kKeyboardReverseCurve,
    ));
    _animationController.reverse().whenComplete(() {
      _backDefaultAnimation();
      FocusManager.instance.primaryFocus!.unfocus();
    });
  }

  @override
  void initState() {
    super.initState();
    if (GetPlatform.isIOS) {
      WidgetsBinding.instance!.addObserver(this);
      status(true);
      forceCloseKeyboard();
      _methodChannel.setMethodCallHandler(onNativeCallReceived);
      _animationController.addListener(notifySwiftKeyboard);
    }
  }

  void notifySwiftKeyboard() {
    if (GetPlatform.isIOS) {
      setState(() {});

      /// We updated the keyboard height in swift from its size in the view
      _methodChannel.invokeMethod(
          'update', _kbHeight + (_animation.value * _kbHeight) * -1);
    }
  }

  void onDetached() {}

  void onInactive() {
    status(false);
  }

  Future<void> onNativeCallReceived(MethodCall call) async {
    if (call.method == 'show_keyboard') {
      _kbHeight = call.arguments;
      toCurrentToOpen();
    } else if (call.method == 'hide_keyboard') {
      if (_animation.value != 0.0) {
        _animation =
            Tween(begin: 0.0, end: _animation.value).animate(CurvedAnimation(
          parent: _animationController,
          curve: _kKeyboardCurve,
          reverseCurve: _kKeyboardReverseCurve,
        ));

        _animationController.reverse().whenComplete(() {
          _backDefaultAnimation();
        });
      }
    } else if (call.method == 'update_keyboard') {
      _kbHeight = call.arguments;
      setState(() {});
    }
  }

  void onPaused() {}

  void onPointMove(PointerMoveEvent details) {
    if (!isKeyboardOpen || !GetPlatform.isIOS) return;
    final kb = _kbHeight;

    if (details.delta.dy.isNegative) {
      isClosing = false;
    } else {
      isClosing = true;
    }

    final position = min(Get.height - details.localPosition.dy, kb) / kb;

    final swiftPosition = kb + (_animation.value * kb) * -1;
    if (position < 0.1) {
      fromCurrentToClose();
    }

    _animation = Tween(begin: position, end: position).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
      reverseCurve: Curves.linear,
    ));

    _methodChannel.invokeMethod('update', swiftPosition);
    setState(() {});
  }

  void onPointUp(PointerUpEvent details) {
    if (!isKeyboardOpen) {
      return;
    }

    final minPosition = min(Get.height - details.localPosition.dy, _kbHeight);

    final position = minPosition / _kbHeight;
    bool canContinue = position < 1.0;

    if (!canContinue) {
      return;
    }

    if (!isClosing) {
      toCurrentToOpen();
    } else {
      fromCurrentToClose();
    }
  }

  void onResumed() {
    status(true);
    setState(() {});
  }

  void status(bool active) {
    _methodChannel.invokeMethod('active', active);
  }

  void toCurrentToOpen() {
    final previousValue = _animation.value;
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: _kKeyboardCurve,
      reverseCurve: _kKeyboardReverseCurve,
    ));

    _animationController
        .forward(from: previousValue)
        .whenComplete(() => _backDefaultAnimation());
  }

  void _backDefaultAnimation() {
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: _kKeyboardCurve,
      reverseCurve: _kKeyboardReverseCurve,
    ));
  }
}
