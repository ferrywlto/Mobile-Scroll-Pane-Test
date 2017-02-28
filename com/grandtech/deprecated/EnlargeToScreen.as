package com.grandtech {
	import flash.display.MovieClip;
	
	public final class EnlargeToScreen implements ITransitionStrategy{
		private var transitObj:MovieClip;
		private var scale:Number;
		
		public function EnlargeToScreen(_mc:MovieClip, _scale:Number) {
			transitObj = _mc;
			scale = _scale;
		}
		
		public function transit():void{
			transitObj.scaleX += scale;
			transitObj.scaleY += scale;
		}
	}
}