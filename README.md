# Gastro-Calm & Herbal Tablets — Project Zomboid Build 42

Adds two treatments for food poisoning with distinct availability and strength.

## Treatments

| Item | Source | Effect |
| --- | --- | --- |
| Gastro-Calm Tablets | Medical loot | Ten-dose blister; each dose removes up to 35 Food Sickness over 90 in-game minutes |
| Crude Herbal Tablet | Crafted | Removes up to 22 Food Sickness over two in-game hours |

Additional doses add relief without slowing the active treatment rate. The
fastest active medicine determines that rate, and at most 70 points of relief
can be banked.
Neither tablet changes zombie infection, wound infection, colds, or ordinary
health directly. Treatment progress is stored in character mod data and
survives saving and loading.

## Multiplayer

Pill use is server-authoritative in multiplayer. The client requests a dose;
the server verifies the exact item ID and type in that player's carried
inventory, consumes one dose, starts the treatment, and returns the approved
treatment state to that client. The server and client then advance the same
recovery curve, so the server retains persistent state while the local sickness
moodle responds immediately.

Enable the mod on the server and every connecting client. For a dedicated
server, add `PoisonRelief` to the server's `Mods=` setting. If the mod is later
published to Steam Workshop, also add its Workshop item ID to `WorkshopItems=`.
Tablets must be in the player's main inventory or a carried bag before the
**Take Stomach Relief Tablet** option appears.

## Loot

Gastro-Calm blister packs may appear in medical-clinic drug storage, medical
storage, and rarely in bathroom counters. Each fresh blister contains ten
doses, using the same remaining-uses mechanic as vanilla drainable medicines.
Crude Herbal Tablets do not spawn as loot.
Distribution changes affect unexplored containers; containers that have already
generated their contents will not be rerolled.

## Crafting

Use a mortar and pestle with two units of lemongrass to make four Crude Herbal
Tablets. The mortar and pestle is kept and may take light wear. Gastro-Calm
cannot be crafted.

## Installation

1. Extract the `PoisonRelief` folder into:
   `C:\Users\YOUR_NAME\Zomboid\mods\`
2. Enable **Gastro-Calm & Herbal Tablets** in the Mods menu.
3. Restart the game before testing an existing save.

## Testing

Launch Project Zomboid with the Steam launch option `-debug`, enable the mod,
load a test save, and use the debug Items List to add either item:

`PoisonRelief.GastroCalmTablet` (one ten-dose blister)

`PoisonRelief.CrudeHerbalTablet`

Raise Food Sickness in the player-stat/body-damage debugger, right-click a
tablet, and choose **Take Stomach Relief Tablet**. Advance game time and confirm
that Food Sickness falls gradually rather than instantly.

For multiplayer, repeat the test as a non-host client and confirm that exactly
one tablet or blister dose is consumed. Disconnect during an active treatment,
reconnect, and confirm that the remaining treatment continues. Also verify that
another player cannot trigger or consume the first player's tablets.

## Balance constants

Edit `common/media/lua/shared/PoisonRelief/PoisonRelief_Treatment.lua`. Each
entry in `TREATMENTS` defines its `relief` and `hours`; `MAX_BANKED_RELIEF`
limits stacked doses.

## Build note

This prototype targets the current Build 42 versioned mod layout and its
`craftRecipe` syntax. Build 42 is actively changing, so if a patch renames a
vanilla ingredient or distribution, check `console.txt` and the corresponding
vanilla scripts from your installed build.
