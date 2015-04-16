require('abilities/ability_generic')
-- 刷新所有技能和物品的CD
function OnRearmFinished(keys)
	local caster = keys.caster
	for i = 0,20 do
		local ability = caster:GetAbilityByIndex(i)	
		local item = caster:GetItemInSlot(i)
		if ability and (ability:GetCooldownTime() > 0) then ability:EndCooldown() end
		if item then item:EndCooldown() end
	end
end
-- 显示黑屏
function OnLaserCasted(keys)
	local target = keys.target_entities[1]
	local caster = keys.caster
	local ability = keys.ability
	if not (target and caster and ability ) then return end

	CreateDummyAndCastAbilityOnTarget(caster, "tinker_laser", ability:GetLevel(), target, 10, false)

	if not target:IsRealHero() then return end

	FireGameEvent("imba_laser_hit_unit",{PlayerID = target:GetPlayerID()})
end
-- 移除黑屏
function OnLaserModifierDestroy(keys)
	local target = keys.target_entities[1]
	if not target then return end
	if not target:IsRealHero() then return end
	FireGameEvent("imba_laser_disappear",{PlayerID = target:GetPlayerID()})
end
-- 释放交叉90度的机器人进军
function OnMarchStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	if not (caster and ability and point) then return end

	local angle_left = QAngle(0,-45,0)
	local angle_right = QAngle(0,45,0)
	local caster_origin = caster:GetOrigin()

	local pos_left = RotatePosition(caster_origin,angle_left,point)
	local pos_right = RotatePosition(caster_origin,angle_right,point)

	CreateDummyAndCastAbilityAtPosition(caster, "tinker_march_of_the_machines", ability:GetLevel(), pos_left, 15, false)
	CreateDummyAndCastAbilityAtPosition(caster, "tinker_march_of_the_machines", ability:GetLevel(), pos_right, 15, false)
end