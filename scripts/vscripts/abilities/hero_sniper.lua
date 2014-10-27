require('abilities/ability_generic')

if AbilityCore.npc_dota_hero_sniper == nil then
	AbilityCore.npc_dota_hero_sniper = class({})
end

function AbilityCore.npc_dota_hero_sniper:LearnAbilityHandler(keys)
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

function GenerateShrapnelPoints( keys)
	local radius = keys.Radius or 400
	local count = keys.Count or 10

	local caster = keys.caster
	local caster_fv = caster:GetForwardVector()
	local caster_origin = caster:GetOrigin()
	local center = caster_origin + caster_fv * 2000

	local result = {}
	for i = 1, count do
		local random = RandomFloat(0, radius)
		local vec = center + RandomVector(random)
		table.insert(result,vec)
	end
	return result
end

function OnShrapnelStart(keys)
	local caster = keys.caster
	local point = keys.target_points[1]
	local ability = keys.ability
	if not ( caster and point and ability ) then return end
	CreateDummyAndCastAbilityAtPosition(caster, "sniper_shrapnel", ability:GetLevel(), point, 30, false)
end

function OnHeadShotAttackStart(keys)
	print("[SNIPER:] OnHeadShotAttackStart ->")

	local caster = keys.caster
	local target = keys.target_entities[1]
	local ability = keys.ability
	local player = PlayerResource:GetPlayer(caster:GetPlayerID())
	if not(caster and target and ability) then return end
	local stun_chance = 8
	if not(target:CanEntityBeSeenByMyTeam(caster)) then
		print("TARGET CANT BE SEEN BY MY TEAM")
		stun_chance = 30
	else
		print("TARGET CAN BE SEEN")
	end
	caster:SetContext("head_shot_stun_chance", tostring(stun_chance), 0)
	print("STUN CHANCE:", stun_chance)
	print("-> [SNIPER:] OnHeadShotAttackStart")
end
-- 爆头
function OnHeadShotAttackLanded(keys)
	print("[SNIPER:] HEAD SHOT ATTACK LANDED ->")

	local caster = keys.caster
	local target = keys.target_entities[1]
	local ability = keys.ability
	local player = PlayerResource:GetPlayer(caster:GetPlayerID())
	if not(caster and target and ability) then return end
	local stun_chance = caster:GetContext("head_shot_stun_chance")
	print("STUN CHANCE:", stun_chance)
	print(caster:GetContext("head_shot_stunned"))
	if caster:GetContext("head_shot_stunned") ~= "true" then
		print("NOT STUNNED IN 2 SECONDS")
		if RandomInt(1,100) <= stun_chance then
			print("SUCCESS!!! STUN IT!")
			ability:ApplyDataDrivenModifier(caster, target, "modifier_headshot_imba", {})
			caster:SetContext("head_shot_stunned", "true", 0)
			caster:SetContextThink(DoUniqueString("head_shot_count_down"), function() caster:SetContext("head_shot_stunned", "false", 0) end, 2.0)
		end
	else
		print("CANT BE STUNNED TOO SOON")
	end

	print("-> [SNIPER:] HEAD SHOT ATTACK LANDED")
end
-- 暗杀
function OnAssassStart(keys)
	print("[SNIPER:] OnAssassStart ->")

	local caster = keys.caster
	local ability = keys.ability
	local ability_restore = caster:FindAbilityByName("sniper_restore_imba")
	local bullets_count = caster:GetModifierStackCount("modifier_sniper_bullets",ability_restore)
	-- 如果没有子弹了，停止
	if bullets_count == nil or bullets_count <= 0 then
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerID(), _error = "#sniper_hava_no_bullet" } )
		caster:Stop() 
		return
	end

	print(" ->[SNIPER:] OnAssassStart")
end
function OnSniperAssassStartChannel(keys)
	print("[SNIPER:] OnSniperAssassStartChannel ->")
	local caster = keys.caster
	local ability = keys.ability
	-- 计算暗杀开始瞄准的时间并保存
	local time = GameRules:GetGameTime()
	caster:SetContext("assass_start_time",tostring(time),0)
	print(" ->[SNIPER:] OnSniperAssassStartChannel")
end
function OnSniperAssassHitUnit(keys)
	print("[SNIPER:] OnSniperAssassHitUnit ->")
	-- 获取施法者
	local caster = keys.caster
	-- 获取技能
	local ability = keys.ability
	-- 获取目标
	local target = keys.target_entities[1]
	
	if not( caster and ability and target) then return end
	
	-- 计算读条时间
	local time = GameRules:GetGameTime()
	local channel_start_time = caster:GetContext("assass_start_time")
	if channel_start_time == nil then channel_start_time = time end
	local channel_time = time - channel_start_time

	-- 计算技能伤害 - 与瞄准等级相关
	local base_damage = ability:GetLevelSpecialValueFor("base_damage", ability:GetLevel() -1)	
	local damage_increase_per_second = ability:GetLevelSpecialValueFor("damage_increase_per_second", ability:GetLevel() -1)	
	local take_aim_ability = caster:FindAbilityByName("sniper_take_aim_imba")
	local take_aim_level = take_aim_ability:GetLevel()
	local damage_to_deal = base_damage + damage_increase_per_second * channel_time * take_aim_level

	-- 计算爆头秒杀概率 - 与爆头等级相关
	local head_shot_chance = ability:GetLevelSpecialValueFor("head_shot_chance", ability:GetLevel() -1)
	local head_shot_increase_per_second = ability:GetLevelSpecialValueFor("head_shot_chance_per_second", ability:GetLevel() -1)
	local head_shot_ability = caster:FindAbilityByName("sniper_headshot_imba")
	local headshot_level = head_shot_ability:GetLevel()
	local head_shot_chance = head_shot_chance + head_shot_increase_per_second * channel_time * headshot_level

	print("CALCULATION RESULT", damage_to_deal,head_shot_chance)
	-- 造成伤害
	local damage_dealt = ApplyDamage({
		victim = target,
		attacker = caster,
		damage = damage_to_deal,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		damage_flags = 0,
		ability = ability
	})
	-- 随机计算是否爆头
	local random_result = RandomInt(1,100)
	if  random_result <= head_shot_chance then
		print("HEAD SHOT!!!")
		local target_health = target:GetHealth()
		local damage_dealt = ApplyDamage({
			victim = target,
			attacker = caster,
			damage = target_health,
			damage_type = DAMAGE_TYPE_PURE,
			damage_flags = 0,
			ability = ability
		})
		
		ScreenShake(target:GetOrigin(), 20, 0.1, 1, 1000, 0, true)

		DebugDrawText(target:GetOrigin() + Vector(0,0,150),"#sniper_head_shot",true,2)
		FireGameEvent("show_center_message", {message = "HEAD SHOT!", duration = 2})
	end

	-- 计算子弹数量并更新
	local ability_restore = caster:FindAbilityByName("sniper_restore_imba")
	local bullets_count = caster:GetModifierStackCount("modifier_sniper_bullets",ability_restore)
	local bullets_end = math.max(bullets_count -1, 0)
	caster:SetModifierStackCount("modifier_sniper_bullets",ability_restore,bullets_end)
	print(ability_restore, bullets_count, bullets_end)

	print(" ->[SNIPER:] OnSniperAssassHitUnit")
end

function OnBuyingBullets(keys)
	print("[SNIPER:] OnBuyingBullets ->")

	local caster = keys.caster
	local ability = keys.ability
	
	if not caster:HasModifier("modifier_sniper_bullets") then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_sniper_bullets", {})
		caster:SetModifierStackCount("modifier_sniper_bullets",keys.ability,1)
	else
		local bullets_count = caster:GetModifierStackCount("modifier_sniper_bullets",keys.ability)
		if bullets_count >= 10 then
			caster:Stop()
			FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerID(), _error = "#sniper_bullets_full" } )
		end
		local bullet_prize = ability:GetSpecialValueFor("bullet_prize")
		if caster:GetGold()	>= bullet_prize then
			bullets_count = math.min(bullets_count + 1,10)
			caster:ModifyGold(-bullet_prize, false, 0)
			DebugDrawText(caster:GetOrigin() + Vector(0,0,100), "- "..tostring(bullet_prize), true, 0.5)
			caster:SetModifierStackCount("modifier_sniper_bullets",keys.ability,bullets_count)
		else
			caster:Stop()
			FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerID(), _error = "#sniper_not_enough_gold_for_bullets" } )
		end
	end
	
	print(" ->[SNIPER:] OnBuyingBullets")
end