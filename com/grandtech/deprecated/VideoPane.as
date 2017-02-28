package com.grandtech {
	import flash.display.MovieClip;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.geom.Rectangle;
	import flash.media.StageVideo;
	
	public final class VideoPane extends MovieClip{
		private var owner:ScrollPaneTest;
		private var vid:Video;
		private var nc:NetConnection;
		private var ns:NetStream;
		private var tfStatus:TextField;
		private var btnPlay:MovieClip;
		private var btnBack:MovieClip;
		private var sWhatToPlay:String;
		
		public function VideoPane(_owner:ScrollPaneTest) {
			
			owner = _owner;
			
			vid = new Video(320,240);
			addChild(vid);
			vid.x = vid.y = 0;
			
			tfStatus = new TextField();
			addChild(tfStatus);
			tfStatus.x = 0;
			tfStatus.y = 240;
			tfStatus.width = 320;
			tfStatus.height = 80;
			
			btnPlay = new MovieClip();
			addChild(btnPlay);
			btnPlay.graphics.beginFill(0x00CCFF);
			btnPlay.graphics.drawRect(0,0,320,80);
			btnPlay.graphics.endFill();
			
			btnPlay.x =0;
			btnPlay.y = 320;
			btnPlay.width = 320;
			btnPlay.height = 80;
			btnPlay.addEventListener(MouseEvent.CLICK, playVideo);
			
			var tfPlay:TextField = new TextField();
			tfPlay.text = "Play";
			btnPlay.addChild(tfPlay);
			
			btnBack = new MovieClip();
			addChild(btnBack);
			btnBack.graphics.beginFill(0xCC00FF);
			btnBack.graphics.drawRect(0,0,320,80);
			btnBack.graphics.endFill();
			
			btnBack.x =0;
			btnBack.y = 400;
			btnBack.width = 320;
			btnBack.height = 80;
			btnBack.addEventListener(MouseEvent.CLICK, resetPane);
			
			var tfBack:TextField = new TextField();
			tfBack.text = "Back";
			btnBack.addChild(tfBack);
			
			
			width = 320;
			height = 480;
			
			nc = new NetConnection();
			nc.client = {};
			nc.client.onBWDone = function ():void {};
			nc.addEventListener(NetStatusEvent.NET_STATUS, H_netStatus);
			
		}
		
		public function setWhatToPlay(str:String):void{
			tfStatus.text = "Selected: "+str;
		}
		
		public function resetPane(evt:MouseEvent):void{
			if(ns!=null){
			vid.clear();
			ns.play(false);
			vid.attachNetStream(null);}
			owner.resetPane();
		}

		public function H_netStatus(event:NetStatusEvent):void
			{
				tfStatus.text = event.info.code.toString();
				switch (event.info.code) {
					case "NetConnection.Connect.Success":
						connectStream();
						//currentState = "Stop";
						break;
				}		
			}
			public function playVideo(event:MouseEvent):void
			{
				btnPlay.enabled = false;
				nc.connect("rtmp://192.168.0.231/vod");
/*				switc)
				{
					case "live": nc1.connect("rtmp://202.134.125.201/live"); break;
					case "vod1": 
					case "vod2": 
					case "vod3": nc1.connect("rtmp://202.134.125.201/vod"); break;
					default: break;
				}*/
			}
			protected function connectStream():void
			{
				//use non-skinable video component
				ns = new NetStream(nc);
				ns.client = {};
				ns.client.onMetaData = function ():void {};
				ns.addEventListener(NetStatusEvent.NET_STATUS,H_netStatus);
				//vid.attachNetStream(ns);
				
				var v:Vector.<StageVideo> = stage.stageVideos;
				var sv:StageVideo = v[0];
				sv.viewPort = new Rectangle(0,0,320,240);
				sv.attachNetStream(ns);
				
				if(Math.ceil(Math.random()*10)%2 == 0){
					ns.play("sample");}
				else{
					ns.play("mp4:sample1_150kbps.f4v");
				}
					
/*				switch(ddl.selectedItem.toString())
				{
					case "live": stream.play("livestream"); break;
					case "vod1": stream.play("sample"); break;
					case "vod2": stream.play("mp4:sample1_150kbps.f4v"); break;
					case "vod3": stream.play("mp4:sample1_700kbps.f4v"); break;
					default: break;
				}	*/
			}
	}
}
