// Brainrot Bay — a roblox-brainrot-01 entry (Node 22, standard library only).
// The game is this directory's Rojo project, built into game.rbxl with
// `rojo build default.project.json --output game.rbxl`, and the program
// hands it in. It copies game.rbxl, src/, screenshots/ and PLAY.json from
// beside this file to /output and writes /output/dossier.json, the summary
// the judge reads, with the vendored make.fun library.
//
// The game: a tropical night-market bay where absurd brainrots ride the
// Brainrot Belt from the dock. Buy one with Cash, walk it home to your
// base plot, and it earns dollars every second. Climb the rarity ladder
// from Sir Quacksalot to King Kebab, chase Gold / Diamond / Rainbow /
// Lava mutations, lock your base against thieves, and run home when the
// tsunami warning sounds. Rebirth at $50,000 earned for a permanent
// income multiplier. Four screenshots show the bay, a buy, a full base
// and the tsunami warning; PLAY.json names the published place once the
// owner publishes it from Roblox Studio.
//
// Every name under /output starts with a letter, a digit or _ and holds only letters, digits, . _ and -: the
// grader fails an entry whose output holds any other, so a file such as .gitkeep or .DS_Store copied in fails it.
// So src/ and screenshots/ are copied without any name that starts with a dot, at any depth.
//
// Outside the grader's container, MAKEFUN_OUTPUT_DIR stands in for /output:
//   mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts

import { copyFileSync, cpSync, existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';

const here = fileURLToPath(new URL('.', import.meta.url));
const out = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

/** cpSync's filter: leave out every file and directory whose name starts with a dot (.gitkeep, .DS_Store, .git). */
const notDotted = (path: string): boolean => !basename(path).startsWith('.');

copyFileSync(join(here, 'game.rbxl'), join(out, 'game.rbxl'));
copyFileSync(join(here, 'PLAY.json'), join(out, 'PLAY.json'));
cpSync(join(here, 'src'), join(out, 'src'), { recursive: true, filter: notDotted });
mkdirSync(join(out, 'screenshots'), { recursive: true });
if (existsSync(join(here, 'screenshots'))) cpSync(join(here, 'screenshots'), join(out, 'screenshots'), { recursive: true, filter: notDotted });

// The scorer's own caps (reference/gate.json): only text_max_bytes shapes the bytes; the others refuse an entry the
// scorer would refuse (more than 4 screenshots or one over 256 KiB; a place of more than 500000 instances, whose
// scripts' sources come to over 8 MiB or whose scripts' paths come to over 1048576 characters, in all).
const dossierBytes = buildDossier(out, { text_max_bytes: 65536, screenshots: { max: 4, max_bytes: 262144 }, max_instances: 500000, scripts_max_source_bytes: 8388608, scripts_max_path_chars: 1048576 });
// The gate refuses a dossier over 1.5 MiB (contracts/dossier.ts DOSSIER_MAX_BYTES is 4 MiB, but the gate's
// dossier_matches row caps it at 1.5 MiB): fail loudly here rather than handing in an entry the scorer refuses.
if (dossierBytes.length > 1572864) throw new Error(`dossier.json is ${dossierBytes.length} bytes, over the 1.5 MiB gate cap`);
writeFileSync(join(out, 'dossier.json'), dossierBytes);
