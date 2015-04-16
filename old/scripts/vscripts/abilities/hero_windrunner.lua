if AbilityCore.npc_dota_hero_windrunner == nil then
	AbilityCore.npc_dota_hero_windrunner = class({})
end

function AbilityCore.npc_dota_hero_windrunner:CastAbilityAtPositionHandler(hero, target_position, ability, keys)
	print("WINDRUNNER CAST AN ABILITY",ability:GetAbilityName())
	local ability_name = ability:GetAbilityName()
	if not (ability_name == "windrunner_powershot_imba") then return end
	if not target_position then return end

	local ability_level = ability:GetLevel()
	local PositionTable = {target_position}
	local angle_left = QAngle(0, 10 ,0)
	local angle_right = QAngle(0, -10 ,0)
	local PosLeft = RotatePosition(hero:GetOrigin(), angle_left, target_position)
	local PosRight = RotatePosition(hero:GetOrigin(), angle_right, target_position)
	table.insert(PositionTable, PosLeft)
	table.insert(PositionTable, PosRight)
	
	for _, pos in pairs(PositionTable) do
		CreateDummyAndCastAbilityAtPosition(hero, "windrunner_powershot", ability_level, pos, 4, false)
	end
end