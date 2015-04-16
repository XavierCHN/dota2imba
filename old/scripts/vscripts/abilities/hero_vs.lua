require('abilities/ability_generic')

if AbilityCore.npc_dota_hero_vengefulspirit == nil then
	AbilityCore.npc_dota_hero_vengefulspirit = class({})
end

function AbilityCore.npc_dota_hero_vengefulspirit:CastAbilityOnTargetHandler(source, target, ability_name, ability, keys)
	if ability:GetAbilityName() == 'vengefulspirit_magic_missile' then
		local allies = FindUnitsInRadius(source:GetTeam(),source:GetOrigin(),nil,500,DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_INVULNERABLE,FIND_ANY_ORDER,false)
		for _, ally in pairs(allies) do
			CreateDummyAtPositionAndCastAbilityOnTarget(source, 'vengefulspirit_magic_missile', ability:GetLevel(), ally:GetOrigin(), target, 5, false)
		end
		return
	end
	if ability:GetAbilityName() == 'vengefulspirit_nether_swap' then
		local ability_modifier_applier = source:FindAbilityByName("vengefulspirit_modifier_applier")
		ability_modifier_applier:SetLevel(ability:GetLevel())
		AddModifier(source, target, ability_modifier_applier, "modifier_swap_invunerable")
	end
end

function OnWaveOfTerrorIntervalThink(keys)
	local caster = keys.caster
	local target = keys.target_entities[1]
	if not (caster and target) then return end
	if not (target:HasModifier("modifier_terror_imba")) then return end

	target:Stop()
	local target_origin = target:GetOrigin()
	local target_pos = target_origin + RandomVector(30)
	target:SetContextThink(DoUniqueString(""),function() target:MoveToPosition(target_pos) end,0)
end