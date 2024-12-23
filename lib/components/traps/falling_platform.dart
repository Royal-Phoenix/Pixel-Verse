import 'package:pixel_verse/components/traps.dart';
import 'package:pixel_verse/components/utilities.dart';

class FallingPlatform extends Trap with CollisionCallbacks {
    double standCount = 500;
    double timer = 0;
    bool isSafe = true;
    FallingPlatform({required super.trap});
}