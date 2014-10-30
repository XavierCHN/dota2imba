if AbilityCore.npc_dota_hero_earthshaker == nil then
	AbilityCore.npc_dota_hero_earthshaker = class({})
end
function AbilityCore.npc_dota_hero_earthshaker:CastedAbilityHandler(keys, hero, ability, ability_target, ability_name)
	if not hero:GetUnitName() == "npc_dota_hero_earthshaker" then return end
	print("earthshaker cast ability")
	local ability_aftershock = hero:FindAbilityByName("earthshaker_aftershock")
	local radius = ability_aftershock:GetLevelSpecialValueFor("aftershock_range", ability_aftershock:GetLevel() -1)	
	radius = radius + 150
	if ability_aftershock:GetLevel() > 0 then
		local enemies = FindUnitsInRadius(hero:GetTeam(), hero:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, unit in pairs(enemies) do
			local caster_to_unit = (unit:GetOrigin() - hero:GetOrigin()):Normalized()
			local length_to_unit = (unit:GetOrigin() - hero:GetOrigin()):Length2D()
			local target_pos = hero:GetOrigin() + caster_to_unit* length_to_unit/2
			FindClearSpaceForUnit(unit,target_pos,false)
		end
	end
end

function OnFissure(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	if not (caster and ability and point ) then return end

	local caster_origin = caster:GetOrigin()
	local ability_direction = (point - caster_origin):Normalized()
	local position_dummy = caster_origin + ability_direction * 80 --todo
	local angle_left = QAngle(0, -90, 0)
	local angle_right = QAngle(0, 90, 0)
	local start_pos_left = RotatePosition(caster_origin,angle_left,position_dummy)
	local start_pos_right = RotatePosition(caster_origin,angle_right,position_dummy)
	local ability_pos_left = start_pos_left + ability_direction * 500
	local ability_pos_right = start_pos_right + ability_direction * 500
	local start_pos_left_1 = start_pos_left + ability_direction * 1400
	local start_pos_right_1 = start_pos_right + ability_direction * 1400
	local ability_pos_left_1 = start_pos_left_1 + ability_direction * 500
	local ability_pos_right_1 = start_pos_right_1 + ability_direction * 500

	CreateDummyAtPositionAndCastAbilityAtPosition(caster, "earthshaker_fissure", ability:GetLevel(), start_pos_left, ability_pos_left, 8.5, false)
	CreateDummyAtPositionAndCastAbilityAtPosition(caster, "earthshaker_fissure", ability:GetLevel(), start_pos_left_1, ability_pos_left_1, 8.5, false)
	CreateDummyAtPositionAndCastAbilityAtPosition(caster, "earthshaker_fissure", ability:GetLevel(), start_pos_right, ability_pos_right, 8.5, false)
	CreateDummyAtPositionAndCastAbilityAtPosition(caster, "earthshaker_fissure", ability:GetLevel(), start_pos_right_1, ability_pos_right_1, 8.5, false)
end

function OnTotemAttack(keys)
	print("LANDED")
	local caster = keys.caster
	local target = keys.target_entities[1]
	local radius = keys.radius
	local percentage = keys.percentage
	if not (caster and target and radius and percentage) then return end
end

function OnEchoSlam(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not (caster and ability ) then return end


	
end