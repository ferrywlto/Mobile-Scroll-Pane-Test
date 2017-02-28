package com.grandtech {
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	
	public class myTextField extends MovieClip {
		
		public var tf_test:TextField;
		public var dfText:String = "zzzzzz";
		public function myTextField() {
			this.tf_test.text = dfText;
			trace(this.tf_test.width);
		}
		
		[Inspectable(defaultValue="123456")] 
		public function get vABC():String{
			return this.tf_test.text;
		}
		
		public function set vABC(value:String):void{
			if (value == vABC) { 
				return;
			}

			trace("trying to set value");
			this.tf_test.text = value;
		}
	}
	
}
