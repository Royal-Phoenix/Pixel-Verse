import 'dart:async';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:pixel_verse/components/utilities.dart';

class GameButton extends PositionComponent
with HasGameRef<PixelVerse>, TapCallbacks {
    String name;
    Function() onPressed;
    late final Sprite sprite;
    final Paint paint = Paint();
    GameButton({required this.name, required this.onPressed, super.position, super.size});

    @override
    FutureOr<void> onLoad() {
        sprite = Sprite(game.images.fromCache('Menu/Buttons/$name.png'));
        return super.onLoad();
    }
    
    @override
    void onTapDown(TapDownEvent event) {
        onPressed();
        super.onTapDown(event);
    }

    @override
    void render(Canvas canvas) {
        sprite.render(canvas, position: Vector2.zero(), size: size);
    }

    @override
    void update(double dt) {}
}