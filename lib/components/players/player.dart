import 'dart:async';
import 'package:flutter/services.dart';
import 'package:pixel_verse/components/items.dart';
import 'package:pixel_verse/components/players.dart';
import 'package:pixel_verse/components/traps.dart';
import 'package:pixel_verse/components/monsters.dart';
import 'package:pixel_verse/components/objects.dart';
import 'package:pixel_verse/components/utilities.dart';

enum PlayerState { idle, run, jump, fall, fly, shoot, doubleJump, wallSlide, hit, spawn, teleport }

class Player extends SpriteAnimationGroupComponent
with HasGameRef<PixelVerse>, KeyboardHandler, CollisionCallbacks {
    late final double _gravity;
    late double _thrust;
    late final double _drag;
    late double _speed;
    late double hitPoints;
    static const double fixedDeltaTime = 1 / 60;
    late double _direction;
    late String _name;
    double accumulatedTime = 0;
    double horizontalMovement = 0;
    double teleportDistance = 100;
    int cursesLeft = 0;
    Vector2 startPosition = Vector2.zero();
    Vector2 velocity = Vector2.zero();
    bool isOnGround = false;
    bool isJumping = false;
    bool isDoubleJumping = false;
    bool isFlying = false;
    bool isTeleporting = false;
    bool isVisible = true;
    bool isShooting = false;
    bool inventoryOpen = false;
    bool isHit = false;
    bool reachedCheckpoint = false;
    List<CollisionBlock> collisionBlocks = [];
    final RectangleHitbox hitbox = getHitbox([6.0, 6.0, 20.0, 25.0]) as RectangleHitbox;
    final StatusBar healthBar = StatusBar(name: 'Health Bar');
    final StatusBar manaBar = StatusBar(name: 'Mana Bar');
    late Inventory inventory;
    Player() {
        inventory = Inventory(this);
    }

    @override
    FutureOr<void> onLoad() {
        // debugMode = true;
        _loadAllAnimations();
        inventory.loadInventory();
        startPosition = Vector2(position.x, position.y);
        if (_direction == -1) flipHorizontallyAroundCenter();
        addAll([hitbox, healthBar, manaBar]);
        return super.onLoad();
    }

    @override
    void update(double dt) {
        accumulatedTime += dt;
        while (accumulatedTime >= fixedDeltaTime) {
            if (isShooting) _playerShoot();
            if (isFlying) _playerFly();
            if (!(isHit || reachedCheckpoint || isFlying || isShooting || inventoryOpen)) {
                _updatePlayerState();
                _updatePlayerMovement(fixedDeltaTime);
                _checkHorizontalCollisions();
                _applyGravity(fixedDeltaTime);
                _checkVerticalCollisions();
            }
            accumulatedTime -= fixedDeltaTime;
        }
        super.update(dt);
    }

    @override
    bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
        horizontalMovement = 0;
        final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.arrowLeft);
        final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.arrowRight);
        horizontalMovement += isLeftKeyPressed ? -1 : 0;
        horizontalMovement += isRightKeyPressed ? 1 : 0;
        isJumping = keysPressed.contains(LogicalKeyboardKey.arrowUp);
        isFlying = keysPressed.contains(LogicalKeyboardKey.shiftLeft);
        isShooting = keysPressed.contains(LogicalKeyboardKey.controlLeft);
        if (!inventoryOpen && keysPressed.contains(LogicalKeyboardKey.keyI)) {
            inventoryOpen = true;
            inventory.openInventory();
        }
        return super.onKeyEvent(event, keysPressed);
    }

    @override
    void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
        if (!reachedCheckpoint && current != PlayerState.spawn && !inventoryOpen && !isTeleporting) {
            if (other is Item && !other.isCollected) other.playerCollision(this);
            if (other is Fruit) other.playerCollision(this);
            if (other is Saw) other.playerCollision(this);
            if (other is Spikes) other.playerCollision(this);
            if (other is SpikeHead) other.playerCollision(this);
            if (other is SpikedBall) other.playerCollision(this);
            if (other is AngryPig) other.playerCollision();
            if (other is Chicken) other.playerCollision();
            if (other is Rhino) other.playerCollision();
            if (other is Mushroom) other.playerCollision();
            if (other is Ghost && other.isVisible) other.playerCollision();
            if (other is Checkpoint) _reachedCheckpoint();
        }
        super.onCollisionStart(intersectionPoints, other);
    }

    void _loadAllAnimations() {
        animations = {
            PlayerState.idle: _playerAnimation('Idle', 11),
            PlayerState.run: _playerAnimation('Run', 12),
            PlayerState.jump: _playerAnimation('Jump', 1),
            PlayerState.fall: _playerAnimation('Fall', 1),
            PlayerState.fly: _playerAnimation('Fly', 1),
            PlayerState.shoot: _playerAnimation('Shoot', 5)..loop = false,
            PlayerState.doubleJump: _playerAnimation('Double Jump', 6),
            PlayerState.wallSlide: _playerAnimation('Wall Slide', 5),
            PlayerState.hit: _playerAnimation('Hit', 7)..loop = false,
            PlayerState.spawn: _playerAnimation('Spawn', 7, special: true)..loop = false,
            PlayerState.teleport: _playerAnimation('Teleport', 7, special: true)..loop = false,
        };
        current = PlayerState.idle;
    }

    SpriteAnimation _playerAnimation(String state, int amount, {bool special = false}) => game.gameAnimation('Player/${special ? '' : ('$_name/')}$state.png', amount, 0.05);

    void setPlayerData(TiledObject player) {
        _name = player.name;
        position = Vector2(player.x, player.y);
        final data = PixelVerse.playerData[_name];
        _speed = data['speed'];
        healthBar.maxPoints = healthBar.points = data['HP'];
        healthBar.updateStatusBar(0, 1);
        manaBar.maxPoints = manaBar.points = data['MP'];
        manaBar.updateStatusBar(0, 1);
        _thrust = data['thrust'];
        _gravity = data['gravity'];
        _drag = data['drag'];
        _direction = player.properties.getValue('direction');
    }

    void _updatePlayerState() {
        if (!isTeleporting) {
            PlayerState playerState = PlayerState.idle;
            if (changedDirection()) {
                flipHorizontallyAroundCenter();
                healthBar.flipHorizontallyAroundCenter();
                manaBar.flipHorizontallyAroundCenter();
            }
            if (velocity.x != 0) playerState = PlayerState.run;
            if (velocity.y > 0) playerState = PlayerState.fall;
            if (velocity.y < 0) playerState = PlayerState.jump;
            current = playerState;
        }
    }

    bool changedDirection() => velocity.x < 0 && scale.x > 0 || velocity.x > 0 && scale.x < 0;

    void _updatePlayerMovement(double dt) {
        if (isJumping && isOnGround) _playerJump(dt);
        velocity.x = horizontalMovement * _speed;
        position.x += velocity.x * dt;
    }

    void boostSpeed(double speed, double duration) async {
        _speed += speed;
        await Future.delayed(Duration(seconds: duration.toInt()));
        _speed -= speed;
    }

    void _playerJump(double dt) {
        if (game.playSounds) FlameAudio.play('jump.wav', volume: game.soundVolume);
        velocity.y = -_thrust;
        position.y += velocity.y * dt;
        isOnGround = false;
        isJumping = false;
    }

    void _playerShoot() async {
        if (game.playSounds) FlameAudio.play('shoot.wav', volume: game.soundVolume);
        current = PlayerState.shoot;
        await animationTicker?.completed;
        animationTicker?.reset();
        isShooting = false;
    }

    void _playerFly() async {
        if (game.playSounds) FlameAudio.play('shoot.wav', volume: game.soundVolume);
        current = PlayerState.fly;
        await animationTicker?.completed;
        animationTicker?.reset();
        isFlying = false;
    }

    void handleMouseClick(Vector2 coord) async {
        if (16 < coord.x && coord.x < 624 && 16 < coord.y && coord.y < 352) _playerTeleport(coord);
    }

    void _playerTeleport(Vector2 coord) async {
        if (position.distanceTo(coord) <= teleportDistance) {
            if (game.playSounds) FlameAudio.play('hit.wav', volume: game.soundVolume);
            isTeleporting = true;
            current = PlayerState.teleport;
            await animationTicker?.completed;
            position = coord;
            current = PlayerState.spawn;
            await animationTicker?.completed;
            isTeleporting = false;
        }
    }

    void _checkHorizontalCollisions() {
        for (final block in collisionBlocks) {
            if (!block.isPlatform) {
                if (checkCollision(this, block)) {
                    double v = velocity.x;
                    if (velocity.x != 0) {
                        velocity.x = 0;
                        position.x = block.x + (v < 0 ? block.width : 0) + (v < 0 ? 1 : -1) * (hitbox.x + hitbox.width);
                        break;
                    }
                }
            }
        }
    }

    void _applyGravity(double dt) {
        velocity.y += _gravity;
        velocity.y = velocity.y.clamp(-_thrust, _drag);
        position.y += velocity.y * dt;
    }

    void _checkVerticalCollisions() {
        for (final block in collisionBlocks) {
            if (block.isPlatform) {
                if (checkCollision(this, block)) {
                    if (velocity.y > 0) {
                        velocity.y = 0;
                        position.y = block.y - (hitbox.y + hitbox.height);
                        isOnGround = true;
                        break;
                    }
                }
            }
            else {
                if (checkCollision(this, block)) {
                    double v = velocity.y;
                    if (velocity.y != 0) {
                        velocity.y = 0;
                        position.y =
                            block.y + (v < 0 ? block.height : -hitbox.height) - hitbox.y;
                        if (v > 0) isOnGround = true;
                        break;
                    }
                }
            }
        }
    }

    void _respawn() async {
        if (game.playSounds) FlameAudio.play('hit.wav', volume: game.soundVolume);
        isHit = true;
        current = PlayerState.hit;
        await animationTicker?.completed;
        animationTicker?.reset();
        position = startPosition;
        current = PlayerState.spawn;
        await animationTicker?.completed;
        animationTicker?.reset();
        velocity = Vector2.zero();
        position = startPosition;
        if (scale.x != _direction) {
            flipHorizontallyAroundCenter();
            if (healthBar.scale.x == -_direction) {
                healthBar.flipHorizontallyAroundCenter();
                manaBar.flipHorizontallyAroundCenter();
            }
        }
        _updatePlayerState();
        Future.delayed(const Duration(milliseconds: 400), () => isHit = false);
    }

    void _reachedCheckpoint() async {
        reachedCheckpoint = true;
        if (game.playSounds) FlameAudio.play('disappear.wav', volume: game.soundVolume);
        current = PlayerState.teleport;
        await animationTicker?.completed;
        animationTicker?.reset();
        reachedCheckpoint = false;
        removeFromParent();
        collisionBlocks.clear();
        Future.delayed(const Duration(seconds: 3), () => game.loadNextLevel());
    }

    void endCollision() => _respawn();
}
