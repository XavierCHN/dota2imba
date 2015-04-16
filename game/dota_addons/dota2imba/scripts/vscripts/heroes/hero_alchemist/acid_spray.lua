--[[
	Author: Noya
	Date: 9.1.2015.
	Plays a looping and stops after the duration
]]
function AcidSpraySound( event )
	local target = event.target
	local ability = event.ability
	local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )

	target:EmitSound("Hero_Alchemist.AcidSpray")

	-- Stops the sound after the duration, a bit early to ensure the thinker still exists
	Timers:CreateTimer(duration-0.1, function() 
		target:StopSound("Hero_Alchemist.AcidSpray") 
	end)

end
-- 每在酸雾里面多待一秒，那么多叠加一层
function AcidSprayThinkInterval( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	if not target:HasModifier("modifier_acid_spray_stack") then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_acid_spray_stack", {})
	else
		local stackCount = target:GetModifierStackCount("modifier_acid_spray_stack",ability)
		target:SetModifierStackCount("modifier_acid_spray_stack",ability,stackCount + 1)
	end
end