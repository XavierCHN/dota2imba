function OnAxeCounterHelix(keys)
    local caster = keys.caster
    local agi = caster:GetAgility()
    local abilityLevel = keys.ability:GetLevel()
    local chance = 17
    local chance = chance + agi * 0.075

    local ran = RandomInt(0, 100)
    if ran <= chance then
        -- 开始做反击螺旋动作
        local parIndex = ParticleManager:CreateParticle('particles/econ/items/axe/axe_weapon_bloodchaser/axe_attack_blur_counterhelix_bloodchaser_b.vpcf', PATTACH_CUSTOMORIGIN, caster)
        ParticleManager:SetParticleControl(parIndex, 0, caster:GetOrigin() + Vector(0,0,0)) --TODO
        ParticleManager:ReleaseParticleIndex(parIndex)

        local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, 275
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
        local damage = {
            attacker = caster,
            victim = nil,
            damage_type = DAMAGE_TYPE_MAGICAL,
            damage_flags = 1,
            damage = 100 + (abilityLevel - 1) * 35
        }
        for k,v in pairs(targets) do
            damage.victim = v
            ApplyDamage(damage)
        end
    end
end