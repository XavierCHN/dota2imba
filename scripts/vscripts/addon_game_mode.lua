-- DOTA2 IMBA GAME MODE
-- AUTHOR: XAVIERCHN
-- 2014.10.24

--[[
	几乎所有的英雄技能代码都在abilities文件夹中
	AbilityCore是各种事件的响应
	以此派生出各种事件接口，比如说某个英雄释放某个技能/被释放技能的接口
	还有英雄学习某个技能的接口，用来处理副技能的情况
]]
require("Globals")
require('items/ItemCore')
require("abilities/AbilityCore")
require("neutrals/NeutralCore")
require('HudControl/CameraControl')

tPrint("Hello World!")
if ImbaGameMode == nil then
	tPrint("INITING GAME MODE")
	ImbaGameMode = class({})
end
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
	tPrint("BEGIN TO PRECACHE RESOURCE")
	local time = GameRules:GetGameTime()
	PrecacheEveryThingFromKV( context )
	time = time - GameRules:GetGameTime()
	tPrint("DONE PRECACHEING IN:"..tostring(time).."Seconds")
end
function ImbaGameMode:InitGameMode()
	tPrint("INITING IMBA GAME MODE")
	self._eGameModeEntity = GameRules:GetGameModeEntity()
	self._eGameModeEntity:SetTowerBackdoorProtectionEnabled( true )
	
	-- self._eGameModeEntity:SetContextThink( "ImbaGameMode:GameThink", function() return self:GameThink() end, 0.25 )

	ItemCore:Init() tPrint("DONE INIT ITEM CORE")
	AbilityCore:Init() tPrint("DONE INIT ABILITY CORE")
	NeutralCore:Init() tPrint("DONE INIT NEUTRAL CORE")
	-- CameraControl:Init() tPrint('DONE INIT CAMERA CONTROL')
	tPrint("DONE INIT IMBA GAME MODE")
end
function ImbaGameMode:GameThink()
	return 0.25
end