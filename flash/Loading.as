package  {
	
	import flash.display.MovieClip;
	
	import ValveLib.Globals;
	import ValveLib.ResizeManager;
	import flash.events.MouseEvent;
			
	
	public class Loading extends MovieClip {
		
		public var gameAPI:Object;
		public var globals:Object;
		public var elementName:String;

		public var LoadingScreen:MovieClip;
		
		public function Loading() {
			trace("LoadingScreen Loading");
		}
		
		public function onLoaded() : void {			
			trace("LoadingScreen onLoaded");
			//make this UI visible
			visible = true;

			//let the client rescale the UI
			Globals.instance.resizeManager.AddListener(this);
			this.gameAPI.SubscribeToGameEvent("game_rules_state_change", this.OnStateChanged);
		}
		
		public function OnStateChanged( args:Object ){
			var newState = globals.Game.GetState()

			if (newState == 0)// init
			{
				LoadingScreen.visible = true;
			}
			if (newState >= 2)//hero selection
			{
				//LoadingScreen.visible = false;
				LoadingScreen.addEventListener(MouseEvent.CLICK, this.OnLoadingScreenClick);
			}
			//DOTA_GAMERULES_STATE_INIT = 0,
			//DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD = 1,
			//DOTA_GAMERULES_STATE_HERO_SELECTION = 2,
			//DOTA_GAMERULES_STATE_STRATEGY_TIME = 3,
			//DOTA_GAMERULES_STATE_PRE_GAME = 4,
			//DOTA_GAMERULES_STATE_GAME_IN_PROGRESS = 5,
			//DOTA_GAMERULES_STATE_POST_GAME = 6,
			//DOTA_GAMERULES_STATE_DISCONNECT = 7,
			//DOTA_GAMERULES_STATE_TEAM_SHOWCASE = 8,
			//DOTA_GAMERULES_STATE_LAST = 9
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
		public function OnLoadingScreenClick(e:MouseEvent):void
		{
			LoadingScreen.visible = false
		}
	}
	
}
