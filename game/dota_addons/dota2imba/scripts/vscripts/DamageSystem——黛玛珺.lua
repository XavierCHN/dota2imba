--------------------------------------
--------------------------------------
--                                  --
--     AMHC.帅哥系列.代码君出品     --
--                                  --
--------------------------------------
--------------------------------------
 
--使用之前在addon_game_mode.lua中载入伤害系统require("DamageSystem")
--并且在addon_game_mode.lua中调用DamageSystemInit()进行初始化
 
--支持的符号().+-*/
--关键词在DamageSystemInit中自定义
 
--享用办法：
--如果是AOE
--"RunScript"
-- {
--     "ScriptFile"        "scripts/vscripts/Abilities/PA.lua"
--     "Function"          "UseDamageSystemToAOE"
--     "format"            "( Agi + Str ) * 0.7 + Attack * 2"
--     "Target"
--     {
--         "Types"     "DOTA_UNIT_TARGET_BASIC | DOTA_UNIT_TARGET_HERO"
--         "Teams"     "DOTA_UNIT_TARGET_TEAM_ENEMY"
--         "Flags"     "DOTA_UNIT_TARGET_FLAG_NONE"
--         "Center"    "CASTER"
--         "Radius"    "400"
--     }
-- }
--如果是单体目标
-- "RunScript"
-- {
--     "ScriptFile"        "scripts/vscripts/Abilities/PA.lua"
--     "Function"          "UseDamageSystemToTarget"
--     "format"            "( Agi + Str ) * 0.7 + Attack * 2"
-- }
 
--format中填入公式，每个字符每个词之间可以没有空格，有空格就好看点
--如果出现没有定义好的词伤害系统将不会运转
--如果出现其它字符会过滤掉
 
if DamageSystem == nil then
    DamageSystem = {}
    DamageSystem.KeysFun={}
    DamageSystem.Keys = {}
end
 
--初始化
function DamageSystemInit()
 
    ----------------------------------
    --在此函数中自定义关键词及其作用--
    ----------------------------------
 
    --敏捷
    DamageSystem:AddKey( "Agi",function( hero )
        if IsValidEntity(hero) then
            if hero:IsAlive() and hero:IsHero() then
                return hero:GetAgility()
            end
        end
    end )
 
    --力量
    DamageSystem:AddKey( "Str",function( hero )
        if IsValidEntity(hero) then
            if hero:IsAlive() and hero:IsHero() then
                return hero:GetStrength()
            end
        end
    end )
 
    --智力
    DamageSystem:AddKey( "Int",function( hero )
        if IsValidEntity(hero) then
            if hero:IsAlive() and hero:IsHero() then
                return hero:GetIntellect()
            end
        end
    end )
 
    --全属性
    DamageSystem:AddKey( "All",function( hero )
        if IsValidEntity(hero) then
            if hero:IsAlive() and hero:IsHero() then
                return hero:GetAgility() + hero:GetStrength() + hero:GetIntellect()
            end
        end
    end )
 
    --攻击力
    DamageSystem:AddKey( "Attack",function( hero )
        if not IsValidEntity(hero) then return end
        return hero:GetAttackDamage()
    end )
 
    --当前生命值
    DamageSystem:AddKey( "Heal",function( hero )
        return hero:GetHealth()
    end )
 
    --最大生命值
    DamageSystem:AddKey( "MaxHeal",function( hero )
        if not IsValidEntity(hero) then return end
        return hero:GetMaxHealth()
    end )
 
    --当前魔法值
    DamageSystem:AddKey( "Mana",function( hero )
        if not IsValidEntity(hero) then return end
        return hero:GetMana()
    end )
 
end
 
--添加关键字
--key:string 关键字
--fun 函数
function DamageSystem:AddKey( key,fun )
    if type(key) ~= "string" and type(fun) ~= "function" then
        print("DamageSystem addKey parameters is error")
    end
 
    table.insert( DamageSystem.Keys,key )
    DamageSystem.KeysFun[key] = fun
end
 
--匹配关键字
function DamageSystem:FindKeys( key )
    for k,v in pairs(DamageSystem.Keys) do
        if key == v then
            return true
        end
    end
    return false
end
 
--进行字符串分割
function DamageSystem:StringSplit( str )
    local _s1 = {}
    local _len = string.len(str)
 
    local j = 1
    local s = ""
    local a = string.byte("a")
    local z = string.byte("z")
    local A = string.byte("A")
    local Z = string.byte("Z")
 
    for i=1,_len do
        local _s = string.sub(str,i,i)
        local _i = string.byte(_s)
 
        if _i == string.byte("(") then if s ~= "" then _s1[j] = s;s = ""; j=j+1 end; _s1[j] = "("; j=j+1 end
        if _i == string.byte(")") then if s ~= "" then _s1[j] = s;s = ""; j=j+1 end; _s1[j] = ")"; j=j+1 end
        if _i == string.byte("+") then if s ~= "" then _s1[j] = s;s = ""; j=j+1 end; _s1[j] = "+"; j=j+1 end
        if _i == string.byte("-") then if s ~= "" then _s1[j] = s;s = ""; j=j+1 end; _s1[j] = "-"; j=j+1 end
        if _i == string.byte("*") then if s ~= "" then _s1[j] = s;s = ""; j=j+1 end; _s1[j] = "*"; j=j+1 end
        if _i == string.byte("/") then if s ~= "" then _s1[j] = s;s = ""; j=j+1 end; _s1[j] = "/"; j=j+1 end
 
        if (_i <= z and _i >= a) or (_i <= Z and _i >= A) or (_i <= string.byte("9") and _i >= string.byte("0")) or _i == string.byte(".") then
            s = s.._s
        else
            if s ~= "" then _s1[j] = s; s = ""; j=j+1 end
        end
    end
    if s ~= "" then _s1[j] = s; end
 
    return _s1
end
 
--语法检测
function DamageSystem:CalCulateDetect( _t,str )
     
    --括号检测
    local brackets = {}
    local top = 0
    for k,v in pairs(_t) do
        if v == "(" then
            top = top + 1;
            brackets[top] = "("; 
        end
 
        if v == ")" then
            if brackets[top] == "(" then
                table.remove(brackets,top)
                top = top - 1
            else
                print("format: "..str.." error is ()")
                return true
            end
        end
    end
 
    --+-*/检测
    for i=1,#_t do
        local v = _t[i]
        if v == "+" or v == "-" or v == "*" or v == "/" then
            if (type(_t[i-1]) == "number" and type(_t[i+1]) == "number") or (_t[i-1] == ")" and _t[i+1] == "(") or (_t[i-1] == ")" and type(_t[i+1]) == "number") or (type(_t[i-1]) == "number" and _t[i+1] == "(") then else
                print("format: "..str.." error is "..v.." in "..i) 
                return true
            end
        end
    end
 
    --数字检测
    for i=1,#_t do
        if type(_t[i]) == "number" then
            if type(_t[i-1]) == "number" or type(_t[i+1]) == "number" or _t[i-1] == ")" or _t[i+1] == "(" then
                print("format: "..str.." error is ".._t[i].." in "..i) 
                return true
            end
        end
    end
 
    return false
end
 
--根据关键字转换相应的值
function DamageSystem:FindKeyToValue( hero,key )
 
    if DamageSystem:FindKeys( key ) then
        local val = DamageSystem.KeysFun[key](hero)
        if val then return val end
    end
     
    if key == "(" or key == ")" or key == "+" or key == "-" or key == "*" or key == "/" then
        return key
    end
 
    return tonumber(key)
end
 
--进行乘法和除法
function DamageSystem:CalCulateInit( _t,max )
    for i=1,max do
        for j=1,max do
            if _t[j] == "*" then
                local a = _t[j-1]
                local b = _t[j+1]
                if a ~= nil and b ~= nil then
                    if type(a) == "number" and type(b) == "number" then
                        _t[j] = nil
                        _t[j] = a * b
                        table.remove(_t,j+1)
                        table.remove(_t,j-1)
                        break
                    end
                end
 
            elseif _t[j] == "/" then
                local a = _t[j-1]
                local b = _t[j+1]
                if a ~= nil and b ~= nil then
                    if type(a) == "number" and type(b) == "number" then
                        _t[j] = nil
                        _t[j] = a / b
                        table.remove(_t,j+1)
                        table.remove(_t,j-1)
                        break
                    end
                end
 
            end
        end
    end
end
 
--进行加法和减法
function DamageSystem:CalCulateAddLow( _t,max )
    for i=1,max do
        for j=1,max do
            if _t[j] == "+" and _t[j-2] ~= "*" and _t[j-2] ~= "/" and _t[j+2] ~= "*" and _t[j+2] ~= "/" then
                local a = _t[j-1]
                local b = _t[j+1]
                if a ~= nil and b ~= nil then
                    if type(a) == "number" and type(b) == "number" then
                        _t[j] = nil
                        _t[j] = a + b
                        table.remove(_t,j+1)
                        table.remove(_t,j-1)
                        break
                    end
                end
 
            elseif _t[j] == "-" and _t[j-2] ~= "*" and _t[j-2] ~= "/" and _t[j+2] ~= "*" and _t[j+2] ~= "/" then
                local a = _t[j-1]
                local b = _t[j+1]
                if a ~= nil and b ~= nil then
                    if type(a) == "number" and type(b) == "number" then
                        _t[j] = nil
                        _t[j] = a - b
                        table.remove(_t,j+1)
                        table.remove(_t,j-1)
                        break
                    end
                end
 
            end
        end
    end
end
 
--去除括号，并且计算
function DamageSystem:CalCulateBrackets( _t )
    local x = 0
    for i=1,#_t do
        for j=1,#_t do
            if _t[j] == "(" then
                x = j
            end
            if _t[j] == ")" then
                table.remove(_t,j)
                table.remove(_t,x)
                break
            end
        end
        DamageSystem:CalCulateInit( _t,#_t )
        DamageSystem:CalCulateAddLow( _t,#_t )
    end
end
 
--进行计算
function DamageSystem:CalCulate( _t )
    DamageSystem:CalCulateInit( _t,#_t )
    DamageSystem:CalCulateAddLow( _t,#_t )
    DamageSystem:CalCulateBrackets( _t )
end
 
--总计
function DamageSystem:Total( hero,str )
    local _t = DamageSystem:StringSplit( str )
    local _i = {}
    local j = 1
 
    for k,v in pairs(_t) do
        local val = DamageSystem:FindKeyToValue( hero,v )
        if val then
 
            _i[j] = val
            j=j+1
 
        else
            return 0
        end
    end
 
    if DamageSystem:CalCulateDetect( _i,str ) then
        return 0
    end
 
    DamageSystem:CalCulate( _i )
    return _i[1]
end
 
--AOE入口
function UseDamageSystemToTarget( keys )
    local target = keys.target or keys.caster
    local total = DamageSystem:Total( keys.caster,keys.format ) or 0
    print("Damage format: "..keys.format.." = "..total)
 
    if not IsValidEntity(target) then return end
    if not target:IsAlive() then return end
 
    local damageType = keys.ability:GetAbilityDamageType() or DAMAGE_TYPE_PURE
    local damageTable = {victim  = keys.target or keys.caster, --受害者
                        attacker = keys.caster, --伤害者
                        damage   = total,       --伤害
                        damage_type = damageType --伤害类型
                    }
    local damage = ApplyDamage(damageTable)
end
 
--单体目标入口
function UseDamageSystemToAOE( keys )
    local total = DamageSystem:Total( keys.caster,keys.format ) or 0
    print("Damage format: "..keys.format.." = "..total)
 
 
    local targets = keys.target_entities
    local damageType = keys.ability:GetAbilityDamageType() or DAMAGE_TYPE_PURE
 
    for i,v in pairs(targets) do
        if not IsValidEntity(v) then return end
        if not v:IsAlive() then return end
        local damageTable = {victim  = v, --受害者
                            attacker = keys.caster, --伤害者
                            damage   = total,       --伤害
                            damage_type = damageType --伤害类型
                        }
        local damage = ApplyDamage(damageTable)
    end
end