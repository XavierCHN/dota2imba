function tableCount(table)
	count  = 0
	for _ in pairs(table) do
		count = count + 1
	end
	return count
end

function FireEffectAndRelease(particlename, target, vec )
	local p_index = ParticleManager:CreateParticle(particlename, PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl(p_index,0,vec)
	ParticleManager:ReleaseParticleIndex(p_index)
end

function GrabKeysWithTarget(keys)
	local caster = keys.caster
	local target = keys.target_entities[1]
	local ability = keys.ability
	local success = caster and target and ability
	return caster, target, ability, success
end
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

-- return the dummy unit
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