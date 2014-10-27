-- doom_bringer_devour
-- doom_bringer_doom
require('abilities/ability_generic')

function OnDevourCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target_entities[1]
	if not(caster and ability and target) then return end

	-- 替换为初始技能
	local ability_sub_1 = caster:GetAbilityByIndex(3) --TODO??
	print(ability_sub_1:GetAbilityName())
	local ability_sub_2 = caster:GetAbilityByIndex(4)
	print(ability_sub_2:GetAbilityName())
	
	-- 初始化变量
	local ability_to_swap_1 = nil
	local ability_to_swap_2 = nil
	local ability_level_1 = 1
	local ability_level_2 = 1

	if target:IsIllusion() then
		-- 秒杀幻像
		ApplyDamage({
			victim = target, attacker = caster, 
			damage = target:GetHealth(), damage_type = DAMAGE_TYPE_PURE, 
			damage_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			ability = ability
		})
		return
	end

	local ban_units = {
		"npc_dota_lone_druid_bear"
	}
	for _, name in pairs(ban_units) do
		if string.find(target:GetUnitName() ,name) then return end
	end

	-- 如果吞噬的目标是英雄？
	if target:IsRealHero() then
		local target_abilities = {}
		for i = 0,15 do
			local ability = target:GetAbilityByIndex(i)
			if ability then table.insert(target_abilities,ability) end
		end
		ability_to_swap_1 = target_abilities[RandomInt(1,#target_abilities)]
		while ability_to_swap_1:GetAbilityName() == "attribute_bonus" do
			ability_to_swap_1 = target_abilities[RandomInt(1,#target_abilities)]
		end
		ability_level_1 = ability_to_swap_1:GetLevel()
		if ability_level_1 < 1 then ability_level_1 = 1 end
	else
		-- 如果不是英雄
		ability_to_swap_1 = target:GetAbilityByIndex(0)
		ability_to_swap_2 = target:GetAbilityByIndex(1)

		-- 击杀单位并立即获得赏金
		local bonus_gold = ability:GetLevelSpecialValueFor("bonus_gold", ability:GetLevel() - 1)

		ApplyDamage({
			victim = target, attacker = caster, 
			damage = target:GetHealth(), damage_type = DAMAGE_TYPE_PURE, 
			damage_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			ability = ability
		})
		caster:ModifyGold(bonus_gold, false, 0)
	end

	-- 如果目标没有技能，不进行技能替换操作
	if ability_to_swap_1 == nil and ability_to_swap_2 == nil then return end

	-- 移除之前的技能
	caster:SwapAbilities(ability_sub_1:GetAbilityName(),"doom_bringer_empty1",false,true)
	caster:SwapAbilities(ability_sub_2:GetAbilityName(),"doom_bringer_empty2",false,true)
	if ability_sub_1:GetAbilityName() ~= "doom_bringer_empty1" then caster:RemoveAbility(ability_sub_1:GetAbilityName()) end
	if ability_sub_2:GetAbilityName() ~= "doom_bringer_empty2" then caster:RemoveAbility(ability_sub_2:GetAbilityName()) end


	-- 添加技能并设置等级
	-- 技能1
	if ability_to_swap_1 then
		ability_to_swap_1 = ability_to_swap_1:GetAbilityName()
		print("swaping ability",ability_to_swap_1)
		caster:AddAbility(ability_to_swap_1)
		caster:SwapAbilities("doom_bringer_empty1",ability_to_swap_1,false,true)

		local ability = caster:FindAbilityByName(ability_to_swap_1)
		if ability then ability:SetLevel(ability_level_1) end
	end
	-- 技能2
	if ability_to_swap_2 then
		ability_to_swap_2 = ability_to_swap_2:GetAbilityName()
		caster:AddAbility(ability_to_swap_2)
		caster:SwapAbilities("doom_bringer_empty2",ability_to_swap_2,false,true)
		local ability = caster:FindAbilityByName(ability_to_swap_2)
		if ability then ability:SetLevel(ability_level_2) end
	end
end

function OnDoomCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target_entities[1]
	if not(caster and ability and target) then return end

	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1)
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1)

	local enemies = FindUnitsInRadius(caster:GetTeam(), target:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for _, unit in pairs(enemies) do
		CreateDummyAndCastAbilityOnTarget(caster, "doom_bringer_doom", ability:GetLevel(), unit, duration + 60, FindScepter(caster))
	end
end