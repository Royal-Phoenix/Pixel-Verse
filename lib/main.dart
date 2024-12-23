import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_verse/components/utilities.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Flame.device.fullScreen();
    await Flame.device.setLandscape();
    runApp(GameWidget(game: PixelVerse()));
}
