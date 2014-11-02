-- 这个文件里面是一些技能通用的东西
-- 比如说在单位身上查找A杖
-- 在某个位置播放某个粒子特效
-- 或者各种创建马甲释放各种技能
-- 注释很详细，慢慢看即可

-- 计算非连续Table里面的元素个数\
-- tbl: table 要计算的表单
--
function tableCount(tbl)
	count  = 0
	for _ in pairs(table) do
		count = count + 1
	end
	return count
end

-- 判定单位是否拥有阿哈利姆神杖
-- caster: 要判定的单位
-- 返回 true: 有神杖 false:没有神杖
--
function FindScepter(caster)
	for i = 0,5 do
		local item = caster:GetItemInSlot(i)
		if item then
			print(item:GetName())
			if item:GetName() == "item_ultimate_scepter" then
				return true
			end
		end
	end
	return false
end
-- 在某个位置播放一个粒子特效，其中target表示拥有这个特效的单位
-- particlename: string 粒子特效字符串 ***/****/****.vpcf
-- target: handle 单位
-- vec: Vector 三维坐标
--
function FireEffectAndRelease(particlename, target, vec )
	local p_index = ParticleManager:CreateParticle(particlename, PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl(p_index,0,vec)
	ParticleManager:ReleaseParticleIndex(p_index)
end

-- 为单位增加自定义的Modifier
-- caster, target: handle Modifier的来源和目标
-- ability: handle 拥有这个Modifier的自定义技能
-- modifier_name: string Modifier名称
-- duration: float or int 可选，Modifier的持续时间，nil时表示永久
-- 
function AddModifier(source, target, ability, modifier_name, duration)
	local modifier_data = {}
	if duration ~= nil and type(duration) ==  "number" and duration > 0 then
		modifier_data = {Duration = duration}
	end
	ability:ApplyDataDrivenModifier(source, target, modifier_name, modifier_data)
end

-- 为单位增加某个Modifier计数
-- source, target: handle Modifier来源和目标
-- ability: handle 技能实体
-- modifier_name: string Modifier名称
-- amount: int 增加数量
-- max_stack_count: int 最大堆叠数量
--
function InCreaseModifierStackCount(source, target, ability, modifier_name, amount, max_stack_count)
	local increase_amount = 1
	if amount ~= nil then
		increase_amount = amount
	end

	if not target:HasModifier(modifier_name) then
		AddModifier(source, target, ability, modifier_name, nil)
		if max_stack_count ~= nil then
			increase_amount = math.min(increase_amount, max_stack_count)
		end
		target:SetModifierStackCount(modifier_name, ability, increase_amount)
	else
		local modifier_count_original = target:GetModifierStackCount(modifier_name, ability)
		target:RemoveModifierByName(modifier_name)
		AddModifier(source, target, ability, modifier_name, nil)
		if max_stack_count ~= nil then
			increase_amount = math.min(modifier_count_original + increase_amount, max_stack_count)
		end
		target:SetModifierStackCount(modifier_name, ability, increase_amount)
	end
end

-- 在施法者的位置创建一个马甲，并对目标地点释放技能
-- owner: handle 马甲的所有者，一般为施法者
-- ability_name: string 所要释放的技能名称
-- ability_level: int 技能等级
-- position: Vector 释放位置
-- release_delay: float 马甲的排泄延迟，要注意，这个延迟应该比技能可能的持续时间长，否则可能直接导致游戏崩溃
-- scepter: OPTIONAL bool 是否给马甲创建A杖
--
function CreateDummyAndCastAbilityAtPosition(owner, ability_name, ability_level, position, release_delay, scepter)
	local dummy = CreateUnitByNameAsync("npc_dummy", owner:GetOrigin(), false, owner, owner, owner:GetTeam(),
		function(unit)
			print("unit created")
			unit:AddAbility(ability_name)
			unit:SetForwardVector((position - owner:GetOrigin()):Normalized())
			local ability = unit:FindAbilityByName(ability_name)
			ability:SetLevel(ability_level)
			ability:SetOverrideCastPoint(0)

			if scepter then
				local item = CreateItem("item_ultimate_scepter", unit, unit)	
				unit:AddItem(item)
			end

			unit:SetContextThink(DoUniqueString("cast_ability"),
				function()
					unit:CastAbilityOnPosition(position, ability, owner:GetPlayerID())
				end,
			0)
			unit:SetContextThink(DoUniqueString("Remove_Self"),function() print("removing dummy units", release_delay) unit:RemoveSelf() end, release_delay)

			return unit
		end
	)
end

-- 在施法者的位置创建一个马甲，并对指定的目标
-- owner: handle 马甲的所有者，一般为施法者
-- ability_name: string 所要释放的技能名称
-- ability_level: int 技能等级
-- target: handle 技能的释放目标
-- release_delay: float 马甲的排泄延迟，要注意，这个延迟应该比技能可能的持续时间长，否则可能直接导致游戏崩溃
-- scepter: OPTIONAL bool 是否给马甲创建A杖
--
function CreateDummyAndCastAbilityOnTarget(owner, ability_name, ability_level, target, release_delay, scepter)
	local dummy = CreateUnitByNameAsync("npc_dummy", owner:GetOrigin(), false, owner, owner, owner:GetTeam(),
		function(unit)
			print("unit created")
			unit:AddAbility(ability_name)
			unit:SetForwardVector((target:GetOrigin() - owner:GetOrigin()):Normalized())
			local ability = unit:FindAbilityByName(ability_name)
			ability:SetLevel(ability_level)
			ability:SetOverrideCastPoint(0)

			if scepter then
				local item = CreateItem("item_ultimate_scepter", unit, unit)	
				unit:AddItem(item)
			end

			unit:SetContextThink(DoUniqueString("cast_ability"),
				function()
					print("cast ability")
					unit:CastAbilityOnTarget(target,ability,owner:GetPlayerID())
				end,
			0)
			unit:SetContextThink(DoUniqueString("Remove_Self"),function() print("removing dummy units", release_delay) unit:RemoveSelf() end, release_delay)

			return unit
		end
	)
end

-- 在指定的位置创建一个马甲，并对目标地点释放技能
-- owner: handle 马甲的所有者，一般为施法者
-- ability_name: string 所要释放的技能名称
-- ability_level: int 技能等级
-- dummy_spawn_location: Vector 马甲创建的位置
-- position: Vector 释放位置
-- release_delay: float 马甲的排泄延迟，要注意，这个延迟应该比技能可能的持续时间长，否则可能直接导致游戏崩溃
-- scepter: OPTIONAL bool 是否给马甲创建A杖
--
function CreateDummyAtPositionAndCastAbilityAtPosition(owner, ability_name, ability_level, dummy_spawn_location, position, release_delay, scepter)
	local dummy = CreateUnitByNameAsync("npc_dummy", dummy_spawn_location, false, owner, owner, owner:GetTeam(),
		function(unit)
			print("unit created")
			unit:AddAbility(ability_name)
			unit:SetForwardVector((position - dummy_spawn_location):Normalized())
			local ability = unit:FindAbilityByName(ability_name)
			ability:SetLevel(ability_level)
			ability:SetOverrideCastPoint(0)

			if scepter then
				local item = CreateItem("item_ultimate_scepter", unit, unit)	
				unit:AddItem(item)
			end

			unit:SetContextThink(DoUniqueString("cast_ability"),
				function()
					unit:CastAbilityOnPosition(position, ability, owner:GetPlayerID())
				end,
			0)
			unit:SetContextThink(DoUniqueString("Remove_Self"),function() print("removing dummy units", release_delay) unit:RemoveSelf() end, release_delay)

			return unit
		end
	)
end

-- 在指定的位置创建一个马甲，并对指定的目标
-- owner: handle 马甲的所有者，一般为施法者
-- ability_name: string 所要释放的技能名称
-- ability_level: int 技能等级
-- position: Vector 马甲的创建位置
-- target: handle 技能的释放目标
-- release_delay: float 马甲的排泄延迟，要注意，这个延迟应该比技能可能的持续时间长，否则可能直接导致游戏崩溃
-- scepter: OPTIONAL bool 是否给马甲创建A杖
--
function CreateDummyAtPositionAndCastAbilityOnTarget(owner, ability_name, ability_level, position, target, release_delay, scepter)
	local dummy = CreateUnitByNameAsync("npc_dummy", position, false, owner, owner, owner:GetTeam(),
		function(unit)
			print("unit created")
			unit:AddAbility(ability_name)
			unit:SetForwardVector((target:GetOrigin() - owner:GetOrigin()):Normalized())
			local ability = unit:FindAbilityByName(ability_name)
			ability:SetLevel(ability_level)
			ability:SetOverrideCastPoint(0)

			if scepter then
				local item = CreateItem("item_ultimate_scepter", unit, unit)	
				unit:AddItem(item)
			end

			unit:SetContextThink(DoUniqueString("cast_ability"),
				function()
					print("cast ability")
					unit:CastAbilityOnTarget(target,ability,owner:GetPlayerID())
				end,
			0)
			unit:SetContextThink(DoUniqueString("Remove_Self"),function() print("removing dummy units", release_delay) unit:RemoveSelf() end, release_delay)

			return unit
		end
	)
end

-- 在指定的位置创建一个马甲，并释放一个无目标技能
-- owner: handle 马甲的所有者，一般为施法者
-- ability_name: string 所要释放的技能名称
-- ability_level: int 技能等级
-- position: Vector 马甲的创建位置
-- release_delay: float 马甲的排泄延迟，要注意，这个延迟应该比技能可能的持续时间长，否则可能直接导致游戏崩溃
-- scepter: OPTIONAL bool 是否给马甲创建A杖
--
function CreateDummyAtPositionAndCastAbilityNoTarget(owner, ability_name, ability_level, position, release_delay, scepter)
	local dummy = CreateUnitByNameAsync("npc_dummy", position, false, owner, owner, owner:GetTeam(),
		function(unit)
			print("unit created")
			unit:AddAbility(ability_name)
			unit:SetForwardVector((position - owner:GetOrigin()):Normalized())
			local ability = unit:FindAbilityByName(ability_name)
			ability:SetLevel(ability_level)
			ability:SetOverrideCastPoint(0)

			if scepter then
				local item = CreateItem("item_ultimate_scepter", unit, unit)	
				unit:AddItem(item)
			end

			unit:SetContextThink(DoUniqueString("cast_ability"),
				function()
					unit:CastAbilityNoTarget(ability, owner:GetPlayerID())
				end,
			0)
			unit:SetContextThink(DoUniqueString("Remove_Self"),function() print("removing dummy units", release_delay) unit:RemoveSelf() end, release_delay)

			return unit
		end
	)
end