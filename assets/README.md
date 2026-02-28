# assets/

This folder contains **raw, imported media** used by the game. Nothing in here should contain game logic.

Recommended structure:
- `visual/` — sprites, textures, UI images, icons, VFX textures (particles)
- `audio/` — music, SFX, UI sounds
- `fonts/` — font files
- `shaders/` — shader files (idk ob wirs brauchen)

Notes:
- Keep naming consistent and descriptive (e.g. `ui_button_primary.png`, `sfx_hit_01.ogg`).
- Avoid putting `.tscn` or `.gd` here, those belong in `scenes/` and `scripts/`.
