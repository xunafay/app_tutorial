library tutorial;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:app_tutorial/src/models/tutorial_item.dart';
import 'package:app_tutorial/src/painter/painter.dart';

class Tutorial {
  static late int count;
  static late Completer<void> _tutorialCompleter;
  static late List<TutorialItem> children;
  static late VoidCallback onTutorialComplete;
  static late OverlayState _overlayState;
  static OverlayEntry? _overlayEntry;

  static Future<void> showTutorial(
    BuildContext context,
    List<TutorialItem> children, {
    required VoidCallback onTutorialComplete,
  }) async {
    Tutorial.children = children;
    Tutorial.onTutorialComplete = onTutorialComplete;
    Tutorial.count = -1;
    _tutorialCompleter = Completer<void>();
    _overlayState = Overlay.of(context);

    await next(context);

    await _tutorialCompleter.future;
  }

  static Future<void> next(
    BuildContext context,
  ) async {
    count++;
    if (count < children.length) {
      final size = MediaQuery.of(context).size;
      if (_overlayEntry != null) {
        _overlayEntry!.remove();
      }

      await Scrollable.ensureVisible(
        children[count].globalKey.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      final offset = _capturePositionWidget(children[count].globalKey);
      final sizeWidget = _getSizeWidget(children[count].globalKey);
      _overlayEntry = OverlayEntry(
        builder: (context) {
          return GestureDetector(
            onTap: () {
              next(context);
            },
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  CustomPaint(
                    size: size,
                    painter: HolePainter(
                      shapeFocus: children[count].shapeFocus,
                      dx: offset.dx + (sizeWidget.width / 2),
                      dy: offset.dy + (sizeWidget.height / 2),
                      width: sizeWidget.width,
                      height: sizeWidget.height,
                      color: children[count].color,
                      borderRadius: children[count].borderRadius,
                      radius: children[count].radius,
                    ),
                  ),
                  children[count].child,
                ],
              ),
            ),
          );
        },
      );
      _overlayState.insert(_overlayEntry!);
    } else {
      _overlayEntry!.remove();
      _tutorialCompleter.complete();
      onTutorialComplete();
    }
  }

  static void skipAll(BuildContext context) {
    _overlayEntry!.remove();
    _tutorialCompleter.complete();
    onTutorialComplete();
  }

  /// This method returns the position of the widget
  static Offset _capturePositionWidget(GlobalKey key) {
    final renderPosition = key.currentContext!.findRenderObject()! as RenderBox;

    return renderPosition.localToGlobal(Offset.zero);
  }

  /// This method returns the size of the widget
  static Size _getSizeWidget(GlobalKey key) {
    final renderSize = key.currentContext!.findRenderObject()! as RenderBox;
    return renderSize.size;
  }
}
