-- storm_spirit_overload
-- storm_spirit_ball_lightning
-- storm_spirit_electric_vortex
-- storm_spirit_static_remnant

function CreateRemantAtPosition(caster, ability_remant, pos)
	caster:SetOrigin(pos)
	ability_remant:SetOverrideCastPoint(0)
	print(ability_remant:IsFullyCastable())
	caster:SetContextThink(DoUniqueString("cast_ability"),
		function()
			caster:CastAbilityNoTarget(ability_remant, caster:GetPlayerID())
		end,
	0)
end

function OnRemantStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not (caster and ability) then return end

	caster:AddNewModifier(caster, nil, "modifier_rooted", {})
	caster:AddNewModifier(caster, nil, "modifier_invulnerable", {})	
	local ability_level = ability:GetLevel()
	local ability_remant = caster:FindAbilityByName("storm_spirit_static_remnant")
	ability_remant:SetLevel(ability_level)

	local caster_origin = caster:GetOrigin()

	local caster_fv = caster:GetForwardVector()
	local caster_qangle = VectorToAngles(caster_fv)	
	caster_qangle.y = caster_qangle.y - 90
	print(caster_qangle)

	local ori_qixing = {
		Vector( 0.0, 0.0, 0 ),
		Vector( -51.8, 113.0, 0 ),
		Vector( -25.3, 207.0, 0 ),
		Vector( 0.0, 316.5, 0 ),
		Vector( 85.7, 365.0, 0 ),
		Vector( 47.2, 474.5, 0 ),
		Vector( -65.2, 474.5, 0 )
	}
	local qixing = {}
	for k, vec in pairs(ori_qixing) do
		vec = (vec * 3) + caster_origin
		vec = RotatePosition(caster_origin,caster_qangle,vec)
		table.insert(qixing,vec)
	end
	
	for i=1,7 do
		caster:SetContextThink(DoUniqueString("release_remant"), function()
				local result_pos = qixing[i]
				print("REMANT_POS",result_pos)
				CreateRemantAtPosition(caster, ability_remant, result_pos)

				if i == 7 then
					caster:SetContextThink(DoUniqueString("this_is_fucked"),function()
					FindClearSpaceForUnit(caster, caster_origin, true) end,0.1)
				end
			end,
		i*0.1)
	end

	caster:RemoveModifierByName("modifier_rooted")
	caster:RemoveModifierByName("modifier_invulnerable")
end

function OnOverloadAttackLanded(keys)

end