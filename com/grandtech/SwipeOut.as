package com.grandtech {
	import flash.display.DisplayObject;
	
	public final class SwipeOut implements ITransitionStrategy{
		private static var self:SwipeOut;
		private var
			inTransitObj:DisplayObject, 
			outTransitObj:DisplayObject,
			offsetX:Number, 
			offsetAlpha:Number;
		
		public static function getInstance(in_mc:DisplayObject, out_mc:DisplayObject, _x:Number, _alpha:Number):SwipeOut{
			if(self == null){
				self = new SwipeOut(new SingletonEnforcer());
			}
			with(self){
				inTransitObj = in_mc;
				outTransitObj = out_mc;
				offsetX = _x;
				offsetAlpha = _alpha;
			}
			return self;
		}
		
		public function transit():void{
			inTransitObj.x += offsetX;
			outTransitObj.x += offsetX;
			inTransitObj.alpha += offsetAlpha;
			outTransitObj.alpha -= offsetAlpha;
		}
		
		public function SwipeOut(foo:SingletonEnforcer){}
	}
}
internal class SingletonEnforcer {}