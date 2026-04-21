# blackmatter-shell — Claude Orientation

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
