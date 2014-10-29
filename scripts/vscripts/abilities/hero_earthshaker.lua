function OnFissure(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	if not (caster and ability and point ) then return end

	local caster_origin = caster:GetOrigin()
	local ability_direction = (point - caster_origin):Normalized()
	local position_dummy = caster_origin + ability_direction * 150 --todo
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

function OnEchoSlam(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not (caster and ability ) then return end


	
end