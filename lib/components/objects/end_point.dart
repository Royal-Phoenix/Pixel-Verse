import 'package:pixel_verse/components/objects.dart';

enum EndPointState { idle, active }

class EndPoint extends GamePoint {
    EndPoint({required super.gameObject});
    String path = 'Game Point/End Point';
}