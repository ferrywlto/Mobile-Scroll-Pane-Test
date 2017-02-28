package com.grandtech {
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.soap.WebService;
	import flash.media.StageVideo;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	public final class ScrollPaneTest extends Sprite implements WebServiceClient{
		public static var 
			stageFPS:uint;
		
		private static const 
			splash_steps:uint = 4,
			splash_duration:uint = 100,
			swipe_steps:uint = 4,
			swipe_duration:uint = 100,
			swipe_displacement:Number = 320/swipe_steps,
			swipe_vislevel:Number = 1/swipe_steps;
			
		public var
			vip:OSMFVideoPane;
			
		private var 
			vsp:VerticalSwipePane,
			tp:TracePane,
			ws:WebService,
			spScr:SplashScreen;
			
		public var cellData:Vector.<CellData>;
		private var state:uint = 0;
		
		public function ScrollPaneTest() {
			//trace(stage.stageVideos);
			stageFPS = stage.frameRate;
			
			mouseEnabled = false;
			//setupTracePane();
			startup();
		}
		
		private function setupTracePane():void{
			tp = new TracePane();
			addChild(tp);
			tp.y = 480 - tp.height;
			//TraceRouter.setTracer(tp.tf);
		}
		
		private function debug(msg:String):void{
			if(tp != null){}
				//TraceRouter._trace(msg);
			else
				trace(msg);
		}

		private function initUI():void{
			vip = new OSMFVideoPane(this);
			vsp = new VerticalSwipePane(this);	
			addChildAt(vsp,0);
			vsp.enable();
		}
		
		private function startup():void{
			//debug("1startup");			
			with(spScr = new SplashScreen()){ alpha = 0; x = 160; y = 240; }
			addChildAt(spScr,0);
			TimerTransition.transit(callWebService, splash_duration, splash_steps, Fading.getInstance(spScr,1/splash_steps));
		}
		
		private function callWebService():void { 
			MBSWebService.init(this);
		} 
		
		public function notifyComplete(obj:Object):void{
			if(state == 0){
				MBSWebService.getList(this,"");
				state = 1;
			}
			else if(state == 1){
				var xml:XML = new XML(obj.result);
				cellData = new Vector.<CellData>(xml.children().length());
				for(var i=0; i<cellData.length; i++){
					var cd:CellData = new CellData();
					var obj:Object = xml.vod[i];
					cd.title = obj.contents_title;
					cd.desc = obj.contents_description;
					cd.index = i;
					cd.rate = Math.ceil(obj.avg_rate);
					cd.imgURL = obj.vod_thumbnail;
					cd.vidpath = obj.contents_outputs_url;
					cellData[i] = cd;
				}
				//TimerTransition.transit(closeSplashScreen, splash_duration, splash_steps, Fading.getInstance(spScr,-1/splash_steps));
				closeSplashScreen();
			}
		}
		
		public function notifyError(obj:Object):void{
			spScr.tf_status.text = "Error Occured."
			trace(obj.toString());
		}
		
		private function closeSplashScreen():void{
			spScr.visible = false;
			removeChild(spScr);
			spScr = null;
			initUI();
		}
		
		private function vspInComplete():void {
			with(vsp){x = 0; alpha=1; visible=true;}
			with(vip){x = 320; alpha=0; visible=false; disable();}
			removeChild(vip);
		}
		
		private function vspOutComplete():void {
			with(vsp){x = -320; alpha=0; visible=false; disable();}
			with(vip){x = 0; alpha=1; visible=true;}
			removeChild(vsp);
		}

		public function transitPane(title:String, desc:String, path:String):void{
			with(vip){
				enable(); x = 320; alpha=0; visible=true;
				setWhatToPlay(title, desc, path);
			}
			addChildAt(vip,0);
			TimerTransition.transit(vspOutComplete, swipe_duration, swipe_steps, SwipeOut.getInstance(vsp, vip, -swipe_displacement, -swipe_vislevel));
		}
		
		public function resetPane():void{
			with(vsp){enable(); x = -320; alpha=1; visible=true;}
			addChildAt(vsp,0);
			TimerTransition.transit(vspInComplete, swipe_duration, swipe_steps, SwipeOut.getInstance(vsp, vip, swipe_displacement, swipe_vislevel));
		}
	}
	
}
