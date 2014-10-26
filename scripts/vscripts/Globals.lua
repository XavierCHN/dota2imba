ADDON_PREFIX = "[IMBA]: "


function TableCount(table)
	if type(table) ~= "table" then return nil end
	ret = 0
	for _ in pairs(table) do
		ret = ret + 1
	end
	return ret
end

function tPrint(msg)
	print(ADDON_PREFIX, msg)
end

function FireEffectAndRelease(particlename, target, vec )
	local p_index = ParticleManager:CreateParticle(particlename, PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl(p_index,0,vec)
	ParticleManager:ReleaseParticleIndex(p_index)
end

local function getTabs(nTabCount)
	if nTabCount < 0 then
		nTabCount = 0
	end
	local retStr = ""
	for i = 1,nTabCount do
		retStr = retStr.."\t"
	end
	return retStr
end
function KeyValueToStringTalbe(kvTable, depth)
	local retTable = {}
	if depth == 1 then
		table.insert(retTable, getTabs(depth).."\""..tostring(kvTable).."\"")
	end
	table.insert(retTable, getTabs(depth).."{")
	for Key,Value in pairs(kvTable) do
		if type(Value) ~= "table" then
			stringKVLine = getTabs(depth + 1).."\""..tostring(Key).."\""..getTabs(15 - math.floor(#tostring(Value) / 4))
				.."\""..tostring(Value).."\""
			table.insert(retTable,stringKVLine)
		else
			table.insert(retTable, getTabs(depth + 1).."\""..tostring(Key).."\"")
			local tbl = KeyValueToStringTalbe(Value, depth + 1)
			for _, line in pairs(tbl) do
				table.insert(retTable, line)
			end
		end
	end
	table.insert(retTable, getTabs(depth).."}")
	return retTable
end