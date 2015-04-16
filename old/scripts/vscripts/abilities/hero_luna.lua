require("abilities/ability_generic")

function OnLucentBeam(keys)
	print("on luna lucent beam")

	local caster = keys.caster
	local target = keys.target_entities[1]
	local ability = keys.ability
	local success = caster and target and ability
	if not success then return end

	local aura_radius = ability:GetLevelSpecialValueFor("aura_radius", ability:GetLevel() -1)

	npc_owner = caster
	if caster:GetUnitName() == "npc_dummy" then
		npc_owner = caster:GetOwner()
	end
	
	if not target:HasModifier("modifier_luna_lucent_beam_imba") then
		ability:ApplyDataDrivenModifier(target, target, "modifier_luna_lucent_beam_imba", {})
		target:SetModifierStackCount("modifier_luna_lucent_beam_imba",ability,1)
	else
		local modifier_count = target:GetModifierStackCount("modifier_luna_lucent_beam_imba",ability)
		target:SetModifierStackCount("modifier_luna_lucent_beam_imba",ability,math.min(modifier_count + 1,10))
	end

	local all_heroes = FindUnitsInRadius(target:GetTeam(), target:GetOrigin(), nil, aura_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, unit in pairs(all_heroes) do
		if not unit:HasModifier("modifier_luna_lucent_beam_imba_attack_bonus") then
			ability:ApplyDataDrivenModifier(target, unit, "modifier_luna_lucent_beam_imba_attack_bonus", {})
			unit:SetModifierStackCount("modifier_luna_lucent_beam_imba_attack_bonus",ability,1)
		else
			local modifier_count = unit:GetModifierStackCount("modifier_luna_lucent_beam_imba_attack_bonus",ability)
			print(modifier_count)
			unit:RemoveModifierByName("modifier_luna_lucent_beam_imba_attack_bonus")
			ability:ApplyDataDrivenModifier(unit, unit, "modifier_luna_lucent_beam_imba_attack_bonus", {})
			unit:SetModifierStackCount("modifier_luna_lucent_beam_imba_attack_bonus",ability,math.min(modifier_count + 1,10))
		end
	end
	CreateDummyAndCastAbilityOnTarget(npc_owner, "luna_lucent_beam", ability:GetLevel(), target, 2, false)
end
function OnLunaEclipseStart(keys)
	local caster = keys.caster
	caster:SetContext("beam_count","0",0)
	OnLunaEclipse(keys)
end
function OnLunaEclipse(keys)
	local caster = keys.caster
	local beam_count = tonumber(caster:GetContext("beam_count") or "0")
	local ability = keys.ability
	local eclipse_radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1)

	local enemy_heroes = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, eclipse_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	local target = nil
	print("enemies count",#enemy_heroes)
	if #enemy_heroes > 0 then
		target = enemy_heroes[RandomInt(1, #enemy_heroes)]
	end
	if target ~= nil then
		CreateDummyAndCastAbilityOnTarget(caster, "luna_lucent_beam_imba", ability:GetLevel(), target, 2, false)
	end

	local beam_count = beam_count + 1
	local max_beam = ability:GetLevelSpecialValueFor("beams", ability:GetLevel() - 1)
	if beam_count >= max_beam then
		caster:RemoveModifierByName("modifier_luna_eclipse_imba")
	end
	caster:SetContext("beam_count",tostring(beam_count),0)
end
function OnLunaBlessingCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not (caster and ability) then return end
	local ability_lucent = caster:FindAbilityByName("luna_lucent_beam_imba")
	if not ability_lucent then return end
	if ability_lucent:GetLevel() < 1 then return end

	local lucent_stack = caster:GetModifierStackCount("modifier_luna_lucent_beam_imba_attack_bonus",ability_lucent)
	print("LUCENT STACK", lucent_stack)
	if lucent_stack == nil then lucent_stack = 1 end
	if lucent_stack < 1 then lucent_stack = 1 end
	
	if caster:HasModifier("modifier_luna_blessing_per_lucent")	then
		caster:RemoveModifierByName("modifier_luna_blessing_per_lucent")
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_luna_blessing_per_lucent", {})
	caster:SetModifierStackCount("modifier_luna_blessing_per_lucent",ability,lucent_stack)
end