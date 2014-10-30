-- self[target_name]:CastedAbilityHandler(keys, hero, ability, ability_target, ability_name)
if AbilityCore.npc_dota_hero_kunkka == nil then
	AbilityCore.npc_dota_hero_kunkka = class({})
end

function ReturnXMarkTargets(kunkka, target)
	print("XMARK RETURN CASTED",kunkka:GetTeam() , target:GetTeam(), target:GetUnitName())
	if kunkka:GetTeam() ~= target:GetTeam() then
		local enemies = FindUnitsInRadius(kunkka:GetTeam(), target:GetOrigin(), nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		print("KUNKKA RETURN ENEMIES FOUND", #enemies)
		if #enemies > 1 then
			print("KUNKKA RETURN ENEMIES FOUND", #enemies)
			for _, unit in pairs(enemies) do
				if unit ~= target then
					FindClearSpaceForUnit(unit, kunkka.__xMarkPosition, false)
				end
			end
		end
	end
end
function grabEnemies(caster)

	local caster_fv = caster:GetForwardVector()
	local caster_origin = caster:GetOrigin()
	local target_pos = caster_origin + caster_fv * 1000
	caster:SetContextThink(DoUniqueString(""),
		function()
			local enemies = FindUnitsInRadius(caster:GetTeam(), target_pos, nil, 625, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			print("enemies found", #enemies)
			--TODO
			-- for _, unit in pairs(enemies) do
			-- 	unit:AddNewModifier(caster, nil, "modifier_pugna_decrepify", {Duration = 2})
			-- end
		end,
	2.8)
end
function AbilityCore.npc_dota_hero_kunkka:CastedAbilityHandler(keys, kunkka, ability, target, ability_name)
	if ability_name == "kunkka_x_marks_the_spot" then
		if not target then return end
		kunkka.__xMarkTarget = target
		kunkka.__xMarkPosition = target:GetOrigin()
		print("KUNKKA, X SPOT CASTED TO ", target:GetUnitName())
		local delay = ability:GetLevelSpecialValueFor("duration",ability:GetLevel() -1)
		kunkka:SetContextThink(DoUniqueString(""),
			function() 
				if target:HasModifier("modifier_kunkka_x_marks_the_spot") then
					ReturnXMarkTargets(kunkka, kunkka.__xMarkTarget)
				end
			end,
		delay)
	end
	if ability_name == "kunkka_return" then
		print("XMARK RETURN CASTED",kunkka.__xMarkTarget:GetUnitName())
		ReturnXMarkTargets(kunkka, kunkka.__xMarkTarget)
	end
	if ability_name == "kunkka_ghostship" then
		local targetPos = ability:GetCursorPosition()
		print("GHOST SHIP TARGET POSITION",targetPos)
		grabEnemies(kunkka)
	end
end



