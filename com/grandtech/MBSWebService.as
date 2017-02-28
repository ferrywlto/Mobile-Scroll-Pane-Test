package com.grandtech {
	import mx.rpc.events.ResultEvent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.soap.WebService;
	
	public class MBSWebService {

		private static var 
			ws:WebService,
			sessionID:String,
			client:WebServiceClient;
			
		//private static const serverURL:String = "http://202.134.125.204:8500";  //Eman Machine
		private static const serverURL:String = "http://192.168.0.232:8500";  //for DEMO 
		//private static const serverURL:String = "http://solutions.grandtech.com.hk:8134 " // John Machine
		
		public static function init(_client:WebServiceClient):void{
			client = _client;
			if(sessionID == null){
				ws = new WebService(); 
				ws.addEventListener("fault", ws_onError); 
				ws.wsdl=serverURL+"/mbs_content/scripts/sec_component2.cfc?wsdl";
				ws.loadWSDL();
				ws.sec_set_access_logs.addEventListener("result", ws_onResult_AccessLog);
				ws.sec_set_access_logs("","");// must pass "" even the request type paramater is optional, strange.
			}
		}
		
		public static function getList(_client:WebServiceClient, termSearch:String):void{
			client = _client;
			ws = new WebService();
			ws.wsdl=serverURL+"/mbs_content/scripts/vod_component2.cfc?wsdl";
			ws.loadWSDL();
			ws.vod_get_contentsNthumbnail_list_inpopularity_ins.addEventListener("result", ws_onResult_GetList);
			ws.vod_get_contentsNthumbnail_list_inpopularity_ins(sessionID, "vc.contents_title like '%"+termSearch+"%' ","ORDER BY contents_title DESC Limit 20");
		}
		
		private static function ws_onResult_GetList(event:ResultEvent):void{
			event.stopPropagation();
			//trace(event.result);
			client.notifyComplete(event.result);
		}
		private static function ws_onResult_AccessLog(event:ResultEvent):void{
			event.stopPropagation();
			sessionID = event.result.result.row.access_logs_session_id;
			//trace(sessionID);
			client.notifyComplete(event.result);
		}

		private static function ws_onError(event:FaultEvent):void { 
			event.stopPropagation();
			client.notifyError(event.fault.getStackTrace());
		} 
	}
}
