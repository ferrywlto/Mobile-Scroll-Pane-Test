package com.grandtech {
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.display.MovieClip;
	
	public final class BasicVerticalSwipe extends MovieClip implements VerticalSwipeStrategy {
		private static const scalingFactor:Number = 0.5;
		private static const con:uint = 20;

		private var swipeObj:DisplayObject;
		private var mov:uint;
		private var limit1:int;
		private var mode:uint; //0 - no move, 1 - up, 2 - down
		
		public function BasicVerticalSwipe(obj2mov:DisplayObject) {
			swipeObj = obj2mov;
			limit1 = -1*swipeObj.height+480;
			mov = con;
			addEventListener(Event.ENTER_FRAME, onEnterframe);
			//trace(limit1);
		}
		
		public function onEnterframe(evt:Event):void{
			if(mode == 0){
				return;
			}
			else if(mode == 1){
				swipeObj.y = (swipeObj.y <= limit1) ? limit1 : swipeObj.y - mov;
				if(--mov == 0 || swipeObj.y == limit1){
					stopMove();
				}
			}
			else if(mode == 2){
				swipeObj.y = (swipeObj.y >= 0) ? 0 : swipeObj.y + mov;
				if(--mov == 0 || swipeObj.y == 0){
					stopMove();
				}
			}
		}
		
		public function swipe(value:Number):void{
			mov = Math.floor(value*scalingFactor);
			if(mov != 0){
				mode = (mov > 0)? 2 : 1;
			}
		}
		
		public function swipeUp():void{
			stopMove();
			mode = 1;
		}
		
		public function swipeDown():void{
			mode = 2;
		}
		
		private function stopMove():void{
			mode = 0;
			mov = con;
		}
	}
}