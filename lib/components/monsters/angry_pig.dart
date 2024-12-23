import 'package:pixel_verse/components/monsters.dart';

class AngryPig extends Monster with PassiveMovement {
    AngryPig({required super.monster});

    @override
    void update(double dt) {
        if (isAlive) {
            _updateState();
            movement(dt);
        }
        super.update(dt);
    }

    void _updateState() {
        current = states[collideState];
        if ((moveDirection > 0 && scale.x > 0) || (moveDirection < 0 && scale.x < 0)) {
            flipHorizontallyAroundCenter();
        }
    }
}