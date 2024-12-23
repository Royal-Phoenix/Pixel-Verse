import 'dart:async';
import 'dart:convert';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:pixel_verse/components/players/player.dart';
import 'package:pixel_verse/components/utilities.dart';

class PixelVerse extends FlameGame
with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
    @override
    Color backgroundColor() => const Color(0xFF211F30);
    static Map<String, dynamic> monsterData = {};
    static Map<String, dynamic> trapData = {};
    static Map<String, dynamic> objectData = {};
    static Map<String, dynamic> itemData = {};
    static Map<String, dynamic> playerData = {};
    late CameraComponent cam;
    late Level gameWorld;
    late Player player;
    late CustomJoystick joystick;
    late List<String> levelNames;
    double soundVolume = 1.0;
    int currentLevelIndex = 0;
    bool playerInitialized = false;
    bool showControls = false;
    bool playSounds = false;

    @override
    FutureOr<void> onLoad() async {
        monsterData = await assets.readJson('data/monsters.json');
        trapData = await assets.readJson('data/traps.json');
        objectData = await assets.readJson('data/objects.json');
        itemData = await assets.readJson('data/items.json');
        playerData = await assets.readJson('data/players.json');
        levelNames = await getLevelNames();
        await images.loadAllImages();
        _loadLevel();
        return super.onLoad();
    }

    @override
    void update(double dt) {
        if (showControls && playerInitialized) joystick.updateJoystick();
        super.update(dt);
    }

    Future<List<String>> getLevelNames() async {
        final String jsonString = await assets.bundle.loadString('AssetManifest.json');
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        return [for (String level in jsonMap.keys.where(
            (String key) => key.endsWith('.tmx')
        ).toList()) level.split('/').last];
    }

    void addJoystick() {
        joystick = CustomJoystick(
            player: player,
            knob: SpriteComponent(
                sprite: Sprite(images.fromCache('Controls/Knob.png')),
            ),
            background: SpriteComponent(
                sprite: Sprite(images.fromCache('Controls/Joystick.png')),
            ),
        );
        add(joystick);
    }

    void loadNextLevel() {
        removeAll([cam, gameWorld]);
        _loadLevel();
    }

    void _loadLevel() {
        Future.delayed(
            const Duration(milliseconds: 350),
            () {
                player = Player();
                gameWorld = Level(
                    player: player,
                    levelName: levelNames[currentLevelIndex++ % levelNames.length],
                );
                cam = CameraComponent.withFixedResolution(
                    world: gameWorld,
                    width: 640,
                    height: 360,
                );
                cam.viewfinder.anchor = Anchor.topLeft;
                addAll([cam, gameWorld]);
                playerInitialized = true;
                if (showControls && playerInitialized) {
                    addJoystick();
                    add(JumpButton());
                }
            }
        );
    }

    SpriteAnimation gameAnimation(String path, int amount, double fps) {
        final image = images.fromCache(path);
        return SpriteAnimation.fromFrameData(
            image,
            SpriteAnimationData.sequenced(
                amount: amount,
                stepTime: fps,
                textureSize: imageSize(image, amount),
            ),
        );
    }
}