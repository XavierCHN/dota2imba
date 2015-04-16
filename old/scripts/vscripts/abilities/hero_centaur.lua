-- [[API]]
--- self[target_name]:CastedAbilityHandler(target, source, ability, keys)
--- self[hero_name]:CastAbilityOnTargetHandler(source, target, ability_name, ability, keys)
--- self[hero_name]:CastAbilityAtPositionHandler(hero, target_position, ability, keys)
--- self[hero_name]:CastAbilityNoTargetHandler(hero, ability)
--- self[hero_name]:LearnAbilityHandler(keys, hero, keys.abilityname)
--- self[hero_name]:GeneralCastAbilityHandler(hero, ability)
-- [[API]]

require('abilities/ability_generic')
if AbilityCore.npc_dota_hero_centaur == nil then
	AbilityCore.npc_dota_hero_centaur = class({})
end
-- self[hero:GetUnitName()]:CastedAbilityHandler(keys, hero, ability, nil, ability_name)
function AbilityCore.npc_dota_hero_centaur:GeneralCastAbilityHandler(caster, ability)
	if ability:GetAbilityName() == "centaur_hoof_stomp" then
		local dur = {2,3,4,5}
		local duration = dur[ability:GetLevel()]
		local caster_origin = caster:GetOrigin()
		local start_time = GameRules:GetGameTime()
		-- 创建地裂的粒子特效
		local p_index = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_sun_strike_ground.vpcf", PATTACH_CUSTOMORIGIN, centaur)
		ParticleManager:SetParticleControl(p_index, 0, caster_origin)

		caster:SetContextThink(DoUniqueString(''),
			function()
				local enemies = FindUnitsInRadius(caster:GetTeam(), caster_origin, nil, 315, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
				if #enemies > 0 then
					for _, unit in pairs(enemies) do
						if not unit:HasModifier("modifier_stunned") then
							unit:AddNewModifier(caster, ability, "modifier_stunned", {Duration = 1})
						end
					end
				end
				if ( GameRules:GetGameTime() - start_time) >= duration  then
					ParticleManager:DestroyParticle(p_index,true)
					ParticleManager:ReleaseParticleIndex(p_index)
					return nil
				else
					return 0.01
				end
			end,
		0.01)
	end

	if ability_name == "centaur_stampede_imba" then
		centaur:SetContextThink(DoUniqueString(""),
			function()
				local ability_stampede = centaur:FindAbilityByName("centaur_stampede")
				ability_stampede:SetLevel(ability:GetLevel())
				centaur:CastAbilityNoTarget(ability_stampede,centaur:GetPlayerID())
			end,
		0)
	end

	if ability_name == "centaur_double_edge" then
		local caster = centaur
		local target = ability_target
		local strength_sub = nil

		local damage_ratio = {1,1.5,2,2.5}
		local damage_ratios = damage_ratio[ability:GetLevel()]
		if not target:IsRealHero() then
			strength_sub = caster:GetStrength()
		else
			strength_sub = caster:GetStrength() - target:GetStrength()
		end
		local damage_dealt = ApplyDamage({attacker = caster, victim = target, damage = strength_sub * damage_ratios, damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, ability = ability})
		print("damage dealt",strength_sub,damage_dealt)	
	end
end