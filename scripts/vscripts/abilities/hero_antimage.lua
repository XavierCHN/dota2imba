-- [[API]]
--- self[target_name]:CastedAbilityHandler(target, source, ability, keys)
--- self[hero_name]:CastAbilityOnTargetHandler(source, target, ability_name, ability, keys)
--- self[hero_name]:CastAbilityAtPositionHandler(hero, target_position, ability, keys)
--- self[hero_name]:CastAbilityNoTargetHandler(hero, ability)
--- self[hero_name]:LearnAbilityHandler(keys, hero, keys.abilityname)
--- self[hero_name]:GeneralCastAbilityHandler(hero, ability)
-- [[API]]


require("abilities/ability_generic")

if AbilityCore.npc_dota_hero_antimage == nil then
	AbilityCore.npc_dota_hero_antimage = class({})
end
-- self[target_name]:CastedAbilityHandler(keys, hero, ability, ability_target, ability_name)
function AbilityCore.npc_dota_hero_antimage:CastedAbilityHandler(antimage, source, ability, keys)
	-- 当敌法师被释放一个指向性技能

	-- 眩晕持续时间表
	local stun_duration = {0, 1, 1.5, 2, 2.5}
	-- 眩晕间隔
	local trigger_cooldown = {0, 4, 5, 6, 7}

	-- 获取魔法盾的等级
	local ability_spell_shield = antimage:FindAbilityByName("antimage_spell_shield")
	local ability_level = ability_spell_shield:GetLevel()

	-- 百分比概率，如果成功，就给单位添加被眩晕的状态
	local chance = 5
	if RandomInt(1,100) < chance then
		source:AddNewModifier(antimage,source,"modifier_stunned",{Duration = stun_duration[ability_level + 1]})
		antimage:SetContext("spell_shield_triggered", "true", trigger_cooldown[ability_level])
	end
end

-- 法力损毁 —— 攻击到位
--
function OnManaBreakAttackLanded(keys)
	print("[ANTIMAGE:] ON IMBA MANA BREAK ATTACK LANDED")
	-- 施法者
	local caster = keys.caster
	-- 技能
	local ability = keys.ability 
	-- 目标单位
	local target = keys.target_entities[1]
	-- 确保各种数据有效
	if not(caster and ability and target) then return end

	-- 基础魔法损毁数值
	local mana_per_hit = ability:GetLevelSpecialValueFor("mana_per_hit", ability:GetLevel() - 1)
	-- 百分比魔法损毁数值
	local mana_percentage_per_hit = ability:GetLevelSpecialValueFor('mana_percentage_per_hit', ability:GetLevel() -1)
			/ 100
	-- 目标魔法总量
	local target_mana = target:GetMana()
	-- 要损毁的魔法值
	local mana_to_burn = mana_per_hit + mana_percentage_per_hit * target_mana
	-- 损毁系数
	local damage_ratio = ability:GetLevelSpecialValueFor('damage_per_burn', ability:GetLevel() -1)
	local bonus_damage = 0
	-- 当魔法值不足
	if target_mana < mana_to_burn then
		-- 设置魔法为0
		target:SetMana(0)
		-- 计算额外伤害
		bonus_damage = mana_to_burn - target_mana
	else
		target:SetMana(target_mana - mana_to_burn)
	end
	-- 计算要造成的伤害并造成伤害
	local damage_to_deal = damage_ratio * mana_to_burn + bonus_damage
	local damage_dealt = ApplyDamage({
		victim = target,
		attacker = caster,
		damage = damage_to_deal,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		damage_flags = 0,
		ability = ability
	})
	-- 播放特效和音效
	target:EmitSound("Hero_Antimage.ManaBreak")
	FireEffectAndRelease("particles/generic_gameplay/generic_manaburn.vpcf", target , target:GetOrigin())
end

-- 闪烁 —— 释放
-- 
function OnAntiMageBlink(keys)
	-- 施法者
	local caster = keys.caster
	-- 目标地点
	local point = keys.target_points[1]
	-- 技能
	local ability = keys.ability
	-- 最大闪烁距离
	local max_range = ability:GetLevelSpecialValueFor("blink_range", ability:GetLevel() -1)
	-- 最小闪烁距离
	local min_range = ability:GetLevelSpecialValueFor("min_blink_range", ability:GetLevel() -1)
	-- 计算闪烁方向
	local direction = (point - caster:GetOrigin()):Normalized()
	-- 避免点击方向和英雄完全重合的情况，当出现这种情况，则方向为英雄所面向的方向
	if direction == Vector(0,0,0) then direction = caster:GetForwardVector() end
	-- 计算闪烁距离 - 点击地点和最大闪烁距离之间的相对小值，并且要大于最小距离
	local target_length = math.max(math.min((point - caster:GetOrigin()):Length2D(), max_range), min_range)
	-- 计算目标地点
	local target_point = caster:GetOrigin() + ( direction * target_length )
	-- 播放特效并移动英雄到目标地点
	FireEffectAndRelease("particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", caster, caster:GetOrigin())
	caster:EmitSound('Hero_Antimage.Blink_out')
	FindClearSpaceForUnit(caster, target_point, true)
	caster:EmitSound('Hero_Antimage.Blink_in')
	FireEffectAndRelease("particles/units/heroes/hero_antimage/antimage_blink_end.vpcf", caster, caster:GetOrigin())
	-- 获取法力虚空的范围
	local mana_void_range = ability:GetLevelSpecialValueFor("mana_void_range", ability:GetLevel() -1)
	-- 获取法力虚空的持续时间
	local mana_void_duration = ability:GetLevelSpecialValueFor("mana_void_duration", ability:GetLevel() -1)
	-- 获取闪烁路径上的敌方单位
	local nearest_enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, mana_void_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MANA_ONLY, FIND_ANY_ORDER, false)
	-- 循环所有敌方单位
	for _, unit in pairs(nearest_enemies) do
		-- 储存单位的魔法值
		local hero_mana = unit:GetMana()
		-- 清空
		unit:SetMana(0)
		-- 播放粒子特效
		FireEffectAndRelease("particles/generic_gameplay/generic_manaburn.vpcf", unit, unit:GetOrigin())
		-- 一定时间(mana_void_duration)之后，返回魔法值
		unit:SetContextThink(DoUniqueString('restore_mana'),
			function()
				unit:SetMana(hero_mana)
			end,
		mana_void_duration)
	end
end

-- 法力虚空 —— 释放
-- 
function OnManaVoidCasted(keys)
	-- 施法者
	local caster = keys.caster
	-- 目标
	local target = keys.target_entities[1]
	-- 技能
	local ability = keys.ability
	-- 法力虚空范围
	local range = ability:GetLevelSpecialValueFor('radius', ability:GetLevel() -1)
	-- 获取法力虚空作用范围内的单位
	local enemy_heroes = FindUnitsInRadius(caster:GetTeam(), target:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	-- 循环单位表
	for _, hero in pairs(enemy_heroes) do
		-- 判断敌方是否为智力型英雄
		if hero:GetPrimaryAttribute() == 2 then -- 2 for 智力
			-- 如果是，则牵引到法力虚空中心
			FindClearSpaceForUnit(hero, target:GetOrigin(), false)
		end
	end
	-- 创建马甲并释放技能
	CreateDummyAndCastAbilityOnTarget(caster, "antimage_mana_void", ability:GetLevel(), target, 1, false)

	ScreenShake(target:GetOrigin(), 20, 0.1, 1, 1000, 0, true)

end

-- 法力虚空 —— 被动攻击
-- 
function OnManaVoidAttackLanded(keys)
	print("[ANTIMAGE:] ON MANA VOID ATTACK LANDED -> CALLED")
	-- 施法者
	local caster = keys.caster
	-- 目标
	local target = keys.target_entities[1]
	local ability = keys.ability
	
	if not(caster and ability and target) then return end
	if not (target:IsRealHero()) then return end
	if target:GetTeam() == caster:GetTeam() then return end
	if target:GetPrimaryAttribute()	~= 2 then return end -- 如果对方不是智力型英雄，就不做啥
	
	-- 创建马甲并释放技能
	CreateDummyAndCastAbilityOnTarget(caster, "antimage_mana_void", ability:GetLevel(), target, 1, false)
end