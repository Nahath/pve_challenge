pve_creep_bolt = class({})

function pve_creep_bolt:OnProjectileHit(hTarget, vLocation)
	if hTarget == nil then return end

	hTarget:SetHealth(math.min(hTarget:GetHealth() + 100, hTarget:GetMaxHealth()))

	return true  -- stop the projectile on hit
end
