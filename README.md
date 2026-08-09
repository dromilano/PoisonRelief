# Gastro-Calm & Herbal Tablets

![Gastro-Calm & Herbal Tablets](preview.png)

A Project Zomboid Build 42 mod that adds two treatments for Food Sickness:
factory-made **Gastro-Calm Tablets** and craftable **Crude Herbal Tablets**.

Both medicines work gradually. They can give a poisoned survivor a fighting
chance without making dangerous food completely harmless.

## Features

- Factory-made Gastro-Calm blister packs found in medical loot.
- A craftable herbal alternative made from lemongrass.
- Gradual treatment rather than an instant cure.
- Ten doses per Gastro-Calm blister pack.
- Stackable relief, capped at 70 Food Sickness points.
- Single-player and multiplayer support.
- Server-authoritative medicine use in multiplayer.
- No dependencies.

## Treatments

| Treatment | How to obtain | Effect per dose |
| --- | --- | --- |
| **Gastro-Calm Tablets** | Medical loot | Removes up to 35 Food Sickness over 90 in-game minutes |
| **Crude Herbal Tablet** | Crafting | Removes up to 22 Food Sickness over two in-game hours |

Taking another dose can add more relief, but it does not make the active
treatment run faster. When different medicines are active, the fastest one
determines the recovery rate.

> [!IMPORTANT]
> These tablets reduce Food Sickness. They do not cure zombie infection, wound
> infection, colds, or directly restore ordinary health. Because treatment is
> gradual, taking a tablet too late may not save the character.

## Finding Gastro-Calm

Gastro-Calm blister packs may appear in:

- Medical-clinic drug storage.
- Medical storage.
- Bathroom counters, rarely.

Each fresh blister contains ten doses and uses the same remaining-uses mechanic
as vanilla drainable medicines. Loot changes only affect containers whose
contents have not already been generated.

## Crafting the herbal alternative

Use a mortar and pestle with **two units of lemongrass** to make **four Crude
Herbal Tablets**. The mortar and pestle is kept and may take light wear.

Crude Herbal Tablets do not spawn as loot, and Gastro-Calm cannot be crafted.

## Using the tablets

Keep the medicine in the character's main inventory or a carried bag.
Right-click it and choose **Take Stomach Relief Tablet**.

Treatment progress is stored with the character and continues after saving and
loading. In multiplayer, the server validates and consumes each dose before
applying the treatment.

## Compatibility

- **Game version:** Project Zomboid Build 42
- **Single-player:** Supported
- **Multiplayer:** Supported
- **Dependencies:** None
- **Mod ID:** `PoisonRelief`
- **Workshop ID:** To be assigned on publication

Servers and connecting players must all enable the mod.

## Installation

### Steam Workshop

The Workshop release is coming soon. Once published, subscribe to the item,
enable **Gastro-Calm & Herbal Tablets** in the Mods menu, and restart the game.

### Manual installation

Copy the following directory from this repository:

```text
Contents/mods/PoisonRelief
```

Place it at:

```text
C:\Users\YOUR_NAME\Zomboid\mods\PoisonRelief
```

Enable **Gastro-Calm & Herbal Tablets** in the Mods menu and restart the game.

## Feedback and bug reports

Found something strange, survived something you definitely should not have, or
watched a tablet disappear without helping? Open an issue in the
[GitHub issue tracker](https://github.com/dromilano/PoisonRelief/issues) with
the game version, single-player or multiplayer status, and any relevant errors
from `console.txt`.

## Credits

Created by **Dro**.

Preview images created with AI
