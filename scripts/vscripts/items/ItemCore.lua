require('Globals')


if ItemCore == nil then
	ItemCore = class({})
end

function ItemCore:Init()
	self._all_items = {}
	self._all_items_cost = {}
	self._all_items = self:CollectAllItemKVFromFile()
	
	self._all_shop_items = self:CollectAllShopItems()
end

local item_files = {
	'scripts/npc/items.txt',
	'scripts/npc/npc_items_custom.txt'
	}

function ItemCore:CollectAllItemKVFromFile()
	for _, file_name in pairs(item_files) do
		local items_from_kv = self:LoadItemsFromKV(file_name)
		if items_from_kv then
			for kv in pairs(items_from_kv) do
				table.insert(self._all_items, kv)
			end
		end
	end
end
function ItemCore:LoadItemsFromKV(file_name)
	local kvs = LoadKeyValues(file_name)
	if not kvs then return {} end
	local ret = {}
	
	for root, items in pairs(kvs) do
		if type(items) == "table" then
			for item_name, item_kv in pairs(items) do
				if type(item_kv) == "table" then
					table.insert(ret, item_name)
					for key, value in pairs(item_kv) do
						if key == "ItemCost" then
							self._all_items_cost[item_name] = tonumber(value)
							print("ITEM CORE, COLLECTED ITEM",item_name, value)
						end
					end
				end
			end
		end
	end
end

function ItemCore:CollectAllShopItems()
	local kvs = LoadKeyValues("scripts/shops/"..GetMapName()..".txt")
	if not kvs then return {} end
	local ret = {}
	for root, shop in pairs(kvs) do
		if type(shop) == "table" then
			for item, item_name in pairs(shop) do
				table.insert(ret, item_name)
			end
		end
	end
end
-- 在所有物品中查找最贵物品和最便宜物品
-- 返回 最贵物品，最贵价格， 最便宜物品， 最便宜价格
-- 
function ItemCore:GetMaxAndMiniumValueItems()
	local most_value_item = nil
	local most_invalue_item = nil
	local most_value_item_value = 0
	local most_invalue_item_value = -1
	
	for item_name, item_cost in pairs(self._all_items_cost) do
		if item_cost > most_value_item_value then
			most_value_item = item_name
			most_value_item_value = item_cost
		end
		if item_cost < most_invalue_item_value or most_invalue_item_value == -1 then
			most_invalue_item = item_name
			most_invalue_item_value = item_cost
		end
	end
	return most_value_item, most_value_item_value, most_invalue_item, most_invalue_item_value
end
-- 在所有商店出售的物品中查找最贵物品和最便宜物品
-- 返回 最贵物品，最贵价格， 最便宜物品， 最便宜价格
-- 
function ItemCore:GetMaxAndMiniumValueItemsFromShop()
	local most_value_item = nil
	local most_invalue_item = nil
	local most_value_item_value = 0
	local most_invalue_item_value = -1
	
	for _, items in pairs(self._all_shop_items) do
		local item_cost = self._all_items
		if item_cost > most_value_item_value then
			most_value_item = item_name
			most_value_item_value = item_cost
		end
		if item_cost < most_invalue_item_value or most_invalue_item_value == -1 then
			most_invalue_item = item_name
			most_invalue_item_value = item_cost
		end
	end
	return most_value_item, most_value_item_value, most_invalue_item, most_invalue_item_value
end

-- 尝试在单位身上找到某件物品
-- 返回，是否找到， 如果找到了，第二个参数为位置
function ItemCore:FindItemOnTarget(target, item_name, search_stack)
	local all_slots = 5
	if search_stack then
		all_slots = 11
	end 
	
	for i = 0,all_slots do
		local item = target:GetItemInSlot(i)
		if item then
			if item:GetName() == item_name then
				return true, i
			end
		end
	end
	return false, nil
end

function ItemCore:GetRandomShopItem()
	return self._all_shop_items[RandomInt(1,TableCount(self._all_shop_items))]
end