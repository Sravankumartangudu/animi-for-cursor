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
2. Use the shared element ids so the engine can animate it: `root`, `head`, `face`, `eyesOpen` with `eyeL`/`eyeR` (centres in `data-x`/`data-y`), `eyesHappy`, `eyesSleep`, `eyesWow`, `m_smile`, `m_grin`, `m_o`, `blushL`, `blushR`.
3. Set `motion` to `fly`, `hop`, `waddle` or `squish`. Put any character-specific animation (tails, ears and so on) in `update(t, S)`.
4. Add the character to the `characters` list in `main.swift`, and to `gallery.html`.
5. Add it to the Characters table in `README.md` and note it in `CHANGELOG.md`.

Please only contribute artwork you created yourself. Don't add copyrighted or trademarked characters.

## License

By contributing, you agree that your contributions are licensed under the [MIT License](LICENSE).
