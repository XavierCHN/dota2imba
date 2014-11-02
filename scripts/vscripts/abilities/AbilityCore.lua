-- [[API]]
--- self[target_name]:CastedAbilityHandler(target, source, ability, keys)
--- self[hero_name]:CastAbilityOnTargetHandler(source, target, ability_name, ability, keys)
--- self[hero_name]:CastAbilityAtPositionHandler(hero, target_position, ability, keys)
--- self[hero_name]:CastAbilityNoTargetHandler(hero, ability)
--- self[hero_name]:LearnAbilityHandler(keys, hero, keys.abilityname)
--- self[hero_name]:GeneralCastAbilityHandler(hero, ability)
-- [[API]]

if AbilityCore == nil then
	AbilityCore = class({})
end

function AbilityCore:Init()
	-- 监听游戏阶段变更事件
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(AbilityCore, "RegisterHeroes"), self)
	-- 监听玩家使用技能事件
	ListenToGameEvent("dota_player_used_ability", Dynamic_Wrap(AbilityCore, "OnPlayerCastAbility"), self)
	-- 监听玩家学习技能事件
	ListenToGameEvent("dota_player_learned_ability", Dynamic_Wrap(AbilityCore, "OnPlayerLearnedAbility"), self)
	
	self._vHeroes = {}
end

-- 用来监听某个单位释放技能的动作 -- 载入各种英雄的文本
require('abilities/hero_antimage')
require('abilities/hero_kunkka')
require('abilities/hero_centaur')
require('abilities/hero_earthshaker')
require('abilities/hero_omni')
require('abilities/hero_sven')
require('abilities/hero_windrunner')
require('abilities/hero_vs')
require('abilities/hero_pudge')

-- 当玩家释放某个技能
function AbilityCore:OnPlayerCastAbility(keys)
	-- 获取玩家ID
	local player_id = keys.PlayerID
	
	-- 获取玩家实体
	local player = PlayerResource:GetPlayer(player_id -1)
	if not player then print("INVALID PLAYER") return end
	
	-- 获取玩家所使用的英雄
	local hero = player:GetAssignedHero()
	if not hero then print("INVALID HERO") return end

	-- 从keys获取技能名称，再获取所释放的技能
	local ability_name = keys.abilityname
	local ability = hero:FindAbilityByName(ability_name)
	if ability then
		print("ABILITY IS VALID", ability:GetAbilityName())
		local ability_target = ability:GetCursorTarget()
		local ability_position = ability:GetCursorPosition()
		local hero_name = hero:GetUnitName()

		-- 如果获取到了技能目标（说明这是一个单位目标技能）
		if ability_target then
			local target_name = ability_target:GetUnitName()
			if self[target_name] and self[target_name].CastedAbilityHandler then
				-- 某个英雄被释放一个指向性技能的Handler
				local source = hero
				local target = ability_target
				------
				---
				self[target_name]:CastedAbilityHandler(target, source, ability, keys)
				---
				-----
			end
			if self[hero_name] and self[hero_name].CastAbilityOnTargetHandler then
				-- 某个英雄释放一个指向性技能的Handler
				local source = hero
				local target = ability_target
				---
				self[hero_name]:CastAbilityOnTargetHandler(source, target, ability_name, ability, keys)
				---
			end
		end
		-- 如果获取到了技能位置，但是没有目标（为了避免某些单位目标技能同时会返回技能目标位置的情况）
		if ability_position and not ability_target then
			if self[hero_name] and self[hero_name].CastAbilityAtPositionHandler then
				-- 当某个英雄对某个位置释放技能的Handler
				----
				self[hero_name]:CastAbilityAtPositionHandler(hero, ability_position, ability, keys)
				----
			end
		end
		-- 如果没有技能位置且没有技能目标，那应该是一个无目标技能
		if not (ability_target and ability_position) then
			if self[hero_name] and self[hero_name].CastAbilityNoTargetHandler then
				-- 当某个英雄释放某个无目标技能的Handler
				----
				self[hero_name]:CastAbilityNoTargetHandler(hero, ability)
				----
			end
		end
		-- 所有技能的通用接口，只要有对应的英雄文本被require，且
		-- 那个文本中有GeneralCastAbilityHandler这个函数
		-- 那么在这里就会调用那个函数
		if self[hero_name] and self[hero_name].GeneralCastAbilityHandler then
			self[hero_name]:GeneralCastAbilityHandler(hero, ability)
		end
	end
end

-- 用来在英雄学习某个技能的时候做出对应操作
require('abilities/hero_juggernaut') -- 监听疾风剑客击杀英雄事件
require('abilities/hero_sniper') -- 监听学习大招事件，来给火枪手设置购买子弹的技能等级
require('abilities/hero_lich') -- 用来自动释放NOVA
require('abilities/hero_nevermore')

function AbilityCore:OnPlayerLearnedAbility(keys)
	print("LEARNED ABILITY HANDLER")
	-- 获取学习技能的玩家实体
	local player = EntIndexToHScript(keys.player)
	if not player then return end
	-- 获取英雄
	local hero = player:GetAssignedHero()
	if hero then
		local hero_name = hero:GetUnitName()
		if self[hero_name] and self[hero_name].LearnAbilityHandler then
			-- 调用对应的接口
			print("LEARNED ABILITY HANDLER CALLING HERO SCRIPT, hero:", hero:GetUnitName(),"ability:",keys.abilityname)
			self[hero_name]:LearnAbilityHandler(keys, hero, keys.abilityname)
		end
	end
end

-- 这个东西暂时没有用
-- 不过可以用来在英雄被选择之后，
-- 就初始化一些东西
--
function AbilityCore:RegisterHeroes(keys)
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