# Gastro-Calm & Herbal Tablets

A Project Zomboid Build 42 mod that adds factory-made Gastro-Calm Tablets and
craftable Crude Herbal Tablets. Both treatments reduce Food Sickness gradually;
they do not cure zombie infection, wound infection, colds, or ordinary damage.

## Repository layout

This repository is ready to upload as a Steam Workshop item:

```text
preview.png
workshop.txt
Contents/
  mods/
    PoisonRelief/
      42/
      common/
```

The installable mod is `Contents/mods/PoisonRelief`. Build 42 metadata lives in
`42/mod.info`, while scripts, Lua, translations, and textures live in `common`.

## Installation

### Steam Workshop

Subscribe to the published Workshop item, enable **Gastro-Calm & Herbal
Tablets** in the Mods menu, and restart the game before testing an existing
save.

### Manual installation

Copy the complete `Contents/mods/PoisonRelief` directory to your local mods
directory:

```text
C:\Users\YOUR_NAME\Zomboid\mods\PoisonRelief
```

Enable the mod in Project Zomboid's Mods menu and restart the game.

## Development and testing

For local development, either copy `Contents/mods/PoisonRelief` into the local
mods directory or create a directory junction to it. Launch Project Zomboid
with the Steam launch option `-debug`, enable the mod, and use the debug Items
List to add:

- `PoisonRelief.GastroCalmTablet`
- `PoisonRelief.CrudeHerbalTablet`

Raise Food Sickness in the player-stat/body-damage debugger, take a tablet, and
advance game time to confirm recovery is gradual. Distribution changes only
affect containers whose loot has not already been generated.

Balance values are defined in
`Contents/mods/PoisonRelief/common/media/lua/shared/PoisonRelief/PoisonRelief_Treatment.lua`.
Loot weights are defined in
`Contents/mods/PoisonRelief/common/media/lua/server/Items/PoisonRelief_Distributions.lua`.

## Workshop upload

1. Open Project Zomboid's Workshop uploader.
2. Select this repository root, which contains `preview.png`, `workshop.txt`,
   and `Contents`.
3. Review the preview, description, tags, and packaged mod before uploading.
4. Keep the Workshop item **unlisted** unless intentionally changing its
   visibility.
5. After the first upload, let the uploader add the assigned Workshop ID; this
   repository deliberately does not contain an invented ID.

Do not upload the source ZIP or development-only temporary files.

## Multiplayer

Medicine use is server-authoritative. The server validates the item, consumes
one dose, advances the treatment, and synchronizes approved state to the client.

Enable `PoisonRelief` on the server and on every connecting client. For a
dedicated server, add:

```ini
Mods=PoisonRelief
```

Once the mod has a real Steam Workshop ID, add that value to `WorkshopItems=`.
Do not place the mod ID (`PoisonRelief`) in `WorkshopItems=`. For multiplayer
testing, join as a non-host client, verify exactly one dose is consumed, then
disconnect and reconnect during treatment to confirm progress persists.

## Gameplay details

Gastro-Calm blister packs appear in medical-clinic drug storage, medical
storage, and rarely in bathroom counters. Crude Herbal Tablets are crafted from
two units of lemongrass with a mortar and pestle. Additional doses may bank up
to 70 points of relief, and the fastest active medicine controls the treatment
rate.
