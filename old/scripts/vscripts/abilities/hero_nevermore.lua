require("abilities/ability_generic")

if AbilityCore.npc_dota_hero_nevermore == nil then
	AbilityCore.npc_dota_hero_nevermore = class({})
end

-- self[hero_name]:LearnAbilityHandler(keys, hero, keys.abilityname)
function AbilityCore.npc_dota_hero_nevermore:LearnAbilityHandler(keys, hero, ability_name)
	if ability_name == "nevermore_shadowraze1_imba"  or ability_name == "nevermore_shadowraze2_imba" or ability_name == "nevermore_shadowraze3_imba"then
		local ability_1 = hero:FindAbilityByName("nevermore_shadowraze1_imba")
		local ability_2 = hero:FindAbilityByName("nevermore_shadowraze2_imba")
		local ability_3 = hero:FindAbilityByName("nevermore_shadowraze3_imba")
		if ability_1 and ability_2 and ability_3 then
			local max_level = math.max(ability_1:GetLevel(), ability_2:GetLevel(), ability_3:GetLevel())
			ability_1:SetLevel(max_level)
			ability_2:SetLevel(max_level)
			ability_3:SetLevel(max_level)
		end
	end
end

function OnRazeStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not (caster and ability) then return end

	local ability_name = ability:GetAbilityName()
	local raze_damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1)
	local raze_radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1)

	local caster_fv = caster:GetForwardVector()
	local caster_origin = caster:GetOrigin()
	local raze_positions = {}

	local ability = caster:FindAbilityByName("nevermore_necromastery")
	if ability then
		print("ability necromastery found",raze_damage)
		if ability:GetLevel() >= 1 then
			local nevermore_necromastery_stack_count = caster:GetModifierStackCount("modifier_nevermore_necromastery",ability_necromastery)
			print(nevermore_necromastery_stack_count)
			if nevermore_necromastery_stack_count > 0 then
				raze_damage = raze_damage + nevermore_necromastery_stack_count * 0.5
				print("RAZE DAMAGE AFTER NECROMASTERY  BUFFS", raze_damage)
			end
		end
	end

	if ability_name == "nevermore_shadowraze1_imba" then
		local raze_1 = caster_origin + caster_fv * 200
		local raze_2 = caster_origin + caster_fv * 450
		local raze_3 = caster_origin + caster_fv * 700
		table.insert(raze_positions,raze_1);table.insert(raze_positions,raze_2);table.insert(raze_positions,raze_3);
	end
	if ability_name == "nevermore_shadowraze2_imba" then
		local raze_1 = caster_origin + caster_fv * 525
		local angle_left = QAngle(0,-10,0)
		local angle_right = QAngle(0,10,0)
		local raze_2 = RotatePosition(caster_origin,angle_left,raze_1)
		local raze_3 = RotatePosition(caster_origin,angle_right,raze_1)
		table.insert(raze_positions,raze_1);table.insert(raze_positions,raze_2);table.insert(raze_positions,raze_3);
	end
	if ability_name == "nevermore_shadowraze3_imba" then
		local raze_1 = caster_origin + caster_fv * 750
		local raze_4 = caster_origin + caster_fv * 850
		local angle_left = QAngle(0,-7,0)
		local angle_right = QAngle(0,7,0)
		local raze_2 = RotatePosition(caster_origin,angle_left,raze_4)
		local raze_3 = RotatePosition(caster_origin,angle_right,raze_4)
		table.insert(raze_positions,raze_1);table.insert(raze_positions,raze_2);table.insert(raze_positions,raze_3);
	end

	caster:EmitSound("Hero_Nevermore.Shadowraze")

	for _, pos in pairs(raze_positions) do
		FireEffectAndRelease('particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf', caster, pos)

		local enemies = FindUnitsInRadius(caster:GetTeam(), pos, nil, raze_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, unit in pairs(enemies) do
			ApplyDamage({victim = unit, attacker = caster, damage = raze_damage, damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = 0,ability = ability})
		end
	end
end