require('items/ItemCore')

local DROP_RATE = 100

if NeutralCore == nil then
	NeutralCore = class({})
end
function NeutralCore:Init()
	_, self._max_value_item_cost, _, self._min_value_item_cost = ItemCore:GetMaxAndMiniumValueItemsFromShop()
	ListenToGameEvent("entity_killed",Dynamic_Wrap(NeutralCore,"OnNeutralKilled"),self)
	
end

function NeutralCore:OnNeutralKilled(keys)
	if not (keys.entindex_attacker and keys.entindex_killed) then return end
	local attacker = EntIndexToHScript(keys.entindex_attacker)
	local victim = EntIndexToHScript(keys.entindex_killed)
	if not victim:IsNeutralUnitType() then return end
	print("A NEUTRAL WAS KILLED!!")
	
	if RandomInt(1,100) > DROP_RATE then return end
	
	local item_to_drop = ItemCore:GetRandomShopItem()

	-- todo
	-- item_to_drop = "item_ultimate_scepter"

	local position = victim:GetOrigin()

	if item_to_drop then
		local item = CreateItem(item_to_drop, attacker, attacker)
		print(item_to_drop,item)
		item:SetPurchaseTime(0)

	    local drop = CreateItemOnPositionSync( position , item)
	    if drop then
	        drop:SetContainedItem( item )
	        item:LaunchLoot( false, 30, 0.35, position + RandomVector( RandomFloat( 1,10 ) ) )
	    end
	end
end