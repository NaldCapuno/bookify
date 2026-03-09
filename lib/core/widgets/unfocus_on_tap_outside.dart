import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class UnfocusOnTapOutside extends StatelessWidget {
  const UnfocusOnTapOutside({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (PointerDownEvent event) {
        final focus = FocusManager.instance.primaryFocus;
        if (focus == null) return;

        final focusedContext = focus.context;
        final renderObject = focusedContext?.findRenderObject();
        if (renderObject is! RenderBox) {
          focus.unfocus();
          return;
        }

        final topLeft = renderObject.localToGlobal(Offset.zero);
        final rect = topLeft & renderObject.size;
        if (!rect.contains(event.position)) {
          focus.unfocus();
        }
      },
      child: child,
    );
  }
}

