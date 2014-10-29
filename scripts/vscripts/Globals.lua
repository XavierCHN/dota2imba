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