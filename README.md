# poc-addon-minecraft

Proof of concept: create a single working Minecraft Bedrock Edition addon -- one custom item with its own texture and behavior -- that can be installed and used in-game.

## Purpose

The Everything Addon website promises customizable Minecraft Bedrock Edition addons. Before investing in the storefront, we need to validate that we can produce the core product. If this works, it becomes the first real item in the catalog.

## Goal

- One custom item with custom texture and behavior
- Packaged as a valid `.mcaddon` file
- Installable and functional in Minecraft Bedrock Edition

## File Structure

```
behavior_pack/
  manifest.json          # Declares the behavior pack (data module) and its dependency on the resource pack
  pack_icon.png          # Icon shown in Minecraft's pack management UI
  items/
    custom_sword.json    # Item definition: identifier, stats, icon reference, menu category

resource_pack/
  manifest.json          # Declares the resource pack (resources module) and its dependency on the behavior pack
  pack_icon.png          # Icon shown in Minecraft's pack management UI
  texts/
    en_US.lang           # Localized display names for custom items
  textures/
    item_texture.json    # Maps texture shortnames to PNG file paths
    items/
      custom_sword.png   # The pixel-art sword texture (16x16)

package.sh               # Bash packaging script (macOS/Linux/Git Bash)
package.ps1              # PowerShell packaging script (Windows)
```

### How pack cross-linking works

Every Bedrock addon has two halves: a **behavior pack** (BP) that defines game logic and an optional **resource pack** (RP) that provides textures, models, and sounds. Each pack has its own `manifest.json` with a unique `header.uuid`.

The two packs reference each other through the `dependencies` array:

- The BP's `dependencies` contains the RP's `header.uuid` (`b3a12422-a3b1-4919-acce-b0a858f90597`).
- The RP's `dependencies` contains the BP's `header.uuid` (`4e9d8788-9f85-40e7-857e-cb4321546d5d`).

When Minecraft applies an addon to a world, it uses these dependencies to ensure both packs are activated together.

### How texture mapping works

The connection from item definition to rendered texture crosses three files:

1. **`behavior_pack/items/custom_sword.json`** -- The `minecraft:icon` component references a shortname: `"default": "custom_sword"`.
2. **`resource_pack/textures/item_texture.json`** -- The `texture_data` object maps that shortname to a file path: `"custom_sword": { "textures": "textures/items/custom_sword" }`. (The `.png` extension is implied.)
3. **`resource_pack/textures/items/custom_sword.png`** -- The actual pixel-art image that Minecraft renders.

The chain is: **item component** (shortname) -> **item_texture.json** (shortname to path) -> **PNG file**.

### How localization works

Minecraft looks up display names using a key derived from the item's identifier. The format is:

```
item.<namespace>:<item_name>.name=<Display Name>
```

For our item with identifier `everything:custom_sword`, the key in `resource_pack/texts/en_US.lang` is:

```
item.everything:custom_sword.name=Custom Sword
```

Without this entry the item would show its raw identifier as the display name.

## Installation (Windows 10/11)

**Prerequisites:** Minecraft Bedrock Edition **version 1.21.0 or later** must be installed and launched at least once (the first launch creates the `com.mojang` folder structure used below).

1. **Clone or download this repository.**

2. **Copy the behavior pack** into the development behavior packs folder:
   ```
   %LOCALAPPDATA%\Packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe\LocalState\games\com.mojang\development_behavior_packs
   ```
   Copy the entire `behavior_pack/` folder so the path ends up as:
   ```
   ...\development_behavior_packs\behavior_pack\manifest.json
   ```

3. **Copy the resource pack** into the development resource packs folder:
   ```
   %LOCALAPPDATA%\Packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe\LocalState\games\com.mojang\development_resource_packs
   ```
   Copy the entire `resource_pack/` folder so the path ends up as:
   ```
   ...\development_resource_packs\resource_pack\manifest.json
   ```

   > **Tip:** If you plan to iterate on the addon, create directory junctions instead of copying so edits in the repo are reflected immediately:
   > ```
   > mklink /J "%LOCALAPPDATA%\...\development_behavior_packs\behavior_pack" "C:\path\to\repo\behavior_pack"
   > mklink /J "%LOCALAPPDATA%\...\development_resource_packs\resource_pack" "C:\path\to\repo\resource_pack"
   > ```
   > Otherwise you will need to re-copy after each change.

4. **Launch Minecraft Bedrock Edition** (from the Microsoft Store / Xbox app).

5. **Create a new world** (or edit an existing one). Turn on **Activate Cheats** (required for the `/give` command). Go to **Add-Ons**, find both "Everything Addon" packs under the available list, and **activate both** of them.

6. **Enter the world** and run:
   ```
   /give @s everything:custom_sword
   ```

## Verification

After running the `/give` command, confirm the following:

- The item appears in your inventory with the display name **"Custom Sword"**.
- The item shows the custom pixel-art sword texture (not a missing-texture placeholder).
- The item renders like a sword when held (hand-equipped, angled in third person).
- The item has a **damage value of 7** and **durability of 500** (visible in the item tooltip or tested by attacking mobs).

## Packaging

To distribute the addon as a single importable file, use the included packaging scripts.

**Bash (macOS / Linux / Git Bash on Windows):** Requires the `zip` command (pre-installed on macOS/Linux; on Windows Git Bash you may need to install it or use the PowerShell script instead).
```bash
./package.sh                    # produces everything-addon.mcaddon
./package.sh my-custom-name     # produces my-custom-name.mcaddon
```

**PowerShell (Windows):**
```powershell
.\package.ps1                              # produces everything-addon.mcaddon
.\package.ps1 -OutputName "my-custom-name" # produces my-custom-name.mcaddon
```

A `.mcaddon` file is just a **zip archive** containing the `behavior_pack/` and `resource_pack/` folders. Minecraft registers the `.mcaddon` extension, so **double-clicking the file on Windows** auto-imports both packs into the game. After importing, the packs appear in the global pack list and can be activated on any world.
