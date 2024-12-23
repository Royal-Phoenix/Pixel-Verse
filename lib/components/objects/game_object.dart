import 'dart:async';
import 'package:pixel_verse/components/utilities.dart';

class GameObject extends SpriteAnimationGroupComponent
with HasGameRef<PixelVerse>, CollisionCallbacks {
    late final double fps;
    Map<String, SpriteAnimation> states = {};
    late String initialState;
    TiledObject gameObject;
    Hitbox hitbox = RectangleHitbox();
    GameObject({required this.gameObject}) {
        super.position = Vector2(gameObject.x, gameObject.y);
        super.size = Vector2(gameObject.width, gameObject.height);
        loadGameObject(gameObject.class_, gameObject.name);
    }

    @override
    FutureOr<void> onLoad() {
        // debugMode = true;
        animations = { for (final entry in loadStates(gameObject.class_, gameObject.name)) states[entry[0]]: entry[1] };
        current = states[initialState];
        return super.onLoad();
    }

    SpriteAnimation objectAnimation(String path, int amount, double fps) {
        return game.gameAnimation('Items/$path.png', amount, fps);
    }

    List<List> loadStates(String class_, String name_) {
        List<List> entries = [];
        final data = PixelVerse.objectData[class_][name_];
        final commonData = PixelVerse.objectData[class_]['common'];
        final objectStates = data.containsKey('states') ? data['states'] : commonData['states'];
        objectStates.forEach((name, data) {
            SpriteAnimation state = objectAnimation('$class_/$name_/$name', data[0], fps)..loop = data[1];
            states[name] = state;
            entries.add([name as String, state]);
        });
        return entries;
    }

    void loadGameObject(String class_, String name) {
        final data = PixelVerse.objectData[class_][name];
        final commonData = PixelVerse.objectData[class_]['common'];
        fps = commonData['fps'];
        initialState = commonData['current'];
        hitbox = getHitbox(data.containsKey('hitbox') ? data['hitbox'] : commonData['hitbox']);
        add(hitbox as Component);
    }
}