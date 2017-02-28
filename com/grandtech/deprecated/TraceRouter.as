package com.grandtech {
	import flash.text.TextField;
	
	public final class TraceRouter {
		private static var tf_Trace:TextField;
		
		public static function setTracer(_tf:TextField) :void{
			tf_Trace = _tf;
		}

		public static function _trace(msg:String):void{
			if(tf_Trace != null){
				trace(msg);
				tf_Trace.appendText(msg + "\n");
				tf_Trace.scrollV = tf_Trace.maxScrollV;
			}
			else{
				trace("TraceRouter not initialized.");
			}
		}
	}
	
}
