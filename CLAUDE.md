# blackmatter-shell — Claude Orientation

> **★★★ CSE / Knowable Construction.** This repo operates under **Constructive Substrate Engineering** — canonical specification at [`pleme-io/theory/CONSTRUCTIVE-SUBSTRATE-ENGINEERING.md`](https://github.com/pleme-io/theory/blob/main/CONSTRUCTIVE-SUBSTRATE-ENGINEERING.md). The Compounding Directive (operational rules: solve once, load-bearing fixes only, idiom-first, models stay current, direction beats velocity) is in the org-level pleme-io/CLAUDE.md ★★★ section. Read both before non-trivial changes.


One-sentence purpose: curated zsh distribution (`blzsh`) — runnable standalone
via `nix run`, consumable as a home-manager module. Bundles 7 plugins and 35
Rust-based CLI tools with starship prompt.

## Classification

- **Archetype:** `blackmatter-component-custom-package-hm`
- **Flake shape:** **custom** (does NOT go through mkBlackmatterFlake)
- **Reason:** Package + HM + overlay composed with `skim-tab`, `blx`, `bm-guard`,
  `blackmatter-nvim` as direct flake inputs. Stable and idiomatic — not worth
  migrating for uniformity.
- **Option namespace:** `blackmatter.components.shell`

## Where to look

| Intent | File |
|--------|------|
| Package derivation | `package.nix` |
| HM module | `module/default.nix` |
| Plugin registry | `module/plugins/` |
| Tool registry | `module/tools/` |
| Bundled prompt / key bindings | `module/groups/` |
| Tests | `tests/` |

## Constraint

Do **not** alias `find → fd` or `grep → rg` in `.bashrc`; guard with `[[ $- == *i* ]]`.
