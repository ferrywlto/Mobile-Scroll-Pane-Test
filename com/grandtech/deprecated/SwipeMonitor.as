package com.grandtech {
	
	import com.grandtech.*;
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	public final class SwipeMonitor extends MovieClip implements ISwipeObserver{
		private var count:uint =0;
		protected var tf:TextField;
		public function SwipeMonitor() {
			tf = new TextField();
			addChild(tf);
			tf.x = tf.y = 0;
			tf.width = 100;
			tf.height = 50;
			tf.background = true;
			tf.backgroundColor = 0xFF0000;
			tf.text = "nothing detected.";
		}

		public function notifySwipe(vsp:VerticalSwipePane):void{
			tf.text = "swipe detected:"+(count++);
		}
	}
	
}
