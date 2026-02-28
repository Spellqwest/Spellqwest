# scripts/

This folder contains all (GDScript) code for gameplay, UI logic, and systems.

High-level structure:
- `autoload/` — singleton scripts registered in Project Settings (global state/services)
- `app/` — boot/routing/state management (switching screens, run lifecycle)
- `ui/` — UI scripts grouped by context (menu/map/combat) and widgets
- `map/` — map generation, event resolution, rewards, runtime map logic
- `combat/` — typing system, spells, AI, combat rules, spawners, rewards
- `inventory/` — inventory model + rules + UI presenters (shared across map/combat)
- `_shared/` — utilities, constants, reusable helpers (no feature-specific logic)

Guidelines:
- Mirror `scenes/` structure where it helps navigation (e.g. `scenes/combat/...` ↔ `scripts/combat/...`).
- Keep global state in autoloads only (e.g. Inventory, SaveManager, Settings, RNG).
- Keep data loading/parsing separate from gameplay logic.
- Avoid circular dependencies: prefer services/autoloads for shared access.
