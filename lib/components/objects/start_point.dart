import 'package:pixel_verse/components/objects.dart';

enum StartPointState { idle, active }

class StartPoint extends GamePoint {
    StartPoint({required super.gameObject});
    String path = 'Game Point/Start Point';
}