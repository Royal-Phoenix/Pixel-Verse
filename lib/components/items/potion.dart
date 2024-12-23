import 'package:pixel_verse/components/items.dart';
import 'package:pixel_verse/components/players/player.dart';
import 'package:pixel_verse/components/utilities.dart';

class Potion extends Item {
    late double health;
    Potion({required super.item}) {
        name = item.name;
    }

    @override
    void playerCollision(Player player) async {
        if (!isCollected) {
            isCollected = true;
            if (game.playSounds) FlameAudio.play('collect_fruit.wav', volume: game.soundVolume);
            current = states['Collected'];
            await animationTicker?.completed;
            activate(player);
            player.inventory.addItem(name, this);
        }
    }

    void activate(Player player) async {
        final Map<String, dynamic> data = PixelVerse.itemData['Potion'][name];
        double duration = data.containsKey('duration') ? data['duration'] : 0;
        if (data.containsKey('HP')) player.healthBar.updateStatusBar(data['HP'], duration);
        if (data.containsKey('MP')) player.manaBar.updateStatusBar(data['MP'], duration);
        if (data.containsKey('speed')) player.boostSpeed(data['speed'], duration);
        if (data.containsKey('stealth')) {}
        if (data.containsKey('curseLeft')) {}
    }
}
