import 'dart:async';
import 'dart:ui';
import 'package:pixel_verse/components/players/player.dart';
import 'package:pixel_verse/components/monsters.dart';
import 'package:pixel_verse/components/utilities.dart';

mixin ActiveMovement on Monster {
    void movement(dt) {
        velocity.x = 0;
        double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
        double offset = (scale.x > 0) ? 0 : -width;
        if (playerInRange(rangeNeg, rangePos)) {
            targetDirection = (player.x + playerOffset < position.x + offset) ? -1 : 1;
            velocity.x = targetDirection * speed;
        }
        moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;
        position.x += velocity.x * dt;
    }
}

mixin PassiveMovement on Monster {
    void movement(dt) {
        position.x += moveDirection * speed * dt;
        if (position.x <= rangeNeg) {
            position.x = rangeNeg;
            moveDirection *= -1;
        }
        if (position.x >= rangePos) {
            position.x = rangePos;
            moveDirection *= -1;
        }
    }
}

class Monster extends SpriteAnimationGroupComponent
with HasGameRef<PixelVerse>, CollisionCallbacks {
    late final double fps;
    late double hitPoints;
    late final double maxHitPoints;
    late double manaPoints;
    late final double maxManaPoints;
    late final double xp;
    late final double gold;
    late final double gravity;
    double speed = 0;
    late final double thrust;
    late final double damage;
    Vector2 velocity = Vector2.zero();
    late final Hitbox hitbox ;
    Map<String, SpriteAnimation> states = {};
    TiledObject monster;
    late double offNeg;
    late double offPos;
    late double rangeNeg;
    late double rangePos;
    late double moveDirection;
    late double targetDirection;
    late String initialState;
    late String collideState;
    bool hasAwakened = false;
    late final Player player;
    Monster({required this.monster}) {
        super.position =  Vector2(monster.x, monster.y);
        super.size =  Vector2(monster.width, monster.height);
        if (monster.name == 'Angry Pig') {
            collideState = 'Walk';
        }
        else {
            collideState = 'Hit';
            hasAwakened = true;
        }
        loadMonster(monster.name);
    }
    bool isAlive = true;

    factory Monster.getMonster(TiledObject monster) {
        return switch (monster.name) {
            'Chicken' => Chicken(monster: monster),
            'Ghost' => Ghost(monster: monster),
            'Mushroom' => Mushroom(monster: monster),
            'Rhino' => Rhino(monster: monster),
            'Angry Pig' => AngryPig(monster: monster),
            _ => Monster(monster: monster)
        };
    }

    @override
    FutureOr<void> onLoad() {
        // debugMode = true;
        priority = -1;
        player = game.player;
        rangeNeg = position.x - offNeg * tileSize;
        rangePos = position.x + offPos * tileSize;
        animations = { for (final entry in loadStates()) states[entry[0]]: entry[1] };
        current = states[initialState];
        return super.onLoad();
    }

    SpriteAnimation monsterAnimation(String path, int amount, double fps) {
        return game.gameAnimation('Monster/$path.png', amount, fps);
    }

    bool playerInRange(double rangeNeg, double rangePos) {
        double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
        return (
            player.x + playerOffset >= rangeNeg &&
            player.x + playerOffset <= rangePos &&
            player.y + player.height > position.y &&
            player.y < position.y + height
        );
    }

    void playerCollision() async {
        if (player.velocity.y > 0 && player.y + player.height > position.y) {
            if (!hasAwakened) {
                hasAwakened = true;
                current = states['Hit'];
                player.velocity.y = -thrust;
                collideState = 'Run';
                speed *= 2;
                current = states[collideState];
            }
            else {
                if (game.playSounds) FlameAudio.play('bounce.wav', volume: game.soundVolume);
                isAlive = false;
                current = states['Hit'];
                player.velocity.y = -thrust;
                await animationTicker?.completed;
                removeFromParent();
            }
        }
        else {
            player.healthBar.updateStatusBar(damage, 1);
            player.endCollision();
        }
    }

    List<List> loadStates() {
        List<List> entries = [];
        PixelVerse.monsterData[monster.name]['states'].forEach((name, data) {
            SpriteAnimation state = monsterAnimation('${monster.name}/$name', data[0], fps)..loop = data[1];
            states[name] = state;
            entries.add([name as String, state]);
        });
        return entries;
    }

    void loadMonster(String name) {
        final data = PixelVerse.monsterData[name];
        offNeg = monster.properties.getValue('offNeg');
        offPos = monster.properties.getValue('offPos');
        moveDirection = monster.properties.getValue('start');
        targetDirection = monster.properties.getValue('target');
        fps = data['fps'];
        maxHitPoints = hitPoints = data['HP'];
        maxManaPoints = manaPoints = data['MP'];
        xp = data['XP'];
        gold = data['gold'];
        gravity = data['gravity'];
        speed = data['speed'];
        thrust = data['thrust'];
        damage = data['damage'];
        initialState = data['current'];
        hitbox = getHitbox(data['hitbox']);
        add(hitbox as Component);
    }
}
