
-- [[API]]
--- self[target_name]:CastedAbilityHandler(target, source, ability, keys)
--- self[hero_name]:CastAbilityOnTargetHandler(source, target, ability_name, ability, keys)
--- self[hero_name]:CastAbilityAtPositionHandler(hero, target_position, ability, keys)
--- self[hero_name]:CastAbilityNoTargetHandler(hero, ability)
--- self[hero_name]:LearnAbilityHandler(keys, hero, keys.abilityname)
-- [[API]]


if AbilityCore.npc_dota_hero_earthshaker == nil then
	AbilityCore.npc_dota_hero_earthshaker = class({})
end
function AbilityCore.npc_dota_hero_earthshaker:GeneralCastAbilityHandler(caster, aiblity)
	if not caster:GetUnitName() == "npc_dota_hero_earthshaker" then return end
	local ability_aftershock = caster:FindAbilityByName("earthshaker_aftershock")
	if ability_aftershock:GetLevel() < 1 then return end
	local radius = ability_aftershock:GetLevelSpecialValueFor("aftershock_range", ability_aftershock:GetLevel() -1)	
	radius = radius + 150
	if ability_aftershock:GetLevel() > 0 then
		local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, unit in pairs(enemies) do
			local caster_to_unit = (unit:GetOrigin() - caster:GetOrigin()):Normalized()
			local length_to_unit = (unit:GetOrigin() - caster:GetOrigin()):Length2D()
			local target_pos = caster:GetOrigin() + caster_to_unit* length_to_unit/2
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
