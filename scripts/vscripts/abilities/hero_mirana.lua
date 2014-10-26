require('abilities/ability_generic')
function OnMiranaArrowStart(keys)
	local caster = keys.caster
	local caster_origin = caster:GetOrigin()
	caster:SetContext("arrow_start_pos_x",tostring(caster_origin.x),0)
	caster:SetContext("arrow_start_pos_y",tostring(caster_origin.y),0)
end

function OnMiranaArrowHitUnit(keys)
	local caster = keys.caster
	local target = keys.target_entities[1]
	local ability = keys.ability
	if not (caster and target and ability) then return end

	local stun_duration_base = ability:GetLevelSpecialValueFor("arrow_min_stun", ability:GetLevel() -1)
	local stun_duration_increase_per_100 = ability:GetLevelSpecialValueFor("stun_time_increase_per_100", ability:GetLevel() -1)
	local damage_increase_per_100 = ability:GetLevelSpecialValueFor("arrow_damage_per_100", ability:GetLevel() -1)

	local target_pos = target:GetOrigin()
	local arrow_start_x = tonumber(caster:GetContext("arrow_start_pos_x") or caster:GetOrigin().x)
	local arrow_start_y = tonumber(caster:GetContext("arrow_start_pos_y") or caster:GetOrigin().y)

	local arrow_start_pos = Vector(arrow_start_x, arrow_start_y, caster:GetOrigin().z)
	print("START POS",arrow_start_pos)
	print("END POS",target_pos)

	local arrow_travel_distance = (target_pos - arrow_start_pos):Length2D()
	print("ARROW TRAVEL DISTANCE", arrow_travel_distance)
	local arrow_damage = damage_increase_per_100 * arrow_travel_distance / 100
	local arrow_stun_duration = stun_duration_base + (stun_duration_increase_per_100 * arrow_travel_distance / 100)
	print("CALCULATION RESULT: ", arrow_damage, arrow_stun_duration)

	local damage_dealt = ApplyDamage({
		victim = target,
		attacker = caster,
		damage = arrow_damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage_flags = 0,
		ability = ability
	})
	ability:ApplyDataDrivenModifier(caster, target, "modifier_mirana_arrow_stun", {Duration = arrow_stun_duration})
	print("DAMAGE DEALT", damage_dealt)
end

function OnStarFallStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not (caster and ability) then return end

	local starfall_radius = ability:GetLevelSpecialValueFor("starfall_radius", ability:GetLevel() -1)
	local starfall_damage_base = ability:GetLevelSpecialValueFor("starfall_base_damage", ability:GetLevel() -1)
	local starfall_healthdamage_percentage = ability:GetLevelSpecialValueFor("starfall_healthdamage_percentage", ability:GetLevel() -1)
	local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, starfall_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, unit in pairs(enemies) do
		local unit_health = unit:GetMaxHealth()
		local starfall_damage = starfall_damage_base + unit_health * starfall_healthdamage_percentage / 100
		print("CALCULATE RESULT", starfall_damage)

		local damage_dealt =  ApplyDamage({
			victim = unit,
			attacker = caster,
			damage = starfall_damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			damage_flags = 0,
			ability = ability
		})
		FireEffectAndRelease("particles/units/heroes/hero_mirana/mirana_starfall_attack.vpcf", unit, unit:GetOrigin())
		unit:EmitSound("Ability.StarfallImpact")
		print("STAR FALL DAMAGE UNIT", unit:GetUnitName(), damage_dealt)
	end
	print(GameRules:GetGameTime())
	caster:SetContextThink(DoUniqueString(""),function()
		print("ON DELAYED ACTION")
		local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, starfall_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		print(GameRules:GetGameTime())
		if #enemies < 1 then return end
		local unit = enemies[RandomInt(1,#enemies)]
		
		local unit_health = unit:GetMaxHealth()
		local starfall_damage = starfall_damage_base + unit_health * starfall_healthdamage_percentage / 100
		local damage_ratio = ability:GetLevelSpecialValueFor("starfall_secondary_damage_creeps_percentage", ability:GetLevel() -1)
		if unit:IsRealHero() then
			damage_ratio = ability:GetLevelSpecialValueFor("starfall_secondary_damage_heroes_percentage", ability:GetLevel() -1)
		end
		starfall_damage = damage_ratio * starfall_damage / 100
		print("CALCULATE RESULT", starfall_damage)
		local damage_dealt =  ApplyDamage({
			victim = unit,
			attacker = caster,
			damage = starfall_damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			damage_flags = 0,
			ability = ability
		})
		FireEffectAndRelease("particles/units/heroes/hero_mirana/mirana_starfall_attack.vpcf", unit, unit:GetOrigin())
		unit:EmitSound("Ability.StarfallImpact")
		print("STAR FALL DAMAGE UNIT SECONDARY", unit:GetUnitName(), damage_dealt)
		end,
	0.8)
end