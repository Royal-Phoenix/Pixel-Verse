import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';

class BackgroundTile extends ParallaxComponent {
    static const double scrollSpeed = 40;
    String backgroundColor;
    BackgroundTile({required this.backgroundColor}) {
        super.position = Vector2.zero();
        super.size = Vector2.all(64);
    }

    @override
    FutureOr<void> onLoad() async {
        priority = -10;
        parallax = await game.loadParallax(
            [ParallaxImageData('Background/$backgroundColor.png')],
            baseVelocity: Vector2(0, -scrollSpeed),
            repeat: ImageRepeat.repeat,
            fill: LayerFill.none,
        );
        return super.onLoad();
    }
}