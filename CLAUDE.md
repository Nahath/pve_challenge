# Instructions

- Take the user's words literally. Do not add, infer, or expand beyond what is explicitly stated. When something is unspecified, ask rather than assume.
- Before flagging something as unspecified, re-read the full document to confirm it is not already addressed.
- Do not flag two statements as contradictory unless they describe the same situation with mutually exclusive outcomes.
- Do not flag something as missing or unspecified if it can be solved with standard programming logic or algorithms.
- **Work with very low reliance on assumptions.** Prefer verified documentation, real examples, and confirmed facts over inference. When an assumption is unavoidable, do not silently code it and ask if it worked — instead, surface the assumption explicitly, explain the uncertainty, and discuss the options with the user before writing any code.

# Mod Overview

This is a Dota 2 custom game mod. Key design constraints:

- **Map**: Uses the default Dota 2 map (`dota`). No custom map.
- **Players vs AI**: Human players are on Radiant (`DOTA_TEAM_GOODGUYS = 2`). The AI/bot team is Dire (`DOTA_TEAM_BADGUYS = 3`).
- **Custom lane creeps**: New types of lane creeps are being added. Custom creeps and special stat advantages are given exclusively to the AI team (Dire).
- **Language**: Dota 2 custom games use **Lua** for scripting and **KeyValues (KV)** for data files.

# Reference Documentation

Dota 2 modding reference is in the DotaModHelper repo at `docs/dota2_modding_reference.md`. Consult it before answering questions about the API, file structure, KV format, or creep spawning. Key points:

- Entry point: `scripts/vscripts/addon_game_mode.lua` (hardcoded filename)
- Custom units defined in: `scripts/npc/npc_units_custom.txt`
- Use `BaseClass "npc_dota_creature"` for all custom units
- Lane creep interception: `ListenToGameEvent("npc_spawned", ...)` + `unit:IsLaneCreep()`
- To replace a default creep: `unit:ForceKill(false)` then `CreateUnitByName(customName, pos, true, nil, nil, team)`
- Team-specific logic: check `unit:GetTeamNumber() == DOTA_TEAM_BADGUYS`
