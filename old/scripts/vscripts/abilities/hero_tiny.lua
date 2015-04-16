require('abilities/ability_generic')

if AbilityCore.npc_dota_caster_tiny == nil then
	AbilityCore.npc_dota_caster_tiny = class({})
end

function AbilityCore.npc_dota_caster_tiny:LearnAbilityHandler(keys)
	local player = EntIndexToHScript(keys.player)
	print(player)
	if not player then return end

	local caster = player:GetAssignedcaster()
	if caster then
		local ability_name = keys.abilityname
		if ability_name == "tiny_toss_imba" then
			local ability = caster:FindAbilityByName("tiny_toss_imba")
			if ability then
				caster.___toss_count = ability:GetLevelSpecialValueFor("toss_times", ability:GetLevel() - 1)
			end
		end
	end
end
-- 投掷，在技能第一次施法，和每次Modifier计时结束调用
--
function OnTossCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	if caster.___current_toss_target == nil then
		local radius = ability:GetLevelSpecialValueFor("grab_radius", ability:GetLevel() - 1)
		local enemies  = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		if #enemies <= 0 or (#enemies == 1 and enemies[1] == caster)then 
			return 
			FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerID(), _error = "#dota_hud_error_cant_toss" } )
		end

		caster.___current_toss_target = enemies[RandomInt(1,#enemies)]
		while( caster.___current_toss_target == caster ) do
			caster.___current_toss_target = enemies[RandomInt(1,#enemies)]
		end
		caster.___knock_back_start_point = caster.___current_toss_target:GetOrigin()
		caster.___knock_back_end_point = keys.target_entities[1]:GetOrigin()
	end

	if caster.___toss_count == nil then
		caster.___toss_count = ability:GetLevelSpecialValueFor("toss_times", ability:GetLevel() - 1)
	end
	if caster.___current_toss_count == nil then
		caster.___current_toss_count = caster.___toss_count
	end
	caster.___current_toss_count = caster.___current_toss_count - 1

	local duration = ability:GetLevelSpecialValueFor("toss_duration", ability:GetLevel() -1)
	local height = ability:GetLevelSpecialValueFor("toss_height", ability:GetLevel() -1)
	if caster.___current_toss_count >= 0 then
		AddModifier(caster, caster.___current_toss_target, ability, "modifier_toss_knock_back", nil)
	else
		caster.___current_toss_count = nil
		caster.___current_toss_target = nil
	end
end
-- 计算投掷距离倍数 1 1.5 1.75 1.875这样子，每次/2
local function multiple(times)
	local ret = 1
	if times <= 0 then
		return ret
	else
		ret = ret * multiple(times - 1)/2
	end
	return ret
end

-- 获取投掷的位置
-- 
function GetKnockBackPoint(caster)
	local init_start_point = caster.___knock_back_start_point
	local init_end_point = caster.___knock_back_end_point
	local knock_back_count = caster.___current_toss_count

	local length = (init_end_point - init_start_point):Length2D()
	print("LENGTH",length)
	local direction = (init_end_point - init_start_point):Normalized()
	local m = 1
	local ret = init_start_point + direction * length * m

	print(ret, init_start_point, init_end_point, knock_back_count, caster.___toss_count)

	return init_start_point + direction * length * m
end
-- 抛物线 y2 = ax2 + bx + c，然后算出来这么个玩意……根据顶点和对称轴和经过原点三个属性计算抛物线……
-- 
local function GetKnockBackHeight(x, l, h)
	local x2 = 4 * ( 1 - h ) * (x * x) / ( l * l )
	local x1 = 4 * ( h - 1 ) * x / l
	return x2 + x1
end

local function GetKnockBackX( total_length, called_count , delay, duration)
	return total_length * called_count * delay / duration
end

function KnockTheFuckingGuyBack(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not (caster and ability ) then return end
	print(caster.___current_toss_target)
	print(caster.___current_toss_count)

	local called_count = 0
	local delay = 0.02
	local duration = ability:GetLevelSpecialValueFor("toss_duration", ability:GetLevel() - 1)
	local max_height = ability:GetLevelSpecialValueFor("toss_height", ability:GetLevel() - 1)
	local total_call_counts = duration / delay

	local target = caster.___current_toss_target
	local toss_count = caster.___current_toss_count
	local target_pos = GetKnockBackPoint(caster)
	local target_origin = target:GetOrigin()
	local total_length = (target_pos - target_origin):Length2D()
	local direction = (target_pos - target_origin):Normalized()

	caster:SetContextThink(DoUniqueString("Knocking_someone_back"),
		function()
			print(total_call_counts, called_count)
			called_count = called_count + 1
			if called_count < total_call_counts then
				local current_length = GetKnockBackX(total_length, called_count, delay, duration)
				print(total_length, current_length)
				local current_height = GetKnockBackHeight(current_length, total_length, max_height)
				local vec = target_origin + current_length * direction
				vec.z = vec.z + current_height
				target:SetOrigin(vec)
				return delay
			else
				return nil
			end
		end,
	delay)
end