package com.grandtech {
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.display.Sprite;
	
	public final class Thumbnail extends Sprite{
		
		private static const imgURL:String = "http://202.134.125.201:8080/images/";//car.png";
		private var loader:Loader;
		
		public function Thumbnail() {
			visible = false;
			mouseEnabled = mouseChildren = false;
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			loader.load(new URLRequest(imgURL+"car"+Math.ceil(Math.random()*9)+".jpg"));
		}
		private function onComplete(evt:Event):void{
			evt.stopPropagation();
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			addChild(loader);
			cacheAsBitmap = true;
			width = 100;
			height = 60;
			visible = true;
		}
	}
	
}
