-- 当亚巴顿杀死一个单位之后，如果单位有魔剑BUFF，那么创建一个幻想
function OnAbaddonKill(keys)
	print("Abaddon kills an unit")
	for k,v in pairs(keys) do
		print(k,v)
	end
	local caster = keys.caster
	local target = keys.unit
	if target:HasModifier("modifier_frostmourne_debuff") then
		local illusion = CreateUnitByName(target:GetUnitName(), target:GetOrigin(), true, caster, nil,caster:GetTeamNumber())
		if illusion.SetPlayerID then
			illusion:SetPlayerID(caster:GetPlayerID())
		end
		illusion:SetControllableByPlayer(caster:GetPlayerID(), true)
		local targetLevel = target:GetLevel()
		if targetLevel > 1 then
			for i = 1, targetLevel-1 do
				if illusion.HeroLevelUp then
					illusion:HeroLevelUp(false)
				end
			end
		end

		if illusion.SetAbilityPoints then
			illusion:SetAbilityPoints(0)
		end

		for abilitySlot = 0,15 do
			local abiltity = target:GetAbilityByIndex(abilitySlot)
			if ability and ability:GetLevel() >1 then
				local abilityLevel = ability:GetLevel()
				local abilityName = ability:GetAbilityName()
				local illusionAbility = illusion:FindAbilityByName(abilityName)
				illusionAbility:SetLevel(abilityLevel)
			end
		end

		illusion:AddNewModifier(caster, ability, "modifier_illusion",{duration = 40})
		illusion:MakeIllusion()
	end
end