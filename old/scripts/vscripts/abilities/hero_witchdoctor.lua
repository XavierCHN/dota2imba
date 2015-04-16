require('abilities/ability_generic')

-- 生咒 —— 施法
-- 
function OnMaledictGoodCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	if not (caster and ability and point) then return end
	
	-- 技能的影响范围
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() -1)
	
	-- 获取范围内的友方单位
	local friends = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	
	-- 将这些单位储存到table中
	GameRules._WitchDoctorMaledictFriendHeroes = friends

	-- 保存释放该技能的时候的生命值
	for _, hero in pairs(friends) do
		local health = hero:GetHealth()
		hero:SetContext("health_orignal",tostring(health),0)
	end

	-- 播放粒子特效
	local p_index = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_maledict_good.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(p_index, 0, point)
	caster:SetContextThink(DoUniqueString("release_particle"),function()
		ParticleManager:DestroyParticle(p_index,true)
		ParticleManager:ReleaseParticleIndex(p_index)
	end,1.0)
end
-- 生咒 —— 计时
-- 
function OnMaledictGoodIntervalThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	for key , hero in pairs(GameRules._WitchDoctorMaledictFriendHeroes) do
		if hero:IsAlive() then
			local health = hero:GetHealth()
			local health_original = tonumber(hero:GetContext("health_orignal") or "0")
			local health_lost = 	health_original - 	health
			print("HEALTH_LOST",health_lost)
			local heal_base = ability:GetLevelSpecialValueFor("heal_base", ability:GetLevel() -1)
			local heal_per_100_damage = ability:GetLevelSpecialValueFor("heal_per_100_damage", ability:GetLevel() -1)

			local heal = heal_base + heal_per_100_damage * health_lost / 100
			print("HEAL",heal)
			hero:Heal(heal, caster)
		else
			print("hero dead!")
			GameRules._WitchDoctorMaledictFriendHeroes.key = nil
		end
	end
end

-- 创建马甲并在指定位置释放大招
-- 因为需要处理打断的问题，所以无法使用通用的马甲
-- 
function CreateDummyAndCastDeathWard(caster, ability, position, point, scepter)
	local dummy = CreateUnitByNameAsync("npc_dummy", caster:GetOrigin(), false, caster, caster, caster:GetTeam(),
		function(unit)
			print("unit created")
			unit:AddAbility("witch_doctor_death_ward")
			unit:SetForwardVector((position - caster:GetOrigin()):Normalized())
			local ability_death_ward = unit:FindAbilityByName("witch_doctor_death_ward")
			ability_death_ward:SetLevel(ability:GetLevel())
			ability_death_ward:SetOverrideCastPoint(0)

			if scepter then
				print("CREATING SCEPTER FOR DUMMY UNITS")
				local item = CreateItem("item_ultimate_scepter", unit, unit)	
				unit:AddItem(item)
			end

			unit:SetContextThink(DoUniqueString("cast_ability"),function()
				unit:CastAbilityOnPosition(position, ability_death_ward, caster:GetPlayerID())
				end,
			0)
			unit:SetContextThink(DoUniqueString("Remove_Self"),function() unit:RemoveSelf() end,20)
			if position == point then
				caster:SetContext("original_ward_unit_entindex",tostring(unit:entindex()),0)
			end
		end
	)
end

-- 死亡守卫 —— 施法
-- 
function OnDeathWardCast(keys)
	print("DEATH WARD CASTED")
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	for k,v in pairs(keys.target_points) do
		print(k,v)
	end
	if not (caster and ability and point) then return end

	local caster_origin = caster:GetOrigin()
	print(caster_origin)
	local caster_fv = caster:GetForwardVector()
	local angle_left = QAngle(0, -10, 0)
	local angle_right = QAngle(0, 10, 0)
	local pos_left = RotatePosition(caster_origin,angle_left,point)
	local pos_right = RotatePosition(caster_origin,angle_right,point)

	local scepter = FindScepter(caster)

	CreateDummyAndCastDeathWard(caster, ability, caster:GetOrigin() + (pos_left - caster:GetOrigin()) * 1.2, point, scepter)
	CreateDummyAndCastDeathWard(caster, ability, caster:GetOrigin() + (pos_right - caster:GetOrigin()) * 1.2, point, scepter)
	CreateDummyAndCastDeathWard(caster, ability, point, point, scepter)
end

function OnDeathWardInterrupted(keys)
	local caster = keys.caster
	local entindex = tonumber(caster:GetContext("original_ward_unit_entindex"))
	local unit = EntIndexToHScript(entindex)
	if not(unit:GetUnitName() == "npc_dummy") then print("Wrong Entity") return end

	unit:Stop()
end