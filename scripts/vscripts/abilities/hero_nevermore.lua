require("abilities/ability_generic")



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

	if ability_name == "nevermore_shadowraze1_imba" then
		local raze_1 = caster_origin + caster_fv * 200
		local raze_2 = caster_origin + caster_fv * 450
		local raze_3 = caster_origin + caster_fv * 700
		table.insert(raze_positions,raze_1);table.insert(raze_positions,raze_2);table.insert(raze_positions,raze_3);
	end
	if ability_name == "nevermore_shadowraze1_imba" then
		local raze_1 = caster_origin + caster_fv * 525
		local angle_left = QAngle(0,-10,0)
		local angle_right = QAngle(0,10,0)
		local raze_2 = RotatePosition(caaster_origin,angle_left,raze_1)
		local raze_3 = RotatePosition(caaster_origin,angle_right,raze_1)
		table.insert(raze_positions,raze_1);table.insert(raze_positions,raze_2);table.insert(raze_positions,raze_3);
	end
	if ability_name == "nevermore_shadowraze1_imba" then
		local raze_1 = caster_origin + caster_fv * 700
		local raze_4 = caster_origin + caster_fv * 750
		local angle_left = QAngle(0,-10,0)
		local angle_right = QAngle(0,10,0)
		local raze_2 = RotatePosition(caaster_origin,angle_left,raze_4)
		local raze_3 = RotatePosition(caaster_origin,angle_right,raze_4)
		table.insert(raze_positions,raze_1);table.insert(raze_positions,raze_2);table.insert(raze_positions,raze_3);
	end
	for _, pos in pairs(raze_positions) do
		FireEffectAndRelease('particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf', caster, pos)

		local enemies = FindUnitsInRadius(caster:GetTeam(), pos, nil, raze_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, unit in pairs(enemies) do
			ApplyDamage({victim = unit, attacker = caster, damage = raze_damage, damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = 0,ability = ability})
		end
	end
end