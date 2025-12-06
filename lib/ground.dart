import 'package:flame/components.dart';
import 'package:flame/rendering.dart';
import 'package:flutter/material.dart';

class Ground extends PositionComponent {
  static const keyName = 'single_ground_key';

  Ground({required super.position, double width = 200, double height = 0})
    : super(key: ComponentKey.named(keyName)) {
    size = Vector2(width, height);
    anchor = Anchor.center;
  }

  late Sprite fingerSprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    fingerSprite = await Sprite.load('tap_finger.png');
    decorator.addLast(PaintDecorator.tint(Colors.white));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    fingerSprite.render(
      canvas,
      position: Vector2(58, 0),
      size: Vector2(100, 100),
    );
  }
}
