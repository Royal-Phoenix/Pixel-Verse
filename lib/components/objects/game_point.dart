import 'package:pixel_verse/components/objects.dart';
import 'package:pixel_verse/components/utilities.dart';

class GamePoint extends GameObject {
    GamePoint({required super.gameObject});

    factory GamePoint.getGamePoint(TiledObject gameObject) {
        return switch (gameObject.name) {
            'Start Point' => StartPoint(gameObject: gameObject),
            'End Point' => EndPoint(gameObject: gameObject),
            'Check Point' => Checkpoint(gameObject: gameObject),
            _ => GamePoint(gameObject: gameObject)
        };
    }
}