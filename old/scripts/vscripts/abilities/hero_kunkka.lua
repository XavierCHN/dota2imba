-- [[API]]
--- self[target_name]:CastedAbilityHandler(target, source, ability, keys)
--- self[hero_name]:CastAbilityOnTargetHandler(source, target, ability_name, ability, keys)
--- self[hero_name]:CastAbilityAtPositionHandler(hero, target_position, ability, keys)
--- self[hero_name]:CastAbilityNoTargetHandler(hero, ability)
--- self[hero_name]:LearnAbilityHandler(keys, hero, keys.abilityname)
--- self[hero_name]:GeneralCastAbilityHandler(hero, ability)
-- [[API]]

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

function AbilityCore.npc_dota_hero_kunkka:CastAbilityOnTargetHandler(kunkka, target, ability_name, ability, _)
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
end

function AbilityCore.npc_dota_hero_kunkka:CastAbilityAtPositionHandler(hero, target_position, ability, keys)
	
end