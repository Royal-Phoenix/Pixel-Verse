import 'dart:async';
import 'package:flame/events.dart';
import 'package:pixel_verse/components/objects.dart';
import 'package:pixel_verse/components/items.dart';
import 'package:pixel_verse/components/players/player.dart';
import 'package:pixel_verse/components/traps.dart';
import 'package:pixel_verse/components/monsters.dart';
import 'package:pixel_verse/components/utilities.dart';

class Level extends World with TapCallbacks {
    late TiledComponent level;
    final String levelName;
    final Player player;
    Level({required this.player, required this.levelName});

    @override
    FutureOr<void> onLoad() async {
        level = await TiledComponent.load(levelName, Vector2.all(tileSize));
        add(level);
        _scrollingBackground();
        _addTrapsLayer();
        _addObjectsLayer();
        _addCollisionsLayer();
        return super.onLoad();
    }

    @override
    void onTapDown(TapDownEvent event) async {
        player.handleMouseClick(event.localPosition);
        super.onTapDown(event);
    }

    void _scrollingBackground() {
        final backgroundLayer = level.tileMap.getLayer('Background');
        if (backgroundLayer != null) {
            final backgroundColor = backgroundLayer.properties.getValue('BackgroundColor');
            add(BackgroundTile(backgroundColor: backgroundColor));
        }
    }

    void _addTrapsLayer() async {
        final trapsLayer = level.tileMap.getLayer<ObjectGroup>('Traps Layer');
        if (trapsLayer != null) {
            for (final trap in trapsLayer.objects) {
                if (trap.class_ == 'Monster') add(Monster.getMonster(trap));
                if (trap.class_ == 'Trap') {
                    CollisionBlock trapCollision;
                    final newTrap = Trap.getTrap(trap);
                    add(newTrap);
                    if (['Falling Platform', 'Rock Head', 'Spike Head', 'Fire'].contains(trap.name)) {
                        if (['Vertical', 'Horizontal'].contains(newTrap.type)) {
                            trapCollision = CollisionBlock.linear(
                                block: trap,
                                moveSpeed: newTrap.speed,
                                hitbox: newTrap.hitbox,
                            );
                        }
                        else if (['Clockwise', 'AntiClockwise'].contains(newTrap.type)) {
                            trapCollision = CollisionBlock.spiral(
                                block: trap,
                                moveSpeed: newTrap.speed,
                                hitbox: newTrap.hitbox,
                            );
                        }
                        else {
                            trapCollision = CollisionBlock(block: trap, hitbox: newTrap.hitbox);
                        }
                        add(trapCollision);
                        player.collisionBlocks.add(trapCollision);
                    }
                }
            }
        }
    }
    void _addObjectsLayer() {
        final objectsLayer = level.tileMap.getLayer<ObjectGroup>('Objects Layer');
        if (objectsLayer != null) {
            for (final object in objectsLayer.objects) {
                if (object.class_ == 'Player') {
                    player.setPlayerData(object);
                    add(player);
                }
                if (object.class_ == 'Fruit') add(Fruit(gameObject: object));
                if (object.class_ == 'Potion') add(Potion(item: object));
                if (object.class_ == 'Game Point') add(GamePoint.getGamePoint(object));
            }
        }
    }

    void _addCollisionsLayer() {
        final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');
        if (collisionsLayer != null) {
            for (final collision in collisionsLayer.objects) {
                final collisionBlock = CollisionBlock(
                    block: collision,
                    hitbox: getHitbox([0.0, 0.0, collision.width, collision.height]),
                );
                player.collisionBlocks.add(collisionBlock);
                add(collisionBlock);
            }
        }
    }
}