package  {
	
	import flash.display.MovieClip;
	
	import ValveLib.Globals;
	import ValveLib.ResizeManager;
	import ValveLib.Events.InputBoxEvent;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flashx.textLayout.formats.Float;
	import flash.ui.Keyboard;
			
	
	public class Loading extends MovieClip {
		
		public var gameAPI:Object;
		public var globals:Object;
		public var elementName:String;

		public var LoadingScreen:MovieClip;
		public var RightClickHandler:MovieClip;
		
		public var ToggleingCamera:Boolean;
		public var ToggleStartPosX:Number;
		public var ToggleStartPosY:Number;
		
		//public var btn:Button;
		
		public function Loading() {}
		
		public function OnTextSubmitted():void
		{
			trace("text submitted");
		}
		
		public function onLoaded() : void {			
			trace("LoadingScreen onLoaded");
			trace("version 10312346");
			
			visible = true;
			
			Globals.instance.resizeManager.AddListener(this);
			this.gameAPI.SubscribeToGameEvent("game_rules_state_change", this.OnStateChanged);
			
			this.ToggleingCamera = false;
			this.RightClickHandler.visible =false;
			
		}
		
		public function OnStateChanged( args:Object ){
			var newState = globals.Game.GetState()

			if (newState == 0)// init
			{
				trace("show loading screen");
				LoadingScreen.visible = true;
			}
			if (newState >= 2)//hero selection
			{
				trace("hide loading screen");
				LoadingScreen.visible = false;
				
			}
			//if (newState >= 3)// pregame
//			{
//				this.gameAPI.SubscribeToGameEvent("hero_picker_hidden", this.StartCameraControl);
//			}
		}
		
		public function onResize(re:ResizeManager) : * {
			trace("TINKER LASER: onScreenSizeChanged");
		}
		public function onScreenSizeChanged():void
		{
			trace("TINKER LASER: onScreenSizeChanged");
			LoadingScreen.width = stage.stageWidth;
			LoadingScreen.height = stage.stageHeight;
		}
		public function StartCameraControl():void
		{
			trace("begin to catch right click");
				this.RightClickHandler.visible = true;
				stage.focus = this.RightClickHandler;
				this.RightClickHandler.addEventListener(MouseEvent.MOUSE_DOWN, this.OnMouseDown);
				this.RightClickHandler.addEventListener(MouseEvent.MOUSE_UP, this.OnMouseUp);
				this.RightClickHandler.addEventListener(MouseEvent.MOUSE_MOVE, this.OnMouseMove);
				this.RightClickHandler.addEventListener(KeyboardEvent.KEY_DOWN, this.OnKeyDown);
				this.RightClickHandler.addEventListener(KeyboardEvent.KEY_DOWN, this.OnKeyUp);
		}
		public function OnMouseDown(e:MouseEvent):void
		{
			trace("right mouse down");
			trace(e.type);
			trace(e.toString());
			this.ToggleingCamera = true;
			this.ToggleStartPosX = e.stageX;
			this.ToggleStartPosY = e.stageY;
			var player_id:Number = globals.Players.GetLocalPlayer();
			var PlayerIDString = player_id.toString();
			trace(this.ToggleStartPosX);
			trace(this.ToggleStartPosY);
			//player_start_change_camera
			this.gameAPI.SendServerCommand( "player_start_change_camera " +PlayerIDString + " "+ this.ToggleStartPosX + " " + this.ToggleStartPosY );
		}
		public function OnMouseUp(e:MouseEvent):void
		{
			trace("mouse up")
			this.ToggleingCamera = false;
			var player_id:Number = globals.Players.GetLocalPlayer();
			var PlayerIDString = player_id.toString();
			this.gameAPI.SendServerCommand( "player_end_change_camera " +PlayerIDString);
		}
		
		public function OnMouseMove(e:MouseEvent):void
		{
			if(this.ToggleingCamera)
			{
				var currentX:Number = e.stageX;
				var currentY:Number = e.stageY;
				var XChange:String = (currentX - this.ToggleStartPosX).toString();
				var YChange:String = (currentY - this.ToggleStartPosY).toString();
				var player_id:Number = globals.Players.GetLocalPlayer();
				var PlayerIDString = player_id.toString();
				this.gameAPI.SendServerCommand( "player_change_camera "+PlayerIDString + " " + XChange + " " + YChange );
			}
		}
		public function OnKeyDown(e:KeyboardEvent):void
		{
			trace("KeydownCalled");
			trace(e.toString());
			
			this.gameAPI.SendServerCommand( "player_key_down " + e.keyCode.toString());
		}
		public function OnKeyUp(e:KeyboardEvent):void
		{
			this.gameAPI.SendServerCommand( "player_key_up " + e.keyCode.toString());
		}
	}
	
}
