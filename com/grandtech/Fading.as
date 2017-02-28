package com.grandtech {
	import flash.display.DisplayObject;
	
	public final class Fading implements ITransitionStrategy{
		private static var self:Fading;
		private var 
			transitObj:DisplayObject,
			scale:Number;
		
		public static function getInstance(_mc:DisplayObject, _scale:Number):Fading{
			if(self == null){
				self = new Fading(new SingletonEnforcer());
			}

			self.transitObj = _mc;
			self.scale = _scale;

			return self;
		}
		
		public function Fading(foo:SingletonEnforcer) {}
		
		public function transit():void{
			transitObj.alpha += scale;
		}
	}
}
internal class SingletonEnforcer {}