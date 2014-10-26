function tableCount(table)
	count  = 0
	for _ in pairs(table) do
		count = count + 1
	end
	return count
end

function FireEffectAndRelease(particlename, target, vec )
	local p_index = ParticleManager:CreateParticle(particlename, PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl(p_index,0,vec)
	ParticleManager:ReleaseParticleIndex(p_index)
end

function GrabKeysWithTarget(keys)
	local caster = keys.caster
	local target = keys.target_entities[1]
	local ability = keys.ability
	local success = caster and target and ability
	return caster, target, ability, success
end