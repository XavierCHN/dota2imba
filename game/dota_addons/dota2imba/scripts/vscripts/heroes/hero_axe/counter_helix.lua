--[[Author: Pizzalol
	Date: 09.02.2015.
	Triggers when the unit attacks
	Checks if the attack target is the same as the caster
	If true then trigger the counter helix if its not on cooldown]]
function CounterHelix( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local helix_modifier = keys.helix_modifier

	local trigger_chance_base = ability:GetLevelSpecialValueFor("trigger_chance", ability:GetLevel() - 1)
	local trigger_chance_per_agi =  ability:GetLevelSpecialValueFor("trigger_chance_per_agi", ability:GetLevel() - 1)
	local trigger_chance_bonus = caster:GetAgility() * trigger_chance_per_agi
	local random_val = RandomInt(0,100)

	if ( random_val < trigger_chance_base + trigger_chance_bonus) then
		print("counter helix not triggered", random_val, trigger_chance_base , trigger_chance_bonus )
		return
	end

	-- If the caster has the helix modifier then do not trigger the counter helix
	-- as its considered to be on cooldown
	if target == caster and not caster:HasModifier(helix_modifier) then
		ability:ApplyDataDrivenModifier(caster, caster, helix_modifier, {})
	end
end