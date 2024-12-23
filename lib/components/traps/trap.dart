import 'dart:async';
import 'package:pixel_verse/components/players/player.dart';
import 'package:pixel_verse/components/traps.dart';
import 'package:pixel_verse/components/utilities.dart';

class Trap extends SpriteAnimationGroupComponent with HasGameRef<PixelVerse> {
    late String type;
    late dynamic offNeg;
    late dynamic offPos;
    late dynamic rangeNeg;
    late dynamic rangePos;
    late final double fps;
    late final double damage;
    late String initialState;
    List<double> direction = [];
    double speed = 0;
    late final Hitbox hitbox;
    TiledObject trap;
    Map<String, SpriteAnimation> states = {};
    Trap({required this.trap}) {
        super.position = Vector2(trap.x, trap.y);
        super.size = Vector2(trap.width, trap.height);
        loadTrap(trap.name);
    }

    factory Trap.getTrap(TiledObject trap) {
        return switch (trap.name) {
            'Falling Platform' => FallingPlatform(trap: trap),
            'Rock Head' => RockHead(trap: trap),
            'Spike Head' => SpikeHead(trap: trap),
            'Spiked Ball' => SpikedBall(trap: trap),
            'Saw' => Saw(trap: trap),
            'Spikes' => Spikes(trap: trap),
            'Platform' => Platforms(trap: trap),
            'Fire' => Fire(trap: trap),
            'Trampoline' => Trampoline(trap: trap),
            'Fan' => Fan(trap: trap),
            _ => Trap(trap: trap)
        };
    }

    @override
    FutureOr<void> onLoad() {
        // debugMode = true;
        priority = -1;
        if (['Vertical', 'Horizontal'].contains(type)) {
            double fallingPlatformPosition = type == 'Vertical' ? position.y : position.x;
            rangeNeg = fallingPlatformPosition - offNeg * tileSize;
            rangePos = fallingPlatformPosition + offPos * tileSize;
        }
        else if (['Clockwise', 'AntiClockwise'].contains(type)) {
            rangeNeg = [position.x - offNeg[0] * tileSize, position.y - offNeg[1] * tileSize];
            rangePos = [position.x + offPos[0] * tileSize, position.y + offPos[1] * tileSize];
        }
        animations = { for (final entry in loadStates()) states[entry[0]]: entry[1] };
        current = states[initialState];
        return super.onLoad();
    }

    @override
    void update(double dt) {
        if (direction.isNotEmpty) {
            direction = blockMovement(type, position, dt, speed, direction, offNeg, offPos, rangeNeg, rangePos);
        }
        super.update(dt);
    }

    SpriteAnimation trapAnimation(String path, int amount, double fps) {
        return game.gameAnimation('Trap/$path.png', amount, fps);
    }

    List<List> loadStates() {
        List<List> entries = [];
        PixelVerse.trapData[trap.name]['states'].forEach((name, data) {
            SpriteAnimation state = trapAnimation('${trap.name}/$name', data[0], fps)..loop = data[1];
            states[name] = state;
            entries.add([name as String, state]);
        });
        return entries;
    }

    void loadTrap(String name) {
        final data = PixelVerse.trapData[name];
        type = trap.properties.getValue('type');
        if (type != 'Idle') {
            if (['Vertical', 'Horizontal'].contains(type)) {
                offNeg = trap.properties.getValue('offNeg');
                offPos = trap.properties.getValue('offPos');
                direction = [trap.properties.getValue('start')];
            }
            else if (['Clockwise', 'AntiClockwise'].contains(type)) {
                offNeg = [trap.properties.getValue('offNegX'), trap.properties.getValue('offNegY')];
                offPos = [trap.properties.getValue('offPosX'), trap.properties.getValue('offPosY')];
                direction = [trap.properties.getValue('startX'), trap.properties.getValue('startY')];
            }
        }
        fps = data['fps'];
        damage = data['damage'];
        speed = data['speed'];
        initialState = data['current'];
        hitbox = getHitbox(data['hitbox']);
        add(hitbox as Component);
    }

    void playerCollision(Player player) async {
        player.healthBar.updateStatusBar(damage, 1);
        player.endCollision();
    }
}
