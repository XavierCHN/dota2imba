-- 将本文件放置在scripts\vscripts\lib\目录中，并在addon_game_mode.lua中载入伤害系统， require('lib.SDamageSystem')
-- put this file into [your_addon\scripts\vscripts\lib\] directory, and add line [require('lib.SDamageSystem')] in [addon_game_mode.lua]

-- 食用方法

 	-- "RunScript"
 	-- {
 	-- 	 "ScriptFile"			"scripts/vscripts/lib/SDamageSystem.lua"
 	-- 	 "Function"				"Damage"
 	-- 	 "formula"				"(s_GetStrength - t_GetStrength) * %damage_amp_str_diff"
 	-- 	 "Target"
 	-- 	 {
 	-- 		[TARGET VALUES]
 	-- 	 }
 	-- }

-- formula 当中，除了直接的数字，+-*/.()以外
-- 所有的字符都应当是以 s_/t_/% 开头的key
-- 如果字符出现错误，那么字符的计算结果将会为0

-- 所有支持的运算符，左括号和右括号同样支持

-- 将表达式转换为后序表达式的方法

-- 将某个字符替换为另一个字符
local stringReplace(str, src, res)
	local result = ""
	for i = 1, string.len(str) do
		if str[i] == src then
			result = result .. res
		else
			result = result .. src
		end
	end
	return result
end

-- 将计算公式转换为后序表达式

local function CalculateParenthesesExpression(sExpression)
	local vOperatorList = {}
	local sOperator = ""
	local sExpressionString = ""
	local sOperand = ""

	sExpression = stringReplace(sExpression, " ", "")
	while (string.len(sExpression) > 0) do

		sOperand = ""
		-- 处理数字
		if (tonumber(sExpression[1]) >=0 and tonumber(sExpression[1]) <= 9) then
			while(tonumber(sExpression[1]) >=0 and tonumber(sExpression[1]) <= 9 or sExpression[1] == ".")) then
				operand3 = operand3..sExpression[1]
				sExpression = string.sub(sExpression,2)
				if (sExpression == "") then break end
			end
			sExpressionString = sExpressionString .. sOperand .. "|"
		end

		-- 处理字符串

		-- 处理 %

		-- 处理左括号
		if (string.len(sExpression) > 0 and sExpression[1] == "(") then
			vOperatorList[#vOperatorList + 1] = "("
			sExpression = string.sub(sExpression,2)
		end

		-- 处理右括号
		sOperand = ""
		if (string.len(sExpression) > 0 and sExpression[1] == ")") then
			do
				if (vOperatorList[#vOperatorList] - 1) ~= "(" then
					sOperand = sOperand .. vOperatorList[#vOperatorList] .. "|"
					vOperatorList[#vOperatorList] = nil
				else
					vOperatorList[#vOperatorList] = nil
					break
				end
			while(true)
			sExpressionString = sExpressionString .. sOperand
			sExpression = string.sub(sExpression, 2)
		end

		-- 处理运算符
		sOperand = ""
		if (string.len(sExpression) >0 and (
				sExpression[1] == "+" or
				sExpression[1] == "-" or
				sExpression[1] == "*" or
				sExpression[1] == "/"
			)) then
			sOperator = sExpression[1]
			if (#vOperatorList>0) then
				if (vOperatorList[#vOperatorList] == "(" or verifyOperatorPriority(sOperator, vOperatorList[#vOperatorList])) then
					table.insert(vOperatorList, sOperator)
				else
					sOperand = sOperand .. vOperatorList[#vOperatorList] .. "|"
					vOperatorList[#vOperatorList] = nil
					vOperatorList[#vOperatorList + 1] = sOperator
					sExpressionString = sExpressionString .. sOperand
				end
			else
				vOperatorList[#vOperatorList + 1] = sOperator
			end
			sExpression = string.sub(sExpression, 2)
		end

		sOperand = ""
		while()

	end
end






function Damage(keys)

	if not type(keys) == "table" then return end

	local source = keys.caster
	local targets = keys.target_entities
	local formula = keys.formula

	if not source and target and keys.formula then return end

	local damageType = keys.ability:GetAbilityDamageType() or DAMAGE_TYPE_PURE

	local DAMAGE_TYPES = {
		["DAMAGE_TYPE_PURE"] = DAMAGE_TYPE_PURE,
		["DAMAGE_TYPE_PHYSICAL"] = DAMAGE_TYPE_PHYSICAL,
		["DAMAGE_TYPE_MAGICAL"] = DAMAGE_TYPE_MAGICAL,
		["DAMAGE_TYPE_COMPOSITE"] = DAMAGE_TYPE_COMPOSITE,
		["DAMAGE_TYPE_HP_REMOVAL"] = DAMAGE_TYPE_HP_REMOVAL
	}

	if keys.Type then if DAMAGE_TYPES[keys.Type] then damageType = DAMAGE_TYPES[keys.Type] end end

end