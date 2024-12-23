import 'package:pixel_verse/components/objects.dart';
import 'package:pixel_verse/components/players/player.dart';
import 'package:pixel_verse/components/utilities.dart';

class Fruit extends GameObject {
    late String name;
    late double hitPoints;
    late final double maxHitPoints;
    late double manaPoints;
    late final double maxManaPoints;
    late final double effectDuration;
    late final double xp;
    late final double gold;
    Fruit({required super.gameObject}) {
        name = gameObject.name;
        final data = PixelVerse.objectData['Fruit'][name];
        final commonData = PixelVerse.objectData['Fruit']['common'];
        hitPoints = data.containsKey('effects') ? data['effects']['HP'] : commonData['effects']['HP'];
        manaPoints = data.containsKey('effects') ? data['effects']['MP'] : commonData['effects']['MP'];
        gold = data.containsKey('effects') ? data['effects']['gold'] : commonData['effects']['gold'];
        xp = data.containsKey('effects') ? data['effects']['XP'] : commonData['effects']['XP'];
        effectDuration = data.containsKey('effects') ? data['effects']['duration'] : commonData['effects']['duration'];
    }

    void playerCollision(Player player) async {
        if (game.playSounds) FlameAudio.play('collect_fruit.wav', volume: game.soundVolume);
        player.healthBar.updateStatusBar(hitPoints, effectDuration);
        player.manaBar.updateStatusBar(manaPoints, effectDuration);
        current = states['Collected'];
        await animationTicker?.completed;
        removeFromParent();
    }

}