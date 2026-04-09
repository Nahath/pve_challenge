require("gamemode")

function Precache(context)
	PrecacheUnitByNameSync("npc_dota_creep_badguys", context)
	PrecacheUnitByNameSync("npc_dota_creep_badguys_ranged", context)
	PrecacheUnitByNameSync("npc_pve_extra_dire_ranged", context)
	PrecacheParticle("particles/creep_healing_wave.vpcf", context)
end

function Activate()
	GameMode = CGameMode()
	GameMode:InitGameMode()
end
