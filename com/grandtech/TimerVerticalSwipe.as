package com.grandtech {
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.display.Sprite;
	
	public final class TimerVerticalSwipe {
		private static const
			scalingFactor:Number = 0.2,
			time_to_swipe:uint = 1500,
			timer_interval:Number = time_to_swipe/ScrollPaneTest.stageFPS,
			num_timer_call:Number = time_to_swipe/timer_interval,
			movOffset:uint = 1;
		private var 
			timer:Timer,
			swipeObj:Sprite,
			swipeNum:uint,
			mov:Number,
			limit1:int,
			tmp:Number;
			
		public var
			mode:uint; //0 - no move, 1 - up, 2 - down
			
		public function TimerVerticalSwipe(obj2mov:Sprite) {
			swipeObj = obj2mov;
			limit1 = -1*swipeObj.height+480;
			timer = new Timer(timer_interval);
			swipeNum = swipeObj.numChildren;
		}

		private var realMov:Number;
		public function onTimer(evt:Event):void{
			evt.stopPropagation();
			if(mode == 0){ return; }
			else if(mode == 1){ realMov = -mov; }
			else if(mode == 2){ realMov = mov; }
			for(tmp=0; tmp<swipeNum; tmp++){
				swipeObj.getChildAt(tmp).y += realMov;
			}
			mov-=movOffset;
			if(mov<=0){stopMove();}
		}

		
		public function swipe(value:int):void{
			stopMove();
			if(value == 0){
				return;
			}
			else{
				timer.addEventListener(TimerEvent.TIMER, onTimer);
				timer.start();

				//mov = Math.ceil((Math.abs(value)*scalingFactor));
				
				//var frame_interval = 1000/ScrollPaneTest.stageFPS;
				//totalMov = (value+1*value)/2; //*num_timer_call/2;
				//totalPiece = (num_timer_call+1)*num_timer_call/2;
				//movOffset = Math.abs(totalMov/totalPiece);
				//mov = Math.abs(movOffset*num_timer_call);
				//trace(totalMov+":"+totalPiece+":"+movOffset+":"+mov);
				
				mode = (value > 0)? 2 : 1;
				mov = Math.abs(value);
					//trace("mov:"+mov);
			}
		}
		
		private function stopMove():void{
			//trace("stopmove");
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, onTimer);
			mov = 0;
			mode = 0;
		}
	}
}
