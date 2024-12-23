import 'package:pixel_verse/components/monsters.dart';

class Ghost extends Monster with PassiveMovement {
    Ghost({required super.monster});
    bool isVisible = true;
    double visibleTime = 200;
    double timer = 0;

    @override
    void update(double dt) {
        if (isAlive) {
            _updateState();
            movement(dt);
        }
        super.update(dt);
    }

    void _updateState() {
        if (isVisible) {
            if (timer++ > visibleTime) isVisible = false;
            current = timer < 15 ? states['Appear'] : states['Idle'];
        }
        else {
            if (timer-- < 0) isVisible = true;
            if (timer > 185) current = states['Disappear'];
        }
        if ((moveDirection > 0 && scale.x > 0) || (moveDirection < 0 && scale.x < 0)) {
            flipHorizontallyAroundCenter();
        }
    }
}