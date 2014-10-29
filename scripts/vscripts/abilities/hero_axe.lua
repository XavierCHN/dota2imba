require("abilities/ability_generic")

-- 反击螺旋 —— 被攻击
-- 
function OnCounterHelixAttacked(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not (caster and ability) then return end

	-- 初始化变量
	local chance = ability:GetLevelSpecialValueFor('trigger_chance', ability:GetLevel())
	local bonus_chance = ability:GetSpecialValueFor("chance_per_strength")
	local radius = ability:GetSpecialValueFor("radius")
	local damage = ability:GetLevelSpecialValueFor('damage', ability:GetLevel())

	-- 获取力量数值
	local strength_value = caster:GetStrength()

	-- 计算概率
	local total_chance = chance + bonus_chance * strength_value
	-- 获取随机数
	local random_result = RandomInt(1,100)

	-- 如果成功，则进行一次反击螺旋/播放声音/特效/造成伤害
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

-- 战争饥渴 —— 循环
-- 作废
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

-- 淘汰之刃 —— 释放
-- 
function OnCullingBlade(keys)
	local caster = keys.caster
	local target = keys.target_entities[1]
	local ability = keys.ability
	if not (caster and target and ability) then return end

	-- 初始化变量
	local target_health = target:GetHealth()
	local target_kills = target:GetKills() if target_kills == 0 then target_kills = 1 end
	local target_deaths = target:GetDeaths()
	local ability_damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1)
	local kill_threshold = ability:GetLevelSpecialValueFor("kill_threshold", ability:GetLevel() - 1)
	if FindScepter(caster) then 
		kill_threshold = ability:GetLevelSpecialValueFor("kill_threshold_scepter", ability:GetLevel() - 1)
	end

	-- 计算是否需要直接淘汰
	local cull = false
	cull = cull or (target_deaths/target_kills > 2)-- 如果死亡/击杀>2，则淘汰
	cull = cull or (target_health < kill_threshold) --如果血量不足，则淘汰
	print("CULL?", cull)

	-- 如果不直接淘汰，则造成伤害
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
		-- 创建马甲单位并对目标释放真正的淘汰之刃
		CreateDummyAndCastAbilityOnTarget(caster, "axe_culling_blade" , 2, target, 0.2, FindScepter(caster))
	end
end