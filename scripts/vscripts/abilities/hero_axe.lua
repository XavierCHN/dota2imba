require("abilities/ability_generic")

function OnCounterHelixAttacked(keys)
	local caster = keys.caster
	local ability = keys.ability
	local chance = ability:GetLevelSpecialValueFor('trigger_chance', ability:GetLevel())
	local bonus_chance = ability:GetSpecialValueFor("chance_per_strength")
	local strength_value = caster:GetStrength()
	local radius = ability:GetSpecialValueFor("radius")
	local damage = ability:GetLevelSpecialValueFor('damage', ability:GetLevel())

	local total_chance = chance + bonus_chance * strength_value
	local random_result = RandomInt(1,100)

	if  random_result < total_chance then
		caster:EmitSound("Hero_Axe.CounterHelix")
		FireEffectAndRelease("particles/units/heroes/hero_axe/axe_attack_blur_counterhelix.vpcf", caster, caster:GetOrigin())
		local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, unit in pairs(enemies) do
			local damage_dealt = ApplyDamage({
				victim = unit,
				attacker = caster,
				damage = damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				damage_flags = 0,
				ability = ability
			})
		end
	end
end
function OnImbaBattleHungerIntervalThink(keys)
	print("battle hunger on interval think")
	local caster = keys.caster
	local target = keys.target_entities[1]
	local ability = keys.ability
	if not (caster and target and ability) then return end
	
	local target_health = target:GetHealth()
	local damage_base = ability:GetLevelSpecialValueFor("damage_base", ability:GetLevel() - 1)
	local damage_percentage = ability:GetLevelSpecialValueFor("damage_percentage", ability:GetLevel() - 1)

	local damage = damage_base + damage_percentage * target_health / 100

	ApplyDamage({victim = target,attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL , damage_flags = DOTA_UNIT_TARGET_FLAG_NONE, ability = ability})
end
function OnCullingBlade(keys)
	-- 原始已经重写为 1级失败，造成0伤害，2级必杀
	local caster = keys.caster
	local target = keys.target_entities[1]
	local ability = keys.ability
	if not (caster and target and ability) then return end

	local target_health = target:GetHealth()
	local target_kills = target:GetKills() if target_kills == 0 then target_kills = 1 end
	local target_deaths = target:GetDeaths()
	local ability_damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1)
	local kill_threshold = ability:GetLevelSpecialValueFor("kill_threshold", ability:GetLevel() - 1)
	if FindScepter(caster) then 
		kill_threshold = ability:GetLevelSpecialValueFor("kill_threshold_scepter", ability:GetLevel() - 1)
	end

	local cull = false
	cull = cull or (target_deaths/target_kills > 2)-- 如果死亡/击杀>2，则淘汰
	cull = cull or (target_health < kill_threshold) --如果血量不足，则淘汰

	print("CULL?", cull)

	if not cull then
		local damage_dealt = ApplyDamage({
			victim = target,
			attacker = caster,
			damage = ability_damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			damage_flags = 0,
			ability = ability
		})
	else
		CreateDummyAndCastAbilityOnTarget(caster, "axe_culling_blade" , 2, target, 0.2, FindScepter(caster))
	end
end