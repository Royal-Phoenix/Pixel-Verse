import 'dart:io';
import 'package:csv/csv.dart';
import 'package:pixel_verse/components/players/player.dart';
import 'package:pixel_verse/components/utilities.dart';

Future<Map<String, List>> readCSV(String filePath) async {
    final file = File(filePath);
    final contents = await file.readAsString();
    List<List> rows = const CsvToListConverter().convert(contents);
    Map<String, List> data = {};
    for (List row in rows) {
        data['${row.first}'] = row.getRange(1, row.length).toList();
    }
    return data;
}

bool checkCollision(Player player, CollisionBlock block) {
    final RectangleHitbox hitbox = player.hitbox;
    final double playerX = player.position.x + hitbox.x;
    final double playerY = player.position.y + hitbox.y;
    double fixedX = playerX;
    double fixedY = playerY;
    if (player.scale.x < 0) fixedX -= (2 * hitbox.x) + hitbox.width;
    if (block.isPlatform) fixedY += hitbox.height;
    return (
        fixedY < block.y + block.height &&
        playerY + hitbox.height > block.y &&
        fixedX < block.x + block.width &&
        fixedX + hitbox.width > block.x
    );
}

Vector2 imageSize(image, int amount) => Vector2(image.width / amount, image.height / 1);

Hitbox getHitbox(List coords) {
    if (coords.isNotEmpty) {
        return RectangleHitbox(
            position: Vector2(coords[0], coords[1]),
            size: Vector2(coords[2], coords[3]),
        );
    }
    else {
        return CircleHitbox();
    }
}

GameButton getGameButton(String name, Function() onPressed, Vector2 position, Vector2 size) {
    return GameButton(
        name: name,
        onPressed: onPressed,
        position: position,
        size: size,
    );
}

List<double> blockMovement(String type, Vector2 position, double dt, double moveSpeed,
    List<double> direction, var offNeg,  var offPos,  var rangeNeg,  var rangePos) {
    if (type == 'Vertical') {
        position.y += direction[0] * moveSpeed * dt;
        if (position.y <= rangeNeg) {
            position.y = rangeNeg;
            direction[0] *= -1;
        }
        if (position.y >= rangePos) {
            position.y = rangePos;
            direction[0] *= -1;
        }
        return direction;
    }
    else if (type == 'Horizontal') {
        position.x += direction[0] * moveSpeed * dt;
        if (position.x <= rangeNeg) {
            position.x = rangeNeg;
            direction[0] *= -1;
        }
        if (position.x >= rangePos) {
            position.x = rangePos;
            direction[0] *= -1;
        }
        return direction;
    }
    else if (type == 'Clockwise') {
        if (direction[0] == 0) {
            position.y += direction[1] * moveSpeed * dt;
            if (position.y <= rangeNeg[1]) {
                direction = [direction[0]-direction[1], 0];
                position.y = rangeNeg[1];
            }
            if (position.y >= rangePos[1]) {
                direction = [direction[0]-direction[1], 0];
                position.y = rangePos[1];
            }
        }
        else {
            position.x += direction[0] * moveSpeed * dt;
            if (position.x <= rangeNeg[0]) {
                direction = [0, direction[0]-direction[1]];
                position.x = rangeNeg[0];
            }
            else if (position.x >= rangePos[0]) {
                direction = [0, direction[0]-direction[1]];
                position.x = rangePos[0];
            }
        }
        return direction;
    }
    else if (type == 'AntiClockwise') {
        if (direction[0] == 0) {
            position.y += direction[1] * moveSpeed * dt;
            if (position.y <= rangeNeg[1]) {
                direction = [direction[1]-direction[0], 0];
                position.y = rangeNeg[1];
            }
            if (position.y >= rangePos[1]) {
                direction = [direction[1]-direction[0], 0];
                position.y = rangePos[1];
            }
        }
        else {
            position.x += direction[0] * moveSpeed * dt;
            if (position.x <= rangeNeg[0]) {
                direction = [0, direction[1]-direction[0]];
                position.x = rangeNeg[0];
            }
            if (position.x >= rangePos[0]) {
                direction = [0, direction[1]-direction[0]];
                position.x = rangePos[0];
            }
        }
        return direction;
    }
    else { return direction; }
}