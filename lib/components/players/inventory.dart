import 'package:flutter/material.dart';
import 'package:pixel_verse/components/players.dart';
import 'package:pixel_verse/components/items.dart';
import 'package:pixel_verse/components/utilities.dart';

class  Inventory {
    Color color = const Color(0xFF2B121E);
    Player player;
    Map<String, Item> items = {};
    int capacity = 0;
    int maxCapacity = 50;
    SpriteComponent inventory = SpriteComponent(
        position: Vector2(64, 36),
        size: Vector2(512, 296),
        priority: 10,
    );
    Inventory(this.player);

    void loadInventory() {
        inventory.sprite = Sprite(player.game.images.fromCache('Menu/Inventory/Background.png'));
        inventory.add(SpriteComponent(
            sprite: Sprite(player.game.images.fromCache('Menu/Inventory/NavBar.png')),
            size: Vector2(512, 24),
            priority: 1,
        )..add(getGameButton('Close', () {
                player.game.gameWorld.remove(inventory);
                player.inventoryOpen = false;
            }, Vector2(485, 4), Vector2(15, 16)
        )));
        for (int i=0; i < 5; i++) {
            for (int j=0; j < 10; j++) {
                inventory.add(SpriteComponent(
                    sprite: Sprite(player.game.images.fromCache('Menu/Inventory/Block.png')),
                    position: Vector2(29 + j * 46, 48 + i * 46),
                    priority: 1,
                ));
            }
        }
    }

    void addItem(String name, Item item)  {
        if (capacity < maxCapacity) {
            if (!items.containsKey(item.name)) {
                items[item.name] = item;
                double rowIndex = 33 + capacity % 10 * 46;
                double colIndex = 52 + (capacity / 10).floorToDouble() * 46;
                inventory.add(item);
                item.position = Vector2(rowIndex, colIndex);
                item.priority = 10;
                capacity++;
            }
            else {
                item.removeFromParent();
            }
            items[item.name]?.count++;
        }
        else {
            item.removeFromParent();
        }
    }
    void tradeItem(item) {}
    void openInventory() {
        for (MapEntry<String, Item> entry in items.entries) {
            entry.value.current = entry.value.states[entry.value.name];
        }
        player.game.gameWorld.add(inventory);
    }
}