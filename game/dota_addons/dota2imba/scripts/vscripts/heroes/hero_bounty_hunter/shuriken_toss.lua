-- 飞镖命中后会用一条钩锁连接目标和施法者，持续2/3/4/5秒，连接期间，钩锁会将目标渐渐拉向施法者，速度与两者的距离有关
function OnShurikenPull(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local target_origin =  target:GetOrigin()
	local caster_origin = caster:GetOrigin()
	local diff = target_origin - caster_origin
	local distance = diff:Length2D()
	local direction = diff:Normalized()

	local distance_per_pull = distance * 0.2
	local target_pos = caster_origin + direction * (distance - distance_per_pull)
	FindClearSpaceForUnit(target, target_pos, true)
end