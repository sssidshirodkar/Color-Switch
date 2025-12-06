import 'package:color_switch_game/circle_rotator.dart';
import 'package:color_switch_game/color_switcher.dart';
import 'package:color_switch_game/ground.dart';
import 'package:color_switch_game/my_game.dart';
import 'package:color_switch_game/star_component.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

class Player extends PositionComponent
    with HasGameReference<MyGame>, CollisionCallbacks {
  final _velocity = Vector2.zero();
  final _gravity = 980.0;
  final _jumpSpeed = 350.0;
  final double playerRadius;
  Color _color = Colors.white;
  final _playerPaint = Paint();

  Player({required super.position, this.playerRadius = 13.0})
    : super(anchor: Anchor.center, priority: 20);

  @override
  void onLoad() {
    super.onLoad();
    add(CircleHitbox(collisionType: CollisionType.active));
  }

  @override
  void onMount() {
    // position = Vector2.zero();
    size = Vector2.all(playerRadius * 2);
    anchor = Anchor.center;
    super.onMount();
  }

  @override
  update(double dt) {
    // Player update logic here
    super.update(dt);
    position += _velocity * dt;

    Ground ground = game.findByKeyName(Ground.keyName)! as Ground;
    if (position.y + playerRadius > ground.position.y) {
      _velocity.setZero();
      position.y = ground.position.y - playerRadius;
    } else {
      _velocity.y += _gravity * dt;
    }
  }

  @override
  render(Canvas canvas) {
    // Player render logic here
    super.render(canvas);
    canvas.drawCircle(
      Offset(playerRadius, playerRadius),
      playerRadius,
      _playerPaint..color = _color,
    );
  }

  void jump() {
    // Player jump logic here
    _velocity.y = -_jumpSpeed;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is ColorSwitcher) {
      // Handle collision with ColorSwitcher
      other.removeFromParent();
      switchRandomColor();
    } else if (other is CircleArc) {
      // Handle collision with CircleArc
      if (other.color != _color) {
        game.gameOver();
        FlameAudio.play('hit.wav', volume: 0.25);
      }
    } else if (other is StarComponent) {
      // Handle collision with StarComponent
      other.showCollisionEffect();
      game.incrementScore();
      game.addNextGameComponentsIfNeeded(other);
      FlameAudio.play('pickup.wav', volume: 0.25);
    }
  }

  void switchRandomColor() {
    _color = game.gameColors.random();
  }
}
