require('items/ItemCore')

local DROP_RATE = 7

if NeutralCore == nil then
	NeutralCore = class({})
end
function NeutralCore:Init()
	_, self._max_value_item_cost, _, self._min_value_item_cost = ItemCore:GetMaxAndMiniumValueItemsFromShop()
	ListenToGameEvent("entity_killed",Dynamic_Wrap(NeutralCore,"OnNeutralKilled"),self)
	
end

function NeutralCore:OnNeutralKilled(keys)
	local attacker = EntIndexToHScript(keys.entindex_attacker)
	local victim = EntIndexToHScript(keys.entindex_killed)
	if not victim:IsNeutralUnitType() then return end
	print("A NEUTRAL WAS KILLED!!")
	
	if RandomInt(1,100) > DROP_RATE then return end
	
	local item_to_drop = ItemCore:GetRandomShopItem()
	
	local item = CreateItem(item_to_drop, attacker, attacker)
	item:LaunchLoot(true,10,10,victim:GetOrigin()) --todo
end