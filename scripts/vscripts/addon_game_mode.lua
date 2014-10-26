-- DOTA2 IMBA GAME MODE
-- AUTHOR: XAVIERCHN
-- 2014.10.24

require("AbilityCore")
require("Globals")

tPrint("Hello World!")

if ImbaGameMode == nil then
	tPrint("INITING GAME MODE")
	ImbaGameMode = class({})
end

--------------------------------------------------------------------------------
-- ACTIVATE
--------------------------------------------------------------------------------
function Activate()
	tPrint("ACTIVATE")
    GameRules.ImbaGameMode = ImbaGameMode()
    GameRules.ImbaGameMode:InitGameMode()
end

function PrecacheEveryThingFromKV( context )
	local kv_files = {"scripts/npc/npc_units_custom.txt","scripts/npc/npc_abilities_custom.txt","scripts/npc/npc_heroes_custom.txt","scripts/npc/npc_abilities_override.txt","npc_items_custom.txt"}
	for _, kv in pairs(kv_files) do
		local kvs = LoadKeyValues(kv)
		if kvs then
			print("BEGIN TO PRECACHE RESOURCE FROM: ", kv)
			PrecacheEverythingFromTable( context, kvs)
		end
	end
end
function PrecacheEverythingFromTable( context, kvtable)
	for key, value in pairs(kvtable) do
		if type(value) == "table" then
			PrecacheEverythingFromTable( context, value )
		else
			if string.find(value, "vpcf") then
				PrecacheResource( "particle",  value, context)
				print("PRECACHE PARTICLE RESOURCE", value)
			end
			if string.find(value, "vmdl") then
				PrecacheResource( "model",  value, context)
				print("PRECACHE MODEL RESOURCE", value)
			end
			if string.find(value, "vsndevts") then
				PrecacheResource( "soundfile",  value, context)
				print("PRECACHE SOUND RESOURCE", value)
			end
		end
	end
end

function Precache( context )
	PrecacheEveryThingFromKV( context )
end
--------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------
function ImbaGameMode:InitGameMode()
	tPrint("INITING IMBA GAME MODE")
	self._eGameModeEntity = GameRules:GetGameModeEntity()
	self._eGameModeEntity:SetTowerBackdoorProtectionEnabled( true )
	
	ListenToGameEvent("entity_killed", Dynamic_Wrap(ImbaGameMode, "OnEntityKilled"), self)
	tPrint("DONE REGIST GAME EVENT LISTENER")
	
	self._eGameModeEntity:SetContextThink( "ImbaGameMode:GameThink", function() return self:GameThink() end, 0.25 )

	AbilityCore:Init() tPrint("DONE INIT ABILITY CORE")
	tPrint("DONE INIT IMBA GAME MODE")
end

--------------------------------------------------------------------------------
function ImbaGameMode:GameThink()
	return 0.25
end
function ImbaGameMode:OnEntityKilled()
	--tPrint("ON-ENTITY-KILLED CALLED")
end