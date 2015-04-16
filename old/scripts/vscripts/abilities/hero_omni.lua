require('abilities/ability_generic')
if AbilityCore.npc_dota_hero_omniknight == nil then
	AbilityCore.npc_dota_hero_omniknight = class({})
end

function AbilityCore.npc_dota_hero_omniknight:CastAbilityOnTargetHandler(source, target, ability_name, ability, keys)
	if ability_name == 'omniknight_purification' then
		print("OMNI CAST PURIFICATION")
		local bounces = {2,3,4,5}
		local bounce = bounces[ability:GetLevel()]
		local dummy_target = target
		source:SetContextThink(DoUniqueString("heal_bounces"),
			function()
				local friends = FindUnitsInRadius(source:GetTeam(), dummy_target:GetOrigin(), nil, 400, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
				if #friends >= 1 then
					local friend = friends[RandomInt(1,#friends)]
					CreateDummyAtPositionAndCastAbilityOnTarget(source, "omniknight_purification", ability:GetLevel(), dummy_target:GetOrigin(), dummy_target, 2, false)
					dummy_target = friend
				end
				bounce = bounce - 1
				if bounce > 1 then
					return 0.5
				else
					return nil
				end
			end,
		0.5)
	end
end