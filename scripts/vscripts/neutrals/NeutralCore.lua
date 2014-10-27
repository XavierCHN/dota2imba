if NeutralCore == nil then
	NeutralCore = class({})
end
function NeutralCore:Init()
	ListenToGameEvent("entity_killed",Dynamic_Wrap(NeutralCore,"OnNeutralKilled"),self)
	self.all_item_name = self:CollectAllItemTable()
end
function NeutralCore:CollectAllItemTable()
	local kvs = LoadKeyValues('scripts/npc/npc_items_custom.txt')

end
function NeutralCore:CollectItemNameFromKVFile(file_name)
	local 
end
function NeutralCore:OnNeutralKilled(keys)
	local attacker = EntIndexToHScript(keys.entindex_attacker)
	local victim = EntIndexToHScript(keys.entindex_killed)
	if not victim:IsNeutralUnitType() then return end
	print("A NEUTRAL WAS KILLED!!")
end