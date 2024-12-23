import 'package:pixel_verse/components/objects.dart';
import 'package:pixel_verse/components/players/player.dart';
import 'package:pixel_verse/components/utilities.dart';

class Checkpoint extends GamePoint {
    Checkpoint({required super.gameObject});

    @override
    void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
        if (other is Player) _reachedCheckpoint();
        super.onCollisionStart(intersectionPoints, other);
    }

    void _reachedCheckpoint() async {
        current = states['Active'];
        await animationTicker?.completed;
        current = states['Passive'];
    }
}