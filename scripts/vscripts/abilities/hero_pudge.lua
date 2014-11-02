if AbilityCore.npc_dota_hero_pudge == nil then
	AbilityCore.npc_dota_hero_pudge = class({})
end

function OnMeatHookStart(keys)
	local caster = keys.caster
	local pos = keys.target_points[1]
	caster.___hook_start_pos = caster:GetOrigin()
	CreateDummyAtPositionAndCastAbilityAtPosition(caster, "pudge_meat_hook", keys.ability:GetLevel(), caster:GetOrigin() + (pos - caster:GetOrigin()):Normalized() * 80, pos, 10, false)
end

function OnMeatHookHit(keys)
	local caster = keys.caster
	local target = keys.target
	if not (caster and target ) then return end
	local damage_per_100 = keys.DamagePer100
	local target_pos = target:GetOrigin()
	local distance = (target_pos - caster.___hook_start_pos):Length2D()
	ApplyDamage({victim = target, attacker = caster, damage = distance * damage_per_100 / 100, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_UNIT_TARGET_FLAG_NONE, ability = keys.ability})
end