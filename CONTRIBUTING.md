# Contributing

Thanks for wanting to help! New characters, bug fixes and ideas are all welcome.

## Reporting a bug or asking for a feature

Open an [issue](https://github.com/Sravankumartangudu/animi-for-cursor/issues) and include:

- your macOS version (Apple menu → About This Mac),
- what you did, what you expected, and what happened instead,
- a screenshot or screen recording if it's something visual.

## Making a change

1. Fork the repo and create a branch: `git checkout -b my-change`.
2. Make your change, then build and try it:
   ```sh
   ./build.sh && open Animi.app
   ```
3. For character or animation changes, also open `gallery.html` in a browser to check every character still looks right.
4. Commit with a short, clear message and open a pull request describing what changed and why. Add a screenshot for visual changes.

## Adding a character

1. Add an entry to `CHARS` in `animi.html`. Copy an existing character with a similar shape as a starting point.
2. Use the shared element ids so the engine can animate it: `root`, `head`, `face`, `eyesOpen` with `eyeL`/`eyeR` (centres in `data-x`/`data-y`), `eyesHappy`, `eyesSleep`, `eyesWow`, `m_smile`, `m_grin`, `m_o`, `blushL`, `blushR`. If the eyes have a white with a pupil, wrap the pupil in `pupilL`/`pupilR` so only the pupil moves.
3. Set `motion` to `fly`, `hop`, `waddle`, `squish`, `swing`, `soar`, `glide`, `dash` or `leap`. Put any character-specific animation (tails, capes, props and so on) in `update(t, S)`. `S.m` goes from 0 to 1 while the character is travelling, which is the place for signature moves.
4. Add the character to the `characters` or `heroes` list in `main.swift`, and to `gallery.html`. To preview a character mid-move in a browser, open `animi.html#<key>:move`.
5. Add it to the Characters table in `README.md` and note it in `CHANGELOG.md`.

Please only contribute artwork you created yourself. The fan-art heroes are a curated exception, kept as unofficial, non-commercial fan art with a trademark notice in the README. Please don't add more characters that belong to someone else (from comics, films, games and so on). Original characters with generic powers like flying, swinging or super-speed are always welcome.

## License

By contributing, you agree that your contributions are licensed under the [MIT License](LICENSE).
