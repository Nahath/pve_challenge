CGameMode = class({})

function CGameMode:InitGameMode()
	GameRules:SetCreepSpawningEnabled(true)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 5)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 5)

	-- Fill all 5 Dire slots with bots (false = Dire)
	-- Pattern confirmed from NikolasTzimoulis/Couriers and lightbringer/dota2ai
	Tutorial:StartTutorialMode()
	Tutorial:AddBot("npc_dota_hero_axe",            "top", "hard", false)
	Tutorial:AddBot("npc_dota_hero_juggernaut",     "bot", "hard", false)
	Tutorial:AddBot("npc_dota_hero_crystal_maiden", "mid", "hard", false)
	Tutorial:AddBot("npc_dota_hero_lion",           "top", "hard", false)
	Tutorial:AddBot("npc_dota_hero_sniper",         "bot", "hard", false)
	GameRules:GetGameModeEntity():SetBotThinkingEnabled(true)

	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(CGameMode, "OnGameRulesStateChange"), self)
end

function CGameMode:OnGameRulesStateChange(event)
	if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then return end

	print("[PvE Challenge] Game started.")

	-- Cache the first waypoint for each Dire lane
	self.laneStartWaypoints = {
		Entities:FindByName(nil, "lane_top_pathcorner_badguys_1"),
		Entities:FindByName(nil, "lane_mid_pathcorner_badguys_1"),
		Entities:FindByName(nil, "lane_bot_pathcorner_badguys_1"),
	}

	local names = { "top", "mid", "bot" }
	for i, wp in ipairs(self.laneStartWaypoints) do
		if wp then
			print("[PvE Challenge] " .. names[i] .. " waypoint found: " .. tostring(wp:GetAbsOrigin()))
		else
			print("[PvE Challenge] " .. names[i] .. " waypoint NOT FOUND")
		end
	end

	ListenToGameEvent("npc_spawned", Dynamic_Wrap(CGameMode, "OnNPCSpawned"), self)
end

function CGameMode.BoltThink(unit)
	if not IsValidEntity(unit) or unit:IsNull() or not unit:IsAlive() then return nil end

	local heroes = FindUnitsInRadius(
		unit:GetTeamNumber(),
		unit:GetAbsOrigin(),
		nil,
		1000,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	if #heroes == 0 then return 10.0 end

	local target    = heroes[1]
	local direction = (target:GetAbsOrigin() - unit:GetAbsOrigin()):Normalized()
	local ability   = unit:FindAbilityByName("pve_creep_bolt")

	ProjectileManager:CreateLinearProjectile({
		Source          = unit,
		Ability         = ability,
		EffectName      = "particles/creep_healing_wave.vpcf",
		vSpawnOrigin    = unit:GetAbsOrigin(),
		vVelocity       = direction * 500,
		fDistance       = 1000,
		fStartRadius    = 30,
		fEndRadius      = 30,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		bDeleteOnHit    = false,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		bProvidesVision = false,
	})

	return 10.0
end

function CGameMode:OnNPCSpawned(event)
	local unit = EntIndexToHScript(event.entindex)
	if unit == nil or unit:GetClassname() ~= "npc_dota_creep_lane" then return end
	if unit:GetTeamNumber() ~= DOTA_TEAM_BADGUYS then return end
	if unit:GetUnitName() ~= "npc_dota_creep_badguys_ranged" then return end

	local spawnPos = unit:GetAbsOrigin()

	-- Find the nearest lane start waypoint to determine which lane this creep is in
	local nearest = nil
	local nearestDist = math.huge
	for _, wp in ipairs(self.laneStartWaypoints) do
		if wp ~= nil then
			local dist = (spawnPos - wp:GetAbsOrigin()):Length()
			if dist < nearestDist then
				nearestDist = dist
				nearest = wp
			end
		end
	end

	if nearest == nil then
		print("[PvE Challenge] Warning: no start waypoint found near " .. tostring(spawnPos))
		return
	end

	local extra = CreateUnitByName("npc_pve_extra_dire_ranged", spawnPos, true, nil, nil, DOTA_TEAM_BADGUYS)
	if extra == nil then
		print("[PvE Challenge] Warning: CreateUnitByName returned nil")
		return
	end

	extra:SetModelScale(0.8)
	extra:SetRenderColor(80, 80, 255)

	-- Pattern from Valve Overthrow example: SetInitialGoalEntity only
	extra:SetInitialGoalEntity(nearest)

	-- Start the bolt think on this unit
	extra:SetContextThink("pve_creep_bolt_think", function()
		return CGameMode.BoltThink(extra)
	end, 10.0)
end
