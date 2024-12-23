import 'dart:async';
import 'package:pixel_verse/components/utilities.dart';
import 'package:flutter/material.dart';

class StatusBar extends SpriteAnimationComponent with HasGameRef<PixelVerse> {
    String name;
    double points = 0;
    double maxPoints = 1;
    double limit = 0;
    Color color = Colors.blue;
    StatusBar({required this.name}) {
        if (name == 'Health Bar') {
            super.position = Vector2(0, -2);
            _updateHealthBar(0);
        }
        else if (name == 'Mana Bar') {
            super.position = Vector2(0, -8);
            _updateManaBar(0);
        }
    }

    @override
    void render(Canvas canvas) {
        paint = Paint()..color = color;
        canvas.drawRect(Rect.fromLTWH(4, 3, 24 * limit, 2), paint);
        super.render(canvas);
    }

    @override
    FutureOr<void> onLoad() {
        // debugMode = true;
        animation = game.gameAnimation('Player/Gear/Status Bar.png', 1, 1);
        return super.onLoad();
    }

    void updateStatusBar(double points, double duration) async {
        points = (maxPoints - this.points  >= points) ? points : maxPoints - this.points;
        if (name == 'Health Bar') {
            for (int i=0; i < duration; i++) {
                await Future.delayed(const Duration(milliseconds: 100), () => _updateHealthBar(points));
            }
        }
        else if (name == 'Mana Bar') {
            for (int i=0; i < duration; i++) {
                await Future.delayed(const Duration(milliseconds: 100), () => _updateManaBar(points));
            }
        }
    }
    
    void _updateHealthBar(double health) async {
        points += health;
        if (points > maxPoints) points = maxPoints;
        limit = points / maxPoints;
        if (limit >= 0.6) {
            color = Colors.green;
        }
        else if (limit >= 0.3) {
            color = Colors.yellow;
        }
        else {
            if (limit <= 0) limit = points = 0;
            color = Colors.red;
        }
    }

    void _updateManaBar(double mana) async {
        points += mana;
        if (points > maxPoints) points = maxPoints;
        limit = points / maxPoints;
        if (limit <= 0) limit = points = 0;
    }
}