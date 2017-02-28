package com.grandtech {
	import flash.display.MovieClip;
	
	public final class StarRating extends MovieClip{
		private var _rate:uint;
		
		public function StarRating() {
			mouseEnabled = false;
			mouseChildren = false;
		}
		
		public function set stars(rate:uint):void{
			_rate = rate;
			gotoAndPlay(rate);
		}
		
		public function get stars():uint{
			return _rate;
		}
	}
	
}
