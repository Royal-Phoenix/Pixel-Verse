import 'package:pixel_verse/components/monsters.dart';

class Mushroom extends Monster with ActiveMovement {
    Mushroom({required super.monster});

    @override
    void update(double dt) {
        if (isAlive) {
            _updateState();
            movement(dt);
        }
        super.update(dt);
    }

    void _updateState() {
        current = (velocity.x != 0) ? states['Run'] : states['Idle'];
        if ((moveDirection > 0 && scale.x > 0) || (moveDirection < 0 && scale.x < 0)) {
            flipHorizontallyAroundCenter();
        }
    }
}