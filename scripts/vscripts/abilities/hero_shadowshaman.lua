require("abilities/ability_generic")
function OnEtherShockStart( keys )
	local caster = keys.caster
	local target = keys.target_entities[1]
	local ability = keys.ability
	if not (caster and ability and target) then return end

	-- 获取技能影响范围和等级
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1)
	local level = ability:GetLevel()
	CreateDummyAndCastAbilityOnTarget(caster, "shadow_shaman_ether_shock", level, target, 1, false)

	-- 获取范围内单位
	local enemies = FindUnitsInRadius(caster:GetTeam(), target:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	-- 对每一个单位释放枷锁 
	caster:SetContextThink(DoUniqueString("shackles"),
		function()
			for _, unit in pairs(enemies) do
				CreateDummyAndCastAbilityOnTarget(caster, "shadow_shaman_shackles", level, unit, 10, false)
			end
		end,
	0.18)
end
function OnVoodooStart(keys)
	local caster = keys.caster
	local target = keys.target_entities[1]
	local ability = keys.ability
	if not (caster and ability and target) then return end

	-- 获取技能范围和等级
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1)
	local level = ability:GetLevel()
	-- 获取范围内单位并创建马甲对其释放原始的变羊技能
	local enemies = FindUnitsInRadius(caster:GetTeam(), target:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	print("UNITS FOUND", #enemies)
	for _, unit in pairs(enemies) do
		CreateDummyAndCastAbilityOnTarget(caster, "shadow_shaman_voodoo", level, unit, 2, false)
	end
end
function OnHealingWaveStart(keys)
	local caster = keys.caster
	if not caster then return end
	caster.reduce_chance = 0
end
function OnHealingWaveHitUnit(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not (caster and ability ) then return end

	-- 获取基础减CD概率
	local reduce_chance = ability:GetLevelSpecialValueFor("reduce_chance", ability:GetLevel() -1)
	-- 获取每命中一个单位减CD概率
	local reduce_chance_per_bounces = ability:GetLevelSpecialValueFor("reduce_chance_per_hit", ability:GetLevel() -1)

	-- 叠加概率
	caster.reduce_chance = (caster.reduce_chance or 0) + reduce_chance_per_bounces
	reduce_chance = reduce_chance + caster.reduce_chance
	print("ABILITY REDUCE CHANCE,",reduce_chance)

	-- 获取随机数
	if RandomInt(1,100) < reduce_chance then
		print("REDUCING ABILITY COOLDOWN")
		-- 循环所有技能
		for i = 0, 17 do
			local ability_in_slot = caster:GetAbilityByIndex(i)
			if ability_in_slot then
				-- 对不是治疗波以外的技能减少1秒CD
				if not (ability_in_slot == ability ) then
					print("REDUCE COOLDOWN FOR ABILITY,", ability_in_slot:GetName())
					local cooldown = ability_in_slot:GetCooldownTimeRemaining()
					print("COOLDOWN B4",cooldown)
					ability_in_slot:EndCooldown()
					ability_in_slot:StartCooldown(cooldown - 1)
					print("cooldown after", ability_in_slot:GetCooldownTimeRemaining())
				end
			end
		end
	end
end
function OnWardCast(keys)
	print("on ward cast")
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	if not( caster and ability and point ) then return end

	-- 获取技能等级，棒子数量和伤害
	local ability_level = ability:GetLevel()
	local damage_max = ability:GetLevelSpecialValueFor("damage_max", ability_level -1)
	local damage_min = ability:GetLevelSpecialValueFor("damage_min", ability_level -1)
	local ward_count = ability:GetLevelSpecialValueFor("ward_count", ability_level - 1)

	-- 考虑A杖
	if FindScepter(caster) then
		damage_max = ability:GetLevelSpecialValueFor("damage_max_scepter", ability_level -1)
		damage_min = ability:GetLevelSpecialValueFor("damage_min_scepter", ability_level -1)
		ward_count = ward_count * 2
	end

	-- 棒子单位表
	local ward_name = {
		"npc_dota_shadow_shaman_ward_1_imba",
		"npc_dota_shadow_shaman_ward_2_imba",
		"npc_dota_shadow_shaman_ward_3_imba"
	}
	-- 避免不必要的麻烦
	point = GetGroundPosition(point, caster)

	-- 循环创建ward_count个棒子
	for i=1,ward_count do
		print("trying to create ward")
		-- 异步创建单位
		CreateUnitByNameAsync(ward_name[ability_level], point, true, caster, caster, caster:GetTeam(),
			function(ward)
				print("ward created")
				-- 添加攻击分裂技能和死亡计时技能
				ward:AddAbility("shaman_ward_imba")
				ward:AddAbility("shaman_ward_life_time")
				local ability_attack = ward:FindAbilityByName("shaman_ward_imba")
				ability_attack:SetLevel(1)
				local ability_life = ward:FindAbilityByName("shaman_ward_life_time")
				ability_life:SetLevel(1)
				local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1)
				print("duration", duration)
				ability_life:ApplyDataDrivenModifier(ward, ward, "modifier_life_time", {Duration = duration})

				-- 设置最大和最小伤害
				ward:SetBaseDamageMax(damage_max)
				ward:SetBaseDamageMin(damage_min)
				
				-- 设置全局table表
				ward.ability = ability
				ward.owner = caster
				ward.attack_count = 0
				ward.create_time = GameRules:GetGameTime()
			end
		)
	end
end
function OnWardAttackLanded(keys)
	local caster = keys.caster
	caster.attack_count = caster.attack_count + 1
	-- 获取萨满的大招，keys.ability不正确，获取的是分裂攻击技能
	local ability = caster.ability
	-- 如果攻击次数大于6，则分裂
	if (caster.attack_count) > 6 then
		print("tring to create ward split")
		-- 获取原始棒子的owner
		local owner = caster.owner
		-- 异步创建一根棒子
		CreateUnitByNameAsync(caster:GetUnitName(), caster:GetOrigin(), true, owner, owner, owner:GetTeam(),
			function(ward)
				ward:AddAbility("shaman_ward_life_time")
				local ability_life = ward:FindAbilityByName("shaman_ward_life_time")
				ability_life:SetLevel(1)
				local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1)
				-- 分裂的棒子的持续时间要扣减原始棒子已经存在的时间
				duration = duration - (GameRules:GetGameTime() - caster.create_time)
				print("duration", duration)
				ability_life:ApplyDataDrivenModifier(ward, ward, "modifier_life_time", {Duration = duration})
			end
		)
		-- 重置攻击计数
		caster.attack_count = 0
	end
end