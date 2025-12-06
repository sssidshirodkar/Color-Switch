import 'dart:math' as math;
import 'dart:ui';

import 'package:color_switch_game/my_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class ColorSwitcher extends PositionComponent with HasGameReference<MyGame> {
  ColorSwitcher({required super.position, required super.size})
    : super(anchor: Anchor.center);

  final _colorSwitcherPaint = Paint();

  @override
  void onLoad() {
    super.onLoad();
    add(CircleHitbox(
      collisionType: CollisionType.passive
    ));
  }

  @override
  render(Canvas canvas) {
    super.render(canvas);

    const circle = math.pi * 2;
    final sweep = circle / game.gameColors.length;

    for (int i = 0; i < game.gameColors.length; i++) {
      canvas.drawArc(
        size.toRect(),
        i * sweep,
        sweep,
        true,
        _colorSwitcherPaint
          ..color = game.gameColors[i]
      );
    }
  }
}
