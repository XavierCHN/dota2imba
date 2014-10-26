if AbilityCore == nil then
	AbilityCore = class({})
end

function AbilityCore:Init()
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(AbilityCore, "RegisterHeroes"), self)
	ListenToGameEvent("dota_player_used_ability", Dynamic_Wrap(AbilityCore, "OnPlayerCastAbility"), self)
	ListenToGameEvent("dota_player_learned_ability", Dynamic_Wrap(AbilityCore, "OnPlayerLearnedAbility"), self)
	self._vHeroes = {}
end

function AbilityCore:RegisterHeroes(keys)
	DeepPrint(keys)
	local nNewState = GameRules:State_Get()	
	if nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		for i=-1,9 do
			local hPlayer = PlayerResource:GetPlayer(i)
			if hPlayer then
				local hHero = hPlayer:GetAssignedHero()
				if hHero == nil then

					print("player not select hero yet, playerid", i)

					hPlayer:SetContextThink(DoUniqueString("wait_till_hero_selected"),
						function()
							hHero = hPlayer:GetAssignedHero()
							if hHero then
								print("regist hero for player ",i)
								self._vHeroes[i] = hHero
								GameRules.ImbaGameMode._vHeroes = self._vHeroes
								return nil
							end
							return 1
						end,
					1)

				else
					self._vHeroes[i] = hHero
					GameRules.ImbaGameMode._vHeroes = self._vHeroes
				end
			end
		end
	end
end

function AbilityCore:OnPlayerCastAbility(keys)
	DeepPrint(keys)
	local sAbilityName = keys.abilityname
	local nPlayerID = keys.PlayerID

end

function AbilityCore:OnPlayerLearnedAbility(keys)
	for k,v in pairs(keys) do
		print(k,v)
	end
	local player = EntIndexToHScript(keys.player)
	print(player)
	if not player then return end

	local hero = player:GetAssignedHero()
	if hero then
		local hero_name = hero:GetUnitName()
		if self[hero_name] then
			self[hero_name]:RegistAbility(keys)
		end
	end
end

if AbilityCore.npc_dota_hero_antimage == nil then
	AbilityCore.npc_dota_hero_antimage = class({})
end
if AbilityCore.npc_dota_hero_sniper == nil then
	AbilityCore.npc_dota_hero_sniper = class({})
end
if AbilityCore.npc_dota_hero_juggernaut == nil then
	AbilityCore.npc_dota_hero_juggernaut = class({})
	--modifier_juggernaut_wind_blade_imba
end
function AbilityCore.npc_dota_hero_antimage:RegistAbility(keys)
	local player = EntIndexToHScript(keys.player)
	print(player)
	if not player then return end

	local hero = player:GetAssignedHero()
	if hero then
		local ability_name = keys.abilityname
		if ability_name == "antimage_spell_shield" then
		end
	end
end

function AbilityCore.npc_dota_hero_sniper:RegistAbility(keys)
	local player = EntIndexToHScript(keys.player)
	print(player)
	if not player then return end

	local hero = player:GetAssignedHero()
	if hero then
		local ability_name = keys.abilityname
		if ability_name == "sniper_assassinate_imba" then
			local ABILITY = hero:FindAbilityByName('sniper_restore_imba')
			if ABILITY then
				print("ABILITY FOUND SNIPER RESTORE IMBA")
				ABILITY:SetLevel(1)
			end
		end
	end
end

function AbilityCore.npc_dota_hero_juggernaut:RegistAbility(keys)
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