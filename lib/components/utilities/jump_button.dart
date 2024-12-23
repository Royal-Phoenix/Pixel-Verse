import 'dart:async';
import 'package:flame/events.dart';
import 'package:pixel_verse/components/utilities.dart';

class JumpButton extends SpriteComponent
with HasGameRef<PixelVerse>, TapCallbacks {
    double margin = 32;
    double buttonSize = 128;
    
    @override
    FutureOr<void> onLoad() {
        super.position = Vector2(margin, 360 - margin - buttonSize);
        super.sprite = Sprite(game.images.fromCache('Controls/JumpButton.png'));
        super.priority = 10;
        return super.onLoad();
    }

    @override
    void onTapDown(TapDownEvent event) {
        game.player.isJumping = true;
        super.onTapDown(event);
    }

    @override
    void onTapUp(TapUpEvent event) {
        game.player.isJumping = false;
        super.onTapUp(event);
    }
}