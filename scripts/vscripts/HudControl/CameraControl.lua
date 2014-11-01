if CameraControl == nil then
	CameraControl = class({})
end
function CameraControl:Init()

	self._cameraStart = {}

	Convars:RegisterCommand("player_change_camera",
		function(name, playerid, xchange, ychange)
			local cmdPlayer = Convars:GetCommandClient()
			if not cmdPlayer then return end
			local player_id = cmdPlayer:GetPlayerID()
			if not player_id then return end
			print(player_id,"changes camera", xchange, ychange)
			if not (self._cameraStart.player_id.x and  self._cameraStart.player_id.y
				and self._cameraStart.player_id.yaw and self._cameraStart.player_id.pitch) then return end
			local yaw_changed = xchange /2
			local pitch_changed = ychange /2
			local yaw = tostring((self._cameraStart.player_id.yaw - yaw_changed)%360)
			local pitch = tostring(self._cameraStart.player_id.pitch + pitch_changed)
			print("yaw is valid, changing",yaw)
			SendToConsole("dota_camera_yaw "..yaw)
			SendToConsole("dota_camera_pitch_max "..pitch)
			SendToConsole("dota_camera_pitch_min "..pitch)
			print(Convars:GetFloat("dota_camera_yaw"))
		end,
	"",0)
	Convars:RegisterCommand("player_start_change_camera",
		function(name, playerid, start_pos_x, start_pos_y)
			local cmdPlayer = Convars:GetCommandClient()
			if not cmdPlayer then return end
			local player_id = cmdPlayer:GetPlayerID()
			if not player_id then return end
			SendToServerConsole("sv_cheats 1")
			print(player_id,"start changes camera", start_pos_x, start_pos_y)
			if self._cameraStart.player_id == nil then self._cameraStart.player_id = {} end
			local hero = cmdPlayer:GetAssignedHero()
			if hero then PlayerResource:SetCameraTarget(player_id,hero) else return end
			local hero_origin = hero:GetOrigin()
			local set_pos_string = string.format("dota_camera_setpos %d %d %d", hero_origin.x, hero_origin.y, hero_origin.z)
			print(set_pos_string)
			SendToConsole(set_pos_string)
			self._cameraStart.player_id.x = start_pos_x
			self._cameraStart.player_id.y = start_pos_y
			self._cameraStart.player_id.yaw = Convars:GetFloat("dota_camera_yaw")
			self._cameraStart.player_id.pitch = Convars:GetFloat("dota_camera_pitch_max")

			print("pitch is ",Convars:GetFloat("dota_camera_pitch_max"))
		end, 
	"", 0)	
	Convars:RegisterCommand("player_end_change_camera", 
		function(name, playerid)
			local cmdPlayer = Convars:GetCommandClient()
			if not cmdPlayer then return end
			local player_id = cmdPlayer:GetPlayerID()
			if not player_id then return end
			self._cameraStart.player_id = {}
		end, 
	"", 0)

	Convars:RegisterCommand("player_key_down", function(name, keycode)end, "", 0)
	Convars:RegisterCommand("player_key_up", function(name, keycode)end, "", 0)
end