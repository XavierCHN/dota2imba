package  {
	
	import flash.display.MovieClip;
	
	import ValveLib.Globals;
	import ValveLib.ResizeManager;
			
	
	public class TinkerLaser extends MovieClip {
		
		public var gameAPI:Object;
		public var globals:Object;
		public var elementName:String;

		public var block:MovieClip;
		
		public function TinkerLaser() {
			trace("TINKER LASER: TinkerLaser");
		}
		
		public function onLoaded() : void {			
			trace("TINKER LASER: onLoaded");
			//make this UI visible
			visible = true;
			
			//let the client rescale the UI
			Globals.instance.resizeManager.AddListener(this);
			this.gameAPI.SubscribeToGameEvent("imba_laser_hit_unit", this.ShowBlock);
			this.gameAPI.SubscribeToGameEvent("imba_laser_disappear", this.HideBlock);
			
			block.visible = false;
		}
		
		public function ShowBlock( args:Object ){
			trace("TINKER LASER: ShowBlock");
			var pID:int = this.globals.Players.GetLocalPlayer();
			
			if( pID == args.PlayerID ) {
				trace(pID.toString())
				block.visible = true;
			}
		}
		
		public function HideBlock( args:Object ){
			trace("TINKER LASER: HideBlock");
			var pID:int = this.globals.Players.GetLocalPlayer();
			
			if( pID == args.PlayerID) {
				if(block.visible == true){
					block.visible = false;
				}
			}
		}
		public function onResize(re:ResizeManager) : * {
			trace("TINKER LASER: onScreenSizeChanged");
		}
		public function onScreenSizeChanged():void
		{
			trace("TINKER LASER: onScreenSizeChanged");
			block.width = stage.stageWidth;
			block.height = stage.stageHeight;
		}
	}
	
}
