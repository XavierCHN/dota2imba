require("abilities/ability_generic")

function OnCounterHelixAttacked(keys)
	print("[AXE:] ON COUNTER HELIX TAKE DAMAGE ->")
	local caster = keys.caster
	local ability = keys.ability
	local chance = ability:GetLevelSpecialValueFor('trigger_chance', ability:GetLevel())
	local bonus_chance = ability:GetSpecialValueFor("chance_per_strength")
	local strength_value = caster:GetStrength()
	local radius = ability:GetSpecialValueFor("radius")
	local damage = ability:GetLevelSpecialValueFor('damage', ability:GetLevel())

	local total_chance = chance + bonus_chance * strength_value
	local random_result = RandomInt(1,100)
	print("[AXE:] COUNTER HELIX CALLED WITH A CHANCE OF",total_chance, chance, bonus_chance,"Result",random_result)
	if  random_result < total_chance then
		print("[AXE: COUNTER HELIX CALLED -> SUCCESS!]")
		caster:EmitSound("Hero_Axe.CounterHelix")
		FireEffectAndRelease("particles/units/heroes/hero_axe/axe_attack_blur_counterhelix.vpcf", caster, caster:GetOrigin())
		local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, unit in pairs(enemies) do
			local damage_dealt = ApplyDamage({
				victim = unit,
				attacker = caster,
				damage = damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				damage_flags = 0,
				ability = ability
			})
			print("DAMAGE DEALT", damage_dealt, unit:GetUnitName())
		end
	end
end

function OnImbaBattleHungerStart(keys)
	local caster = keys.caster
	local target = keys.target_entities[1]
	local ability = keys.ability
	if not (caster and target and ability) then return end
	caster:SetContext("new_created","yes",0)
	npc_owner = caster
	if caster:GetUnitName() == "npc_dummy" then
		npc_owner = caster:GetOwner()
	end
	
	local dummy_unit = CreateUnitByNameAsync("npc_dummy", npc_owner:GetOrigin() + Vector(0,0,150), false, npc_owner, npc_owner, npc_owner:GetTeam(), 
		function(unit)
			unit:SetForwardVector((target:GetOrigin() - caster:GetOrigin()):Normalized())
			unit:AddAbility("axe_battle_hunger")
			local ability_original_battle_hunger = unit:FindAbilityByName("axe_battle_hunger")
			ability_original_battle_hunger:SetLevel(ability:GetLevel())
			ability_original_battle_hunger:SetOverrideCastPoint(0)
			unit:SetContextThink(DoUniqueString("cast_ability"),
				function()
					unit:CastAbilityOnTarget(target,ability_original_battle_hunger,unit:GetOwner():GetPlayerID())
				end,
			0)
			unit:SetContextThink(DoUniqueString("remove_self"), function()  unit:RemoveSelf() end, 10)
		end
	)
end

function OnImbaBattleHungerIntervalThink(keys)
	print("battle hunger on interval think")
	local caster = keys.caster
	local target = keys.target_entities[1]
	local ability = keys.ability
	if not (caster and target and ability) then return end
	if caster:GetContext("new_created")	== "yes" then
		print("first time run")
		caster:SetContext("new_created","no",0)
		return
	end
	if not (target:HasModifier("modifier_axe_battle_hunger")) then
		print("target has no battle hunger modifier")
		target:RemoveModifierByName("modifier_axe_battle_hunger_imba")
		target:SetForceAttackTarget(nil)
		return
	end
	if ( target:GetOrigin() - caster:GetOrigin() ):Length2D() < 200 then
		print("axe around")
		if target:GetForceAttackTarget() ~= nil then print(target:GetForceAttackTarget():GetUnitName()) end
		if target:GetForceAttackTarget() == nil then
			print("set force attack target")
			target:SetForceAttackTarget(caster)
		end
	else
		target:SetForceAttackTarget(nil)
	end
end
function OnAxeBattleHungerEnd(keys)
	print("battle hunger on interval think")
	local target = keys.target_entities[1]
	local caster = keys.caster
	if target:GetForceAttackTarget() == caster then
		target:SetForceAttackTarget(nil)
	end
end
function OnCullingBlade(keys)
	-- 原始已经重写为 1级失败，造成0伤害，2级必杀
	local caster = keys.caster
	local target = keys.target_entities[1]
	local ability = keys.ability
	if not (caster and target and ability) then return end

	print("culling blade start")
	local target_health = target:GetHealth()
	local noob = true
	if target:IsRealHero() then
		local target_kills = target:GetKills()
		local target_deaths = target:GetDeaths()
		if target_kills < 1 then target_kills = 1 end
		noob = ((target_deaths / target_kills) > 2)
		print(target_kills, target_deaths, noob)
	end
	local ability_level = 1
	if noob then
		ability_level = 2 --必杀
	end
	print(ability_level)

	local target_health = target:GetHealth()
	local kill_threshold = ability:GetLevelSpecialValueFor("kill_threshold", ability:GetLevel() - 1)
	print("KILL THRESHOLD", target_health, kill_threshold)
	print(ability_level)

	if ( target_health <= kill_threshold ) then
		ability_level = 2
	end

	print(ability_level)

	if ability_level == 1 then
		print("NOT A NOOB AND HAS ENOUGH HELTH, DEALING DAMAGE")
		local ability_damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1)
		local damage_dealt = ApplyDamage({
			victim = target,
			attacker = caster,
			damage = ability_damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			damage_flags = 0,
			ability = ability
		})
		print("DAMAGE DEALT", damage_dealt)
		return
	end

	npc_owner = caster
	if caster:GetUnitName() == "npc_dummy" then
		npc_owner = caster:GetOwner()
	end
	
	local dummy_unit = CreateUnitByNameAsync("npc_dummy", npc_owner:GetOrigin() + Vector(0,0,150), false, npc_owner, npc_owner, npc_owner:GetTeam(), 
		function(unit)
			unit:SetForwardVector((target:GetOrigin() - caster:GetOrigin()):Normalized())
			unit:AddAbility("axe_culling_blade")
			local ability_original_culling_blade = unit:FindAbilityByName("axe_culling_blade")
			ability_original_culling_blade:SetLevel(2)
			ability_original_culling_blade:SetOverrideCastPoint(0)
			unit:SetContextThink(DoUniqueString("cast_ability"),
				function()
					unit:CastAbilityOnTarget(target,ability_original_culling_blade,unit:GetOwner():GetPlayerID())
				end,
			0)
			unit:SetContextThink(DoUniqueString("remove_self"), function()  unit:RemoveSelf() end, 0.2)
		end
	)
end

-- "AbilitySpecial"
-- 		{
-- 			"01"
-- 			{
-- 				"var_type"					"FIELD_INTEGER"
-- 				"kill_threshold"			"250 350 450"
-- 			}
-- 			"02"
-- 			{
-- 				"var_type"					"FIELD_INTEGER"
-- 				"damage"					"150 250 300"
-- 			}
-- 			"03"
-- 			{
-- 				"var_type"					"FIELD_INTEGER"
-- 				"speed_bonus"				"40"
-- 			}
-- 			"04"
-- 			{
-- 				"var_type"					"FIELD_FLOAT"
-- 				"speed_duration"			"6"
-- 			}
-- 			"05"
-- 			{
-- 				"var_type"					"FIELD_INTEGER"
-- 				"speed_aoe"					"900"
-- 			}
-- 			"06"
-- 			{
-- 				"var_type"					"FIELD_FLOAT"
-- 				"cooldown_scepter"			"6.0 6.0 6.0"
-- 			}
-- 			"07"
-- 			{
-- 				"var_type"					"FIELD_INTEGER"
-- 				"kill_threshold_scepter"	"300 450 625"
-- 			}
-- 			"08"
-- 			{
-- 				"var_type"					"FIELD_FLOAT"
-- 				"speed_duration_scepter"	"10"
-- 			}
-- 		}
-- 	}