--[[
	DamageSystem.lua Created by XavierCHN @ 04.14.2015, inspired by 黛玛珺
	使用方法：
	将这个文件放到scripts\vscripts\文件夹，在你需要造成伤害的KV文件中，使用：
	"RunScript"
	{
		"ScriptFile"		"scripts/vscripts/DamageSystem.lua"
		"Function"			"Damage"
		"formula"			"(s_GetStrength - t_GetStrength + %min_strength_diff) * 2"
		// 上面的这个方程，支持所有的API函数，或者自定义的API函数，要求这个API函数不需要任何参数
		// 自定义的API需要是CDOTA_BaseNPC，Entities的成员函数，你可以参考本代码最下方的代码
		// 方程的写法可以类似 "s_GetAP * %ap_amp" 代表从施法者的身上获取AP数值，然后乘以技能等级定义的AP伤害系数，再施加给目标伤害
		// 以s_开头的代表从施法者身上获取数值，以t_开头的代表从目标身上获取数值
		// 支持+-*/^()和%引用AbilitySpecial中的数值，
		// 这个方程的意思是，对目标 (施法者的力量值 - 目标的力量值 + 基础力量优势) * 2 的伤害
		"Type"				"DAMAGE_TYPE_MAGICAL" // 可选，支持魔法伤害，物理伤害和纯粹伤害，默认为纯粹伤害
		"Flags"				"DOTA_UNIT_TARGET_FLAG_INVULNERABLE | DOTA_UNIT_TARGET_FLAG_NO_INVIS" // 伤害Flags，按照官方写法写即可
		"Target"			"TARGET" // 可以为任何目标Value，如果需要对多个单位造成伤害，那么下面方括号Center即可
	}
]]

-- 将某个字符替换为另一个字符
local function stringReplace(str, src, res)
	local result = ""
	for i = 1, string.len(str) do
		local s = string.sub(str,i,i)
		if s == src then
			result = result .. res
		else
			result = result .. s
		end
	end
	return result
end

-- 判断是否是变量名的开头
local function isValidVarStarter(ch)
	return (ch >= "a" and ch <= "z") or (ch >= "A" and ch <= "Z") or (ch == "_") or (ch == "%")
end

-- 判断是否依然是合法变量名的字符
local function isValidVar(ch)
	return isValidVarStarter(ch) or (ch >= "1" and ch <= "9")
end

-- 拆分字符串
local function stringSplit(str, sep)
	if type(str) ~= 'string' or type(sep) ~= 'string' then
        return nil
    end
    local res_ary = {}
    local cur = nil
    for i = 1, #str do
        local ch = string.byte(str, i)
        local hit = false
        for j = 1, #sep do
            if ch == string.byte(sep, j) then
                hit = true
                break
            end
        end
        if hit then
            if cur then
                table.insert(res_ary, cur)
            end
            cur = nil
        elseif cur then
            cur = cur .. string.char(ch)
        else
            cur = string.char(ch)
        end
    end
    if cur then
        table.insert(res_ary, cur)
    end
    return res_ary
end

-- 判断两个运算符号的优先级
local function verifyOperatorPriority(op1, op2)
	if(op1 == "^") then
		return true
	elseif (op1 == "*" and op2 == "+") then
		return true
	elseif (op1 == "*" and op2 == "-") then 
		return true
	elseif (op1 == "/" and op2 == "+") then 
		return true
	elseif (op1 == "/" and op2 == "-") then 
		return true
	else
		return false
	end
end

-- 进行数学运算
local function calculate(op1, op2, opr)
	if opr == "*" then
		op1 = op1 * op2
	elseif opr == "/" then
		if (op2 == 0) then
			Warning("MATH WARNING!!!! Divided By 0!!! returning 99999")
			op1 = 99999
		else
			op1 = op1 / op2
		end
	elseif opr == "+" then
		op1 = op1 + op2
	elseif opr == "-" then
		op1 = op1 - op2
	elseif opr == "^" then
		op1 = op1 ^ op2
	end
	return op1
end

-- 将表达式转换为后序表达式
local function CalculateParenthesesExpression(sExpression)
	local vOperatorList = {} -- 操作符表
	local sOperator = "" -- 操作符
	local sExpString = "" -- 后序表达式
	local sOperand = "" -- 操作数
	local __s = "" -- 表达式的当前字符
	local __sExpression = sExpression -- 暂存一下方程式
	
	-- 替换掉所有空格
	sExpression = stringReplace(sExpression, " ", "")
	
	-- 挨个字符处理整个表达式
	while(string.len(sExpression) > 0) do
		sOperand = ""
		-- 处理数字
		__s = string.sub(sExpression,1,1)
		if(tonumber(__s)) then
			while((tonumber(__s)) or (__s == ".")) do
				sOperand = sOperand .. __s
				sExpression = string.sub(sExpression,2,string.len(sExpression))
				if (sExpression == "") then break end
				__s = string.sub(sExpression,1,1)
			end
			sExpString = sExpString .. sOperand .. "|"
		end
		
		sOperand = ""
		
		-- 处理英文字符，例如 s_GetStrength 或者 %str_buff
		__s = string.sub(sExpression,1,1)
		if(isValidVarStarter(__s)) then
			while(isValidVar(__s)) do
				sOperand = sOperand .. __s
				sExpression = string.sub(sExpression,2,string.len(sExpression))
				if (sExpression == "") then break end
				__s = string.sub(sExpression,1,1)
			end
			sExpString = sExpString .. sOperand .. "|"
		end
		
		
		-- 处理 左括号"("
		if (string.len(sExpression) > 0 and string.sub(sExpression,1,1) == "(") then
			vOperatorList[#vOperatorList + 1] = "("
			sExpression = string.sub(sExpression,2,string.len(sExpression))
		end
		
		-- 处理 右括号")"
		sOperand = ""
		if (string.len(sExpression) > 0 and string.sub(sExpression,1,1) == ")") then
			while (true) do
				if (vOperatorList[#vOperatorList] ~= "(") then
					sOperand = sOperand .. vOperatorList[#vOperatorList] .. "|"
					vOperatorList[#vOperatorList] = nil
				else
					vOperatorList[#vOperatorList] = nil
					break
				end
			end
			sExpString = sExpString .. sOperand
			sExpression = string.sub(sExpression,2,string.len(sExpression))
		end
		
		-- 处理各个运算符号+-*/^
		sOperand = ""
		if (string.len(sExpression) > 0) then
			__s = string.sub(sExpression,1,1)
			if ((__s == "+") or (__s == "-") or (__s == "*") or (__s == "/") or (__s == "^")) then
				sOperator = __s
				if (#vOperatorList > 0) then
					if ((vOperatorList[#vOperatorList] == "(") or verifyOperatorPriority(sOperator, vOperatorList[#vOperatorList])) then
						vOperatorList[#vOperatorList + 1] = sOperator
					else
						sOperand = sOperand .. vOperatorList[#vOperatorList] .. "|"
						vOperatorList[#vOperatorList] = nil
						vOperatorList[#vOperatorList + 1] = sOperator
						sExpString = sExpString .. sOperand
					end
				else
					vOperatorList[#vOperatorList + 1] = sOperator
				end
				sExpression = string.sub(sExpression,2,string.len(sExpression))
			end
		end
	end
	
	sOperand = ""
	-- 处理运算符号堆栈
	while(#vOperatorList ~= 0) do
		sOperand = sOperand .. vOperatorList[#vOperatorList] .. "|"
		vOperatorList[#vOperatorList] = nil
	end
	-- 去掉最后一个|，添加到整个后续表达式
	sExpString = sExpString .. string.sub(sOperand,1,string.len(sOperand) - 1)
	-- 返回转换好的后序表达式
	return sExpString
end

-- 判断某个操作数是否为操作数(非运算符的时候就是操作数啦~)
local function isOperand(str)
	return not( str == "+" or str == "-" or str == "*" or str == "/" or str == "^")
end

-- 从引擎获取数值
local function getNumber(source, target, ability, str)
	-- 如果能直接转换为数值，那么直接返回转换后的数值
	if (tonumber(str)) then return tonumber(str) end

	if (string.sub(str,1,2) == "s_") then -- 以s_开头的，为source的API函数
		local apiFunc = string.sub(str,3,string.len(str))
		if (source[apiFunc]) then
			if (type(source[apiFunc]) == "function") then
				return source[apiFunc](source)
			end
		end
		Warning("DamageSystem.lua throws an error: "..str.." is not a valid engiene api, returning 1\n")
		return 1
	end

	if (string.sub(str,1,2) == "t_") then -- 以t_开头的，为target的API函数
		local apiFunc = string.sub(str,3,string.len(str))
		if (target[apiFunc]) then
			if (type(target[apiFunc]) == "function") then
				return target[apiFunc](target)
			end
		end
		Warning("DamageSystem.lua throws an error: "..str.." is not a valid engiene api\nDID YOU FORGET THE \"s_\" or \"t_\"\n this operand is returning 1\n")
		return 1
	end

	if (string.sub(str,1,1) == "%") then -- 以%开头的，那么去从技能获取SpecialValue
		local specialString = string.sub(str,2,string.len(str))
		return ability:GetLevelSpecialValueFor(specialString, ability:GetLevel() - 1)
	end
	-- 不然抛出一个错误返回1
	Warning("DamageSystem.lua throws an error: "..str.." is not a valid format, returning 1")
	return 1
end

-- 计算伤害数值的函数
local function CalculateDamage(source, target , ability, formula, formated_formula)
	local vOperandList = {}
	local fOperand1 = nil
	local fOperand2 = nil
	
	formated_formula = stringReplace(formated_formula," ", "")
	local vOperand = stringSplit(formated_formula,"|")
	
	for i = 1, #vOperand do
		-- 只要不是运算符的，那么都去获取具体的数值
		if (isOperand(vOperand[i])) then
			vOperandList[#vOperandList + 1] = getNumber(source, target, ability, vOperand[i])
			print("getNumber result for ".. vOperand[i].." is "..getNumber(source, target, ability, vOperand[i]))
		else
			-- 两个操作数和一个操作符退栈运算
			fOperand2 = tonumber(vOperandList[#vOperandList])
			vOperandList[#vOperandList] = nil
			fOperand1 = tonumber(vOperandList[#vOperandList])
			vOperandList[#vOperandList] = nil
			if (fOperand1 == nil or fOperand2 == nil) then
				Warning("MATH ERROR! ExpressionError! The fomular is:" .. formula, "returning nil")
				return nil
			end
			vOperandList[#vOperandList + 1] = calculate(fOperand1,fOperand2,vOperand[i])
		end
	end

	-- 返回根节点
	return vOperandList[1]
end

vDamage = {}
local vDamage = vDamage
setmetatable(vDamage, vDamage)

vDamage.damage_mt = {
	__index = {
		attacker = nil,
		victim = nil,
		damage = 0,
		damage_type = DAMAGE_TYPE_PURE,
		damage_flags = 0
	}
}

-- 伤害函数
function Damage(keys)
	-- 伤害来源（施法者）、目标列表、方程式、技能
	local source = keys.caster
	local targets = keys.target_entities
	local formula = keys.formula
	local ability = keys.ability
	if not (source and targets and ability and formula and #targets > 0) then return end
	
	local damage = keys

	setmetatable(damage, vDamage.damage_mt)

	damage.attacker = source
	damage.damage_type = _G[damage.Type] or damage.Type

	local nDamageFlags = 0
	if damage.Flags and type(damage.Flags) == "string" then
		local sDamageFlags = stringReplace(damage.Flags," ","")
		local vDamageFlags = stringSplit(sDamageFlags,"|")
		for _,flag in pairs(vDamageFlags) do
			nDamageFlags = nDamageFlags + (_G[flag] or 0)
		end
	end

	damage.damage_flags = nDamageFlags

	-- 将函数式转换为后序表达式
	local formated_formula = CalculateParenthesesExpression(formula)
	
	for _, target in pairs(targets) do
		if target:IsAlive() then
			damage.victim = target
			-- 根据后序表达式计算伤害数值
			damage.damage = CalculateDamage(source, target, ability, formula, formated_formula)
			print("DamageSystem: damage calculation result is:", damage.damage)
			print("DamageSystem: damage type is:".. damage.damage_type)
			if (damage.damage ~= nil and damage.damage ~= 0) then
				local damage_dealt = ApplyDamage(damage)
				print("DamageSystem: Damage dealt to target ".. target:GetUnitName() .. " is "..damage_dealt)
			end
		end
	end
end


function CDOTA_BaseNPC:GetAP()
	return self.__ap or 100
end

function CDOTA_BaseNPC:SetAP(value)
	self.__ap = value
end