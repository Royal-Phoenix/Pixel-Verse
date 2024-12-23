import 'dart:async';
import 'package:pixel_verse/components/players.dart';
import 'package:pixel_verse/components/utilities.dart';

abstract class Item extends SpriteAnimationGroupComponent
with HasGameRef<PixelVerse>, CollisionCallbacks {
    late final double fps;
    Map<String, SpriteAnimation> states = {};
    TiledObject item;
    late String name;
    int count = 0;
    bool isCollected = false;
    Hitbox hitbox = RectangleHitbox();
    Item({required this.item}) {
        name = item.name;
        super.position = Vector2(item.x, item.y);
        super.size = Vector2(item.width, item.height);
        loaditem(item.class_, item.name);
    }

    @override
    FutureOr<void> onLoad() {
        // debugMode = true;
        animations = { for (final entry in loadStates(item.class_, item.name).entries) states[entry.key]: entry.value };
        current = states[name];
        return super.onLoad();
    }

    SpriteAnimation itemAnimation(String path, int amount, double fps) {
        return game.gameAnimation('Items/$path.png', amount, fps);
    }

    Map<String, SpriteAnimation> loadStates(String class_, String name_) {
        states[name] = itemAnimation('$class_/$name', 1, fps);
        states['Collected'] = itemAnimation('$class_/Collected', 6, fps)..loop = false;
        return states;
    }

    void loaditem(String class_, String name) {
        final data = PixelVerse.itemData[class_][name];
        fps = PixelVerse.itemData[class_]['common']['fps'];
        hitbox = getHitbox(data['hitbox']);
        add(hitbox as Component);
    }
    
    void playerCollision(Player player);
}
