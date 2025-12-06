import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame/rendering.dart';
import 'package:flutter/material.dart';

class StarComponent extends PositionComponent {
  StarComponent({required super.position, required super.size});

  late Sprite starSprite;
  final _starPaint = Paint();

  @override
  void onLoad() async {
    super.onLoad();
    anchor = Anchor.center;

    add(CircleHitbox(collisionType: CollisionType.passive));

    starSprite = await Sprite.load('star.png');
    decorator.addLast(PaintDecorator.tint(Colors.greenAccent));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    starSprite.render(canvas, size: size);
  }

  void showCollisionEffect() {
    final rnd = Random();
    Vector2 randomVector2() =>
        (Vector2.random(rnd) - Vector2.random(rnd)) * 80;

    parent!.add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 30,
          lifespan: 1,
          generator: (i) {
            return AcceleratedParticle(
              acceleration: randomVector2(),
              speed: randomVector2(),
              child: RotatingParticle(
                to: rnd.nextDouble() * pi * 2,
                child: ComputedParticle(
                  renderer: (canvas, particle) {
                    starSprite.render(
                      canvas,
                      size: (size / 2) * (1 - particle.progress),
                      overridePaint: _starPaint
                        ..colorFilter = ColorFilter.mode(
                          Colors.greenAccent.withAlpha(
                            (255.0 * (1 - particle.progress)).round(),
                          ),
                          BlendMode.srcATop,
                        ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );

    removeFromParent();
  }
}
