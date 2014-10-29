require('abilities/ability_generic')
if AbilityCore.npc_dota_hero_lich == nil then
	AbilityCore.npc_dota_hero_lich = class({})
end

-- 处理学习了NOVA之后的间隔一段时间自动释放NOVA
			-- self[hero_name]:LearnAbilityHandler(keys, hero, keys.abilityname)
function AbilityCore.npc_dota_hero_lich:LearnAbilityHandler(keys, hero, ability_name)
	if ability_name == "lich_frost_nova" then
		local ability = hero:FindAbilityByName("lich_frost_nova")
		if not ability then return end
		local delay = { 8, 7, 6, 5}
		local radius = 550
		hero:SetContextThink("auto_matic_release_nova",
			function()
				print("LICH! NOVA!")
				local enemies = FindUnitsInRadius(hero:GetTeam(), hero:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
				if not enemies then return delay[ability:GetLevel()] end
				if #enemies <= 0 then return delay[ability:GetLevel()] end
				CreateDummyAndCastAbilityOnTarget(hero, "lich_frost_nova", ability:GetLevel(), enemies[RandomInt(1,#enemies)], 5, false)
				return delay[ability:GetLevel()] 
			end,
		delay[ability:GetLevel()])
	end
end
-- 处理放牺牲之后的BUFF
-- self[target_name]:CastedAbilityHandler(keys, hero, ability, ability_target, ability_name)
function AbilityCore.npc_dota_hero_lich:CastedAbilityHandler(keys, lich, ability, creep, ability_name)

	if ability_name == "lich_dark_ritual" then
		OnDarkRitualCast(lich, ability, creep)
	end
end

function OnDarkRitualCast(caster, ability, target)
	print("on dark ritual called")
	local allies_around = FindUnitsInRadius(caster, target_origin, nil, buff_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES, FIND_ANY_ORDER, false)	
	for _, unit in pairs(allies_around) do
		AddModifier(caster, unit, ability, "modifier_dark_ritual_imba_buff", buff_duration)
	end
end

function OnChainFrostCast(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if not( caster and target and ability ) then return end

	-- TODO
	
end