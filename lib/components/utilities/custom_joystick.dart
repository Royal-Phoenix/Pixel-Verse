import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:pixel_verse/components/players/player.dart';

class CustomJoystick extends JoystickComponent {
    Player player;
    CustomJoystick({required this.player, super.knob, super.background}) {
        super.priority = 10;
        super.margin = const EdgeInsets.only(right: 32, bottom: 32);
    }
    
    void updateJoystick() {
        switch (direction) {
            case JoystickDirection.left:
            case JoystickDirection.upLeft:
            case JoystickDirection.downLeft:
                player.horizontalMovement = -1;
                break;
            case JoystickDirection.right:
            case JoystickDirection.upRight:
            case JoystickDirection.downRight:
                player.horizontalMovement = 1;
                break;
            default:
                player.horizontalMovement = 0;
                break;
        }
    }
}