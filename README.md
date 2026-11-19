# Brainrot Bay — roblox-brainrot-01

A 3D brainrot game for make.fun's "Make the best AI Roblox brainrot game" bounty (roblox-brainrot-01): a tropical
night-market bay where absurd brainrots ride the Brainrot Belt from the dock. Buy one with Cash, walk it home to
your base plot, and it earns dollars every second. Climb the rarity ladder from Sir Quacksalot ($50, $2/s) to King
Kebab ($300,000, $8,000/s), chase Gold / Diamond / Rainbow / Lava mutations, lock your base against thieves, and
run home when the tsunami warning sounds. Rebirth at $50,000 earned for a permanent +50% income multiplier.

- `main.ts` (Node 22, standard library only) hands the game in: it copies `game.rbxl`, `src/`, `screenshots/` and
  `PLAY.json` to `/output`, leaving out every name that starts with a dot (such as `.gitkeep` or `.DS_Store`, which
  fail an entry), and writes `/output/dossier.json` with `vendor/makefun-roblox.ts`, the kit's copy, unchanged.
  It also fails loudly when `game.rbxl` is missing or empty, instead of handing in a broken entry.
  `icon-512.png` at the root is the game's Roblox icon source (uploaded on the Creator Dashboard); it is kept
  out of `screenshots/` because the dossier caps that folder at 4 files.
- `game.rbxl` is the place Rojo builds from `src/` and `default.project.json`; `game-v4.rbxl` is the same
  v4 build kept beside it; `screenshots/` holds four captures of it; `PLAY.json` names the published place.
  v4 adds the Mythic log-knocker Tung Tung Sahur ($180,000, $4,000/s) to the cast and a green "+$X" income
  popup under the Cash panel on every income tick, so the money is seen ticking up.
- v5 adds a "Next:" line inside the Cash panel naming the cheapest brainrot the player cannot afford yet
  (the savings goal / next tier), moves the base line and the income popups down to clear it, and guards
  `game.rbxl` at the 32 MiB gate cap in `main.ts`.
- One of your screenshots is also the game's first thumbnail on Roblox: the same picture, uploaded on the Creator
  Dashboard with the game's icon.
- `src/shared/BrainrotConfig.luau` holds the whole cast, prices, mutations and tuning; `src/shared/BrainrotModels.luau`
  builds every brainrot as blocky Parts; the server scripts run the belt, the bases and income, the shop, the
  tsunami and the shared state; `src/client/BrainrotClient.client.luau` builds the HUD, the shop UI and the camera
  intro.
- `TOUR.json` names one step per screenshot.

Run it as the grader does, writing `out/` in place of `/output`:

    mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts

The rules are on the bounty's page (/bounty/roblox-brainrot-01) and in the kit's RULES.txt,
which gives every command in order (Before you submit, then Enter).
