if AbilityCore.npc_dota_hero_juggernaut == nil then
	AbilityCore.npc_dota_hero_juggernaut = class({})
end

-- self[hero_name]:LearnAbilityHandler(keys, hero, keys.abilityname)
				-- self[target_name]:CastedAbilityHandler(keys, hero, ability, ability_target, ability_name)
function AbilityCore.npc_dota_hero_juggernaut:LearnAbilityHandler(keys, juggernaut, ability_name)
	if ability_name == "juggernaut_wind_blade_imba" then
		self._hero = juggernaut
		ListenToGameEvent("entity_killed",Dynamic_Wrap(AbilityCore.npc_dota_hero_juggernaut, "OnJuggKilledEntity"),self)
	end
end
function AbilityCore.npc_dota_hero_juggernaut:OnJuggKilledEntity(keys)
	-- 确保击杀者是剑圣
	local caster = EntIndexToHScript(keys.entindex_attacker)
	if caster ~= self._hero then return end
	-- 确保被击杀的单位是英雄
	local target = EntIndexToHScript(keys.entindex_killed)
	if not target then return end
	if not target:IsRealHero() then return end
	-- 确保剑圣身上有疾风剑客状态
	if not caster:HasModifier("modifier_juggernaut_wind_blade_imba") then return end
	-- 找到两个技能并重置CD
	local ability_blade_fury = caster:FindAbilityByName("juggernaut_blade_fury_imba")
	local ability_wind_blade = caster:FindAbilityByName("juggernaut_wind_blade_imba")
	ability_blade_fury:EndCooldown()
	ability_wind_blade:EndCooldown()
end

function OnBladeFuryCasting(keys)
	local caster = keys.caster
	local units = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, 375, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	if caster.__blade_fury_pulling_units == nil then
		caster.__blade_fury_pulling_units = {}
	end
	for _, unit in pairs(units) do
		-- 
		table.insert(caster.__blade_fury_pulling_units, unit)
		local unit_position = unit:GetOrigin()
		local caster_position = caster:GetOrigin()
		local blade_angle = QAngle(0,1.5,0)
		local closer_position = caster_position + ((unit_position - caster_position):Normalized()) * (0.96 * (unit_position - caster_position):Length2D())
		local result_position = RotatePosition(caster_position, blade_angle, closer_position)
		FindClearSpaceForUnit(unit, result_position, true)
		if not unit:HasModifier("modifier_phased") then
			unit:AddNewModifier(caster, keys.ability, "modifier_phased", {})
		end
	end
end
function OnBladeFuryStart(keys)
	local caster = keys.caster
	EmitSoundOn("Hero_Juggernaut.BladeFuryStart", caster)
end
function OnBladeFuryStop(keys)
	local caster = keys.caster
	StopSoundOn("Hero_Juggernaut.BladeFuryStart", caster)
	for _, unit in pairs(caster.__blade_fury_pulling_units) do
		unit:RemoveModifierByName("modifier_phased")
	end
end
