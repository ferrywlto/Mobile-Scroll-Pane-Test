package com.grandtech {
	import org.osmf.media.MediaFactory;
	import org.osmf.media.URLResource;
	import org.osmf.media.MediaType;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.metadata.TimelineMetadata;
	import org.osmf.metadata.CuePoint;
	import org.osmf.metadata.CuePointType;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.TimelineMetadataEvent;
	import org.osmf.containers.MediaContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;	
	import flash.display.Sprite;
	import flash.text.TextField;
	
	public final class OSMFVideoPane extends Sprite{
		
		private static const 
			//serverURL:String = "http://202.134.125.204:8500/mbs_content/uploads/";
			serverURL:String = "http://192.168.0.232:8500/mbs_content/uploads/";
			//serverURL:String = "rtmp://solutions.grandtech.com.hk/vod/";
		private var 
			owner:ScrollPaneTest,
			contentToPlay:String,
			mf:MediaFactory,
			res:URLResource,
			player:MediaPlayer,
			tlMeta:TimelineMetadata,
			cuePt:CuePoint,
			num:uint,
			stateObj:Object;
					
		private var 
			mCon:MediaContainer,
			element:MediaElement;
			
		private var cueInfoObj:Object =  {title:"",desc:""};
		
		public function OSMFVideoPane(_owner:ScrollPaneTest) {
			//trace("serverURL:"+serverURL);
			owner = _owner;
			cuepoint_mc.visible = false;
			mouseEnabled = false;
			
	
			stateObj = new Object();
			stateObj.x = x;
			stateObj.y = y;
			stateObj.alpha = alpha;
			stateObj.visible = visible;
			
			cuePt = new CuePoint(CuePointType.ACTIONSCRIPT, 5, "cuepoint1", cueInfoObj, 5);
			
			mf = new DefaultMediaFactory();
			player = new MediaPlayer();
			mCon = new MediaContainer();
			addChildAt(mCon,1);
			mCon.width = 320;
			mCon.height = 240;
			mCon.x = 0;
			mCon.y = 0;
		}
		
		private function onMarkerReached(evt:TimelineMetadataEvent):void{
			evt.stopPropagation();
			if((evt.marker as CuePoint).name == "cuepoint1"){
				cuepoint_mc.visible = true;
			}
		}
		private function onMarkerDurationReached(evt:TimelineMetadataEvent):void{
			evt.stopPropagation();
			if((evt.marker as CuePoint).name == "cuepoint1"){
				cuepoint_mc.visible = false;
			}
		}
		private function updateStateInfo(evt:PlayEvent):void{
			evt.stopPropagation();
			btnPlay.visible = !player.playing;
			if(evt.playState == "stopped")
			{
				if(tlMeta != null){
					tlMeta.removeEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onMarkerReached);
					tlMeta.removeEventListener(TimelineMetadataEvent.MARKER_DURATION_REACHED, onMarkerDurationReached);
					tlMeta = null;
				}
			}
		}
			
		private function playVideo(evt:MouseEvent):void{
			evt.stopPropagation();
			cueInfoObj.title = tfCell.tf_title.text;
			cueInfoObj.desc = tfCell.tf_desc.text;
			
			res = new URLResource(serverURL+contentToPlay);
			res.mediaType = MediaType.VIDEO;
			element = mf.createMediaElement(res);
			
			player.autoPlay = true;
			player.media = element;
			
			mCon.addMediaElement(element);
			
			tlMeta = new TimelineMetadata(player.media);
			tlMeta.addMarker(cuePt);
			tlMeta.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onMarkerReached);
			tlMeta.addEventListener(TimelineMetadataEvent.MARKER_DURATION_REACHED, onMarkerDurationReached);
			player.media.addMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE, tlMeta);
		}
		
		private function resetPane(evt:MouseEvent):void{		
			evt.stopPropagation();
			owner.resetPane();
		}
		
		public function setWhatToPlay(sTitle:String, sDesc:String, sVidLoc:String):void{
			tfCell.tf_title.text = sTitle;
			tfCell.tf_desc.text = sDesc;
			contentToPlay = sVidLoc;
			trace(contentToPlay);
		}

		public function disable():void{
			if(player.playing){
				player.stop();
			}
			player.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, updateStateInfo);
			if(element != null){
				mCon.removeMediaElement(element);
			}
			element = null;
			res = null;
			
			btnPlay.removeEventListener(MouseEvent.CLICK, playVideo);
			btnBack.removeEventListener(MouseEvent.CLICK, resetPane);
			
			stateObj.x = x;
			stateObj.y = y;
			stateObj.alpha = alpha;
			stateObj.visible = visible;
		}
		
		public function enable():void{
			player.addEventListener(PlayEvent.PLAY_STATE_CHANGE, updateStateInfo);
			btnPlay.addEventListener(MouseEvent.CLICK, playVideo);
			btnBack.addEventListener(MouseEvent.CLICK, resetPane);
			cuepoint_mc.visible = false;
			
			x = stateObj.x;
			y = stateObj.y;
			alpha = stateObj.alpha;
			visible = stateObj.visible;
		}
	}
}