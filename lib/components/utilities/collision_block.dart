import 'dart:async';
import 'package:pixel_verse/components/utilities.dart';

class CollisionBlock extends PositionComponent {
    late final bool isPlatform;
    late final double moveSpeed;
    late final String type;
    late final dynamic offNeg;
    late final dynamic offPos;
    late final dynamic rangeNeg;
    late final dynamic rangePos;
    late List<double> direction;
    late RectangleHitbox hitbox;
    bool isTrap = false;
    CollisionBlock({required TiledObject block, required Hitbox hitbox}) {
        setup(block, hitbox); }
    CollisionBlock.linear({required TiledObject block, required this.moveSpeed, required Hitbox hitbox}) {
        isTrap = true;
        setup(block, hitbox);
        type = block.properties.getValue('type');
        offNeg = block.properties.getValue('offNeg');
        offPos = block.properties.getValue('offPos');
        direction = [block.properties.getValue('start')];
    }
    CollisionBlock.spiral({required TiledObject block, required this.moveSpeed, required Hitbox hitbox}) {
        isTrap = true;
        setup(block, hitbox);
        type = block.properties.getValue('type');
        offNeg = [block.properties.getValue('offNegX'), block.properties.getValue('offNegY')];
        offPos = [block.properties.getValue('offPosX'), block.properties.getValue('offPosY')];
        direction = [block.properties.getValue('startX'), block.properties.getValue('startY')];
    }

    @override
    FutureOr<void> onLoad() {
        // debugMode = true;
        add(hitbox as Component);
        if (isTrap) {
            if (['Vertical', 'Horizontal'].contains(type)) {
                double fallingPlatformPosition = type == 'Vertical' ? position.y : position.x;
                rangeNeg = fallingPlatformPosition - offNeg * tileSize;
                rangePos = fallingPlatformPosition + offPos * tileSize;
            }
            else {
                rangeNeg = [position.x - offNeg[0] * tileSize, position.y - offNeg[1] * tileSize];
                rangePos = [position.x + offPos[0] * tileSize, position.y + offPos[1] * tileSize];
            }
        }
        return super.onLoad();
    }

    @override
    void update(double dt) {
        if (isTrap) {
            direction = blockMovement(type, position, dt, moveSpeed, direction, offNeg, offPos, rangeNeg, rangePos);
        }
        super.update(dt);
    }

    void setup(TiledObject block, Hitbox hitbox) {
        this.hitbox = hitbox as RectangleHitbox;
        super.position = Vector2(block.x + this.hitbox.x, block.y + this.hitbox.y);
        super.size = Vector2(block.width, block.height);
        isPlatform = block.class_.contains('Platform') || isTrap;
    }
}