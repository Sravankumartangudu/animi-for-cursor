# Changelog

## 1.9 — 2026-10-15

- **Menu bar icon fits in.** The menu bar now shows a plain outline of Bolt's head instead of the shrunken colour app icon. Like the other menu-bar icons, macOS shows it black on a light menu bar and white on a dark one.

## 1.8 — 2026-10-15

- **Thumbnails in the Character and Heroes menus.** Every character now has a small picture next to its name, drawn from the same artwork the pet uses. They appear a few seconds after launch.
- **Tidier menu.** Follow Cursor, Size and Appearance now live under one **Settings** submenu with Behavior and App headings. Your saved choices are unchanged.

## 1.7 — 2026-10-15

- **Appearance setting.** Right-click → **Appearance** → System, Light or Dark. It sets the look of Animi's menus; System follows macOS and is the default. The character looks the same in every mode.

## 1.6 — 2026-10-13

- **Lives in Nexus's menu-bar folder.** With Nexus 1.6, Animi's menu also shows in its submenu in Nexus, and picking an item there works the same as from Animi's own menu-bar icon.
  - Turn on **Keep Agents in Nexus** in Nexus to hide the menu-bar icon. **Show Icon in Menu Bar** in Animi's submenu keeps it.
  - If Nexus isn't running, the icon always shows.

## 1.5 — 2026-10-07

- Reports to [Nexus](https://github.com/Sravankumartangudu/nexus): Animi writes a small heartbeat file to
  `~/.nexus/heartbeats/` every 30 seconds, so Nexus shows it as running.

## 1.4 — 2026-10-06

- Menu bar icon: click it to open the same menu as right-clicking the character. This helps when the character is hidden behind a window.
- The character holds still while the menu is open from the menu bar, too.

## 1.3 — 2026-10-06

- Two more fan-art heroes: Doctor Strange (levitates and casts spinning spell circles inside a sparking portal) and Ant-Man (shrinks to ant size with a burst of sparks, sprints, then grows back).

## 1.2 — 2026-10-06

- Six fan-art heroes in the **Heroes** menu, below the originals, each doing their famous move: Spider-Man (web swing), Iron Man (thruster flight), Superman (fist-first flight), Batman (cape glide, a new motion), Hulk (leap and smash) and Captain America (shield throw). These are unofficial fan art; see the trademark notice in the README.
- New app icon: Bolt watching a cursor.
- Fix: the character no longer moves away while its right-click menu is open, so menu items are easy to pick.

## 1.1 — 2026-10-06

- New **Heroes** menu with six original superheroes, each doing a signature move while it follows the cursor: Tether (grapple swing), Cirrus (caped flight), Volta (spinning storm staff), Gust (super-speed sprint), Rumble (leap and smash) and Aegis (boomerang shield throw).
- More natural eyes: the eyes move first and the head turns after them. Each eye aims on its own, so they converge when the cursor is close. When the cursor rests, the eyes glance around now and then.
- Bao's pupils now move inside its eyes.

## 1.0 — 2026-10-06

First public release.

- Six characters: Bolt (robot), Mochi (cat), Boo (ghost), Jelly (slime), Pip (penguin), Bao (panda).
- Watches the cursor anywhere on screen, and travels after it (Follow Cursor can be turned off).
- Drag to move. Click to squish, double-click to cheer. Falls asleep after 30 seconds without mouse movement.
- Right-click menu: Character, Follow Cursor, Size (Tiny / Small / Medium / Large), Say Hi, Quit.
- Remembers its character, size, follow setting and position.
- Runs on macOS 13 or later.
