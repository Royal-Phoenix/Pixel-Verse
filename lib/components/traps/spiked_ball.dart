import 'dart:math';
import 'package:pixel_verse/components/traps/trap.dart';

enum SpikedBallState { idle }

class SpikedBall extends Trap {
    late double swingAngle;
    late double swingLimit;
    late double swingRadius;
    late double swingDirection;
    late List<double> pivotPos;
    late bool limitedSwing;
    SpikedBall({required super.trap}) {
        swingAngle = trap.properties.getValue('angle');
        swingLimit = trap.properties.getValue('limit');
        limitedSwing = trap.properties.getValue('limited');
        swingRadius = trap.properties.getValue('radius');
        swingDirection = trap.properties.getValue('start');
        pivotPos = [trap.properties.getValue('centerX'), trap.properties.getValue('centerY')];
    }

    @override
    void update(double dt) {
        _spikedBallMovement(dt);
        super.update(dt);
    }

    void _spikedBallMovement(double dt) {
        if (limitedSwing) {
            position.x = swingRadius * sin(pi * swingAngle / 180) + pivotPos[0] - 32;
            position.y = swingRadius * cos(pi * swingAngle / 180) + pivotPos[1] - 48;
            swingAngle += swingDirection * speed * dt;
            if (swingAngle <= -swingLimit) {
                swingDirection *= -1;
                swingAngle = -swingLimit;
            }
            if (swingAngle >= swingLimit) {
                swingDirection *= -1;
                swingAngle = swingLimit;
            }
        }
        else {}
    }
}