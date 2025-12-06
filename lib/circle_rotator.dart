import 'dart:math' as math;
import 'dart:ui';

import 'package:color_switch_game/my_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class CircleRotator extends PositionComponent with HasGameReference<MyGame> {
  final double thickness;
  final double rotationSpeed; // Radians per second

  CircleRotator({
    required super.position,
    required super.size,
    this.thickness = 8.0,
    this.rotationSpeed = 4.0,
  }) : assert(size!.x == size.y),
       super(anchor: Anchor.center);

  @override
  Future onLoad() async {
    await super.onLoad();
    const circle = math.pi * 2;
    final sweep = circle / game.gameColors.length;

    for (int i = 0; i < game.gameColors.length; i++) {
      add(
        CircleArc(
          angleStart: i * sweep,
          angleEnd: sweep,
          color: game.gameColors[i],
        ),
      );
    }
    add(
      RotateEffect.to(
        math.pi * 2,
        EffectController(duration: rotationSpeed, infinite: true),
      ),
    );
  }
}

class CircleArc extends PositionComponent with ParentIsA<CircleRotator> {
  final double angleStart;
  final double angleEnd;
  final Color color;
  final _arcPaint = Paint();

  CircleArc({
    required this.angleStart,
    required this.angleEnd,
    required this.color,
  }) : super(anchor: Anchor.center);

  @override
  void onMount() {
    super.onMount();
    size = parent.size;
    position = size / 2;

    _addHitBox();
  }

  void _addHitBox() {
    final center = size / 2;
    const precision = 8;

    final segment = angleEnd / (precision - 1);
    final radius = size.x / 2;
    final vertices = <Vector2>[];

    for (int i = 0; i < precision; i++) {
      final thisSegment = angleStart + segment * i;
      final x = math.cos(thisSegment);
      final y = math.sin(thisSegment);
      vertices.add(center + Vector2(x, y) * radius);
    }

    for (int i = precision - 1; i >= 0; i--) {
      final thisSegment = angleStart + segment * i;
      final x = math.cos(thisSegment);
      final y = math.sin(thisSegment);
      vertices.add(center + Vector2(x, y) * radius);
    }

    add(PolygonHitbox(vertices, collisionType: CollisionType.passive));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawArc(
      size.toRect().deflate(parent.thickness / 2),
      angleStart,
      angleEnd,
      false,
      _arcPaint
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = parent.thickness,
    );
  }
}
