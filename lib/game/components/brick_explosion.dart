import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class BrickExplosion extends ParticleSystemComponent {
  BrickExplosion({required Vector2 position, required Color color})
      : super(
          particle: Particle.generate(
            count: 15,
            lifespan: 0.8,
            generator: (i) => AcceleratedParticle(
              acceleration: Vector2(0, 10), // Gravity for particles
              speed: Vector2(
                (Random().nextDouble() - 0.5) * 20,
                (Random().nextDouble() - 0.5) * 20,
              ),
              position: position.clone(),
              child: CircleParticle(
                radius: 0.2 + Random().nextDouble() * 0.3,
                paint: Paint()..color = color.withOpacity(0.8),
              ),
            ),
          ),
        );
}
