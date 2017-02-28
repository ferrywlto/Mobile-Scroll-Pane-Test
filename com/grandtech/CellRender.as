package com.grandtech  {
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	public final class CellRender extends Sprite {
		
		private var 
			desc:String,
			path:String,
			title:String,
			index:uint,
			rate:uint,
			image:Bitmap;
			
		public function CellRender() : void {
			cacheAsBitmap = false;
			mouseEnabled = false;
			
			image = new Bitmap();
			addChild(image);
			image.x = image.y = 3;
			image.width = 100;
			image.height = 60;
			
			celltxt.mouseEnabled = false;
			celltxt.mouseChildren = false;
			stars.mouseEnabled = false;
			stars.mouseChildren = false;
		}
		
		public function set v_path(_path:String):void{
			path = _path;
		}
		public function get v_path():String{
			return path;
		}
		public function set v_rate(_rate:uint): void{
			rate = _rate;
			stars.gotoAndPlay(_rate);
		}
		public function get v_rate():uint{
			return rate;
		}
		
		public function set v_image(bmd:BitmapData) :void{
			image.bitmapData = bmd;
			image.width = 100;
			image.height = 60;
		}
		
		public function getImage():Bitmap{
			return image;
		}
		
		//[Inspectable(name="Title", type=String, defaultValue="")]
		public function set v_title( str:String ) : void {
			title = str;
			celltxt.tx_title.text = title;
		}
		
		public function get v_title() : String {
			return title;
		}

		//[Inspectable(name="Description", type=String, defaultValue="")]
		public function set v_desc( str:String ) : void {
			desc = str;
			celltxt.tx_description.text = desc;
		}
		
		public function get v_desc() : String {
			return desc;
		}
		
		public function set v_index(idx:uint):void{
			index = idx;
		}
		public function get v_index():uint{
			return index;
		}
	}
	
}
