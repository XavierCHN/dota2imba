require('abilities/ability_generic')
if AbilityCore.npc_dota_hero_lich == nil then
	AbilityCore.npc_dota_hero_lich = class({})
end

function AbilityCore.npc_dota_hero_lich:LearnAbilityHandler(keys)
	if keys.abilityname == "lich_frost_nova_imba" then
		local player = EntIndexToHScript(keys.player)
		if not player then return end
		local hero = player:GetAssignedHero()
		if not hero then return end
		local ability = hero:FindAbilityByName("lich_frost_nova_imba")
		if not ability then return end
		local delay = ability:GetLevelSpecialValueFor("auto_nova_interval", ability:GetLevel() - 1)
		local radius = ability:GetLevelSpecialValueFor("auto_nova_radius", ability:GetLevel() - 1)
		hero:SetContextThink("auto_matic_release_nova",
			function()
				local enemies = FindUnitsInRadius(hero:GetTeam(), hero:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
				if not enemies then return delay end
				if #enemies <= 0 then return delay end
				CreateDummyAndCastAbilityOnTarget(hero, "lich_frost_nova", ability:GetLevel(), target, 5, false)
				return delay
			end,
		delay)
	end
end

function OnDarkRitualCast(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if not( caster and target and ability ) then return end

	local mana_turn_rate = ability:GetLevelSpecialValueFor("turn_rate", ability:GetLevel() - 1)
	local buff_radius = ability:GetLevelSpecialValueFor("buff_radius", ability:GetLevel() - 1)
	local buff_duration = 	ability:GetLevelSpecialValueFor("buff_duration", ability:GetLevel() - 1)
	local target_origin = target:GetOrigin()
	local target_health = target:GetHealth()
	local mana = mana_turn_rate * target_health
	caster:SetMana(target:GetMana(0 + mana))

	ApplyDamage({attacker = caster, victim = target, damage = target_health, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_UNIT_TARGET_FLAG_NONE})

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