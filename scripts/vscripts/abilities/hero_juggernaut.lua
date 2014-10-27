if AbilityCore.npc_dota_hero_juggernaut == nil then
	AbilityCore.npc_dota_hero_juggernaut = class({})
end
function AbilityCore.npc_dota_hero_juggernaut:LearnAbilityHandler(keys)
	local player = EntIndexToHScript(keys.player)
	print(player)
	if not player then return end
	self._hero = player:GetAssignedHero()
	local hero = player:GetAssignedHero()
	if hero then
		local ability_name = keys.abilityname
		if ability_name == "juggernaut_wind_blade_imba" then
			ListenToGameEvent("entity_killed",Dynamic_Wrap(AbilityCore.npc_dota_hero_juggernaut, "OnJuggKilledEntity"),self)
		end
	end
end
function AbilityCore.npc_dota_hero_juggernaut:OnJuggKilledEntity(keys)
	local caster = EntIndexToHScript(keys.entindex_attacker)
	if caster ~= self._hero then return end
	local target = EntIndexToHScript(keys.entindex_killed)
	if not target then return end
	if not target:IsRealHero() then return end
	if not caster:HasModifier("modifier_juggernaut_wind_blade_imba") then return end
	local ability_blade_fury = caster:FindAbilityByName("juggernaut_blade_fury_imba")
	local ability_wind_blade = caster:FindAbilityByName("juggernaut_wind_blade_imba")
	ability_blade_fury:EndCooldown()
	ability_wind_blade:EndCooldown()
end

function OnBladeFuryCasting(keys)
	local caster = keys.caster
	local units = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, 375, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, unit in pairs(units) do
		local unit_position = unit:GetOrigin()
		local caster_position = caster:GetOrigin()
		local blade_angle = QAngle(0,1.5,0)
		local closer_position = caster_position + ((unit_position - caster_position):Normalized()) * (0.96 * (unit_position - caster_position):Length2D())
		local result_position = RotatePosition(caster_position, blade_angle, closer_position)
		FindClearSpaceForUnit(unit, result_position, true)
	end
end
function OnBladeFuryStart(keys)
	local caster = keys.caster
	EmitSoundOn("Hero_Juggernaut.BladeFuryStart", caster)
end
function OnBladeFuryStop(keys)
	print("STOP!!!!")
	local caster = keys.caster
	StopSoundOn("Hero_Juggernaut.BladeFuryStart", caster)
end
