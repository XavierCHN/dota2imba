if AbilityCore == nil then
	AbilityCore = class({})
end

function AbilityCore:Init()
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(AbilityCore, "RegisterHeroes"), self)
	ListenToGameEvent("dota_player_used_ability", Dynamic_Wrap(AbilityCore, "OnPlayerCastAbility"), self)
	ListenToGameEvent("dota_player_learned_ability", Dynamic_Wrap(AbilityCore, "OnPlayerLearnedAbility"), self)
	self._vHeroes = {}
end

function AbilityCore:OnPlayerCastAbility(keys)
	local player_id = keys.PlayerID
	local player = PlayerResource:GetPlayer(player_id)
	if not player then return end
	local hero = player:GetAssignedHero()
	if hero then
		local hero_name = hero:GetUnitName()
		local ability_name = keys.abilityname
		if self[hero_name] and self[hero_name].abilityname then
			self[hero_name]:CastAbilityHandler(keys)
		end
	end
end

-- 用来在英雄学习某个技能的时候做出对应操作
require('abilities/hero_juggernaut') -- 监听疾风剑客击杀英雄事件
require('abilities/hero_sniper') -- 监听学习大招事件，来给火枪手设置购买子弹的技能等级
require('abilities/hero_nevermore') -- 监听支配死灵击杀单位事件 TODO
require('abilities/hero_tiny') -- 监听TOSS事件
function AbilityCore:OnPlayerLearnedAbility(keys)
	local player = EntIndexToHScript(keys.player)
	if not player then return end
	local hero = player:GetAssignedHero()
	if hero then
		local hero_name = hero:GetUnitName()
		if self[hero_name] then
			self[hero_name]:LearnAbilityHandler(keys)
		end
	end
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