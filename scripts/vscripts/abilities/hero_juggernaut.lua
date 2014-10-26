function OnBladeFuryCasting(keys)
	local caster = keys.caster
	local units = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, 375, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, unit in pairs(units) do
		local unit_position = unit:GetOrigin()
		local caster_position = caster:GetOrigin()
		local blade_angle = QAngle(0,1.5,0)
		local closer_position = caster_position + ((unit_position - caster_position):Normalized()) * (0.96 * (unit_position - caster_position):Length2D())
		local result_position = RotatePosition(caster_position, blade_angle, closer_position)
		FindClearSpaceForUnit(unit, result_position, true)
	end
end
function OnBladeFuryStart(keys)
	local caster = keys.caster
	EmitSoundOn("Hero_Juggernaut.BladeFuryStart", caster)
end
function OnBladeFuryStop(keys)
	print("STOP!!!!")
	local caster = keys.caster
	StopSoundOn("Hero_Juggernaut.BladeFuryStart", caster)
end
