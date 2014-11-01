-- [[API]]
--- self[target_name]:CastedAbilityHandler(target, source, ability, keys)
--- self[hero_name]:CastAbilityOnTargetHandler(source, target, ability_name, ability, keys)
--- self[hero_name]:CastAbilityAtPositionHandler(hero, target_position, ability, keys)
--- self[hero_name]:CastAbilityNoTargetHandler(hero, ability)
--- self[hero_name]:LearnAbilityHandler(keys, hero, keys.abilityname)
--- self[hero_name]:GeneralCastAbilityHandler(hero, ability)
-- [[API]]
require('abilities/ability_generic')
if AbilityCore.npc_dota_hero_sven == nil then
	AbilityCore.npc_dota_hero_sven = class({})
end
function AbilityCore.npc_dota_hero_sven:GeneralCastAbilityHandler(hero, ability)
	if ability:GetAbilityName() == 'sven_warcry' then
		local friends = FindUnitsInRadius(hero:GetTeam(),hero:GetOrigin(),nil,1000,DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
		local ability_datadriven_applier = hero:FindAbilityByName("sven_all_ability_datadriven_modifier")
		ability_datadriven_applier:SetLevel(ability:GetLevel())
		for _, unit in pairs(friends) do
			AddModifier(hero, unit, ability_datadriven_applier, "modifier_sven_warcry_strength_bonus", 15)
		end
	end
end
function AbilityCore.npc_dota_hero_sven:LearnAbilityHandler(keys, hero, ability_name)
	if ability_name == 'sven_great_cleave' then
		local ability_modifier = hero:FindAbilityByName("sven_great_cleave_modifier")
		local ability_cleave = hero:FindAbilityByName(keys.abilityname)
		ability_modifier:SetLevel(ability_cleave:GetLevel())
	end
end
function OnWarCryCreated(keys)
	local owner = keys.target_entities[1]
	local strength = owner:GetBaseStrength()
	owner.__base_strength = owner:GetBaseStrength()
	local ratio = {1.2,1.3,1.4,1.5}
	local rat = ratio[keys.ability:GetLevel()]
	owner:SetBaseStrength(strength * rat)
end
function OnWarCryDestroy(keys)
	local owner = keys.target_entities[1]
	local strength = owner.__base_strength
	if not strength then return end
	owner:SetBaseStrength(strength)
end
function OnStormBolt(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if not (caster and target and ability) then return end
	FindClearSpaceForUnit(caster, target:GetOrigin(), false)
	CreateDummyAndCastAbilityOnTarget(caster, "sven_storm_bolt", ability:GetLevel(), target, 4, false)
end
function OnGreatCleaveAttackLanded(keys)
	local caster = keys.caster
	local target = keys.target_entities[1]
	local chance = keys.Chance
	-- chance = 1000 --TODO TEST
	if RandomInt(1,100) <= chance then
		local damage = target:GetHealth() / 2
		local ability_greatecleave = caster:FindAbilityByName("sven_great_cleave")
		ApplyDamage({attacker = caster,victim =target, damage = damage, damage_type = DAMAGE_TYPE_PURE, damage_flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, ability = ability_greatecleave})
	end
end