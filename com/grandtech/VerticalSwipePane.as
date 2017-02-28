package com.grandtech {
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.events.GestureEvent;
	import flash.events.TransformGestureEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.events.Event;
	
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.display.BitmapData;
	import flash.sampler.getSize;
	import flash.display.Bitmap;
	import flash.system.LoaderContext;
	import flash.events.FocusEvent;

	public final class VerticalSwipePane extends Sprite implements WebServiceClient{
		
		private static const 
			//serverURL:String = "http://localhost/images/",
			//http://202.134.125.204:8500/mbs_content/uploads/shared/00000191/00000203/output/83_000011401_thm.jpg
			//serverURL:String = "http://202.134.125.204:8500/mbs_content/uploads/",
			serverURL:String = "http://192.168.0.232:8500/mbs_content/uploads/",
			max_scaling:Number = 1.1, 
			numCells:Number = 7, 
			upperMov:Number = numCells*87.85,
			lowerMov:Number = (numCells)*87.85, 
			lowerBound:Number = (numCells-1)*86.85, 
			timer_interval:uint = 25, stageHeight:uint = 440,
			MOUSE_UP_DEC_FACTOR:Number = 0.2, MOUSE_DOWN_DEC_FACRTOR:Number = 0.9;
			
		private var
			i:uint = 0, imgNum:uint = 0, scrollIdx:uint = 0, w:uint = 0,
			mDown:Boolean = false,
			scaling:Number = max_scaling, offsetY:Number,			
			oldClickY:Number, oldMovieY:Number, oldMouseY:Number,
			maxScroll:Number, tmpMouseMove:Number, cell_height:Number,
			visTimer:Timer,
			stateObj:Object,
			content_mc:Sprite,
			swipeStrategy:TimerVerticalSwipe,
			owner:ScrollPaneTest,
			urlReq:URLRequest,
			cellData:Vector.<CellData>,
			cells:Vector.<CellRender>,
			tmpCell:CellRender,
			loader:Loader,
			context:LoaderContext,
			topCell:CellRender, bottomCell:CellRender,
			idxBoundLower:int = 0, idxBoundUpper:int = idxBoundLower+numCells-1,
			idxBoundMin:uint = 0, idxBoundMax:uint,
			barSearch:SearchBar;
		
		public function VerticalSwipePane(_owner:ScrollPaneTest) {
			mouseEnabled = false;
			owner = _owner;
			
			visTimer = new Timer(timer_interval);
			context = new LoaderContext(true);
			
			stateObj = new Object();
			stateObj.x = this.x;
			stateObj.y = this.y;
			stateObj.alpha = this.alpha;
			stateObj.visible = this.visible;
			
			initList();
			resetList(owner.cellData,1);
			
			maxScroll = stageHeight-content_mc.height;
			cell_height = topCell.height; //init value
			swipeStrategy = new TimerVerticalSwipe(content_mc);
			
			addChild(content_mc);
			barSearch = new SearchBar();
			barSearch.x = 0;
			barSearch.y = 440;
			barSearch.mouseEnabled = false;
			addChild(barSearch);
		}
		
		private function startLoadImages():void{
			imgNum = 0; //reset every time
			urlReq = new URLRequest();			
			urlReq.url = serverURL+cellData[imgNum].imgURL;
			//trace("start load image:"+serverURL+cellData[imgNum].imgURL);
			loader = new Loader();
			context = new LoaderContext(true);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadStuff);
			loader.load(urlReq, context);
		}
		
		private function loadStuff(evt:Event):void{
			//trace(imgNum+"|t:"+cellData[imgNum].title+"|u:"+serverURL+cellData[imgNum].imgURL);
			//trace(loader.contentLoaderInfo.bytesLoaded+"/"+loader.contentLoaderInfo.bytesTotal);
			evt.stopPropagation();
			cellData[imgNum].cache = evt.target.loader.content.bitmapData;
			imgNum++;
			if(imgNum<=idxBoundMax){
				urlReq.url = serverURL+cellData[imgNum].imgURL;
				loader.load(urlReq,context);
			}
			else{
				loader.removeEventListener(Event.COMPLETE, loadStuff);
				loader = null;
				drawBMPDataToAllCell();
				//trace("done loading");
			}
		}
		
		private function drawBMPDataToAllCell():void{
			for(i=0; i<numCells; i++){
				if(i<idxBoundMax){
				var tmpCell:CellRender = cells[i];
				tmpCell.v_image = cellData[i].cache;
				}else{
					return;
				}
			}
		}
		private function ON_MOUSE_DOWN(evt:MouseEvent):void {
			evt.stopPropagation();
			swipeStrategy.swipe(0);
			mDown = true;
			oldClickY = oldMouseY = mouseY;
		}

		private function ON_MOUSE_UP(evt:MouseEvent):void {
			evt.stopPropagation();
			if(mDown){
				mDown = false;
				swipeStrategy.swipe(Math.ceil((mouseY - oldClickY)*scaling*MOUSE_UP_DEC_FACTOR));
				scaling = max_scaling;
			}
		}
		
		private function sendCellBottom(cell:CellRender):void{
			cell.y += upperMov;
			idxBoundLower++;
			idxBoundUpper++;
			cell.v_image = cellData[idxBoundUpper].cache;
			cell.v_title = cellData[idxBoundUpper].title;
			cell.v_desc = cellData[idxBoundUpper].desc;
			cell.v_rate = cellData[idxBoundUpper].rate;
			cell.v_path = cellData[idxBoundUpper].vidpath;
			bottomCell = cell;
		}
		private function sendCellTop(cell:CellRender):void{
			cell.y -= lowerMov;
			idxBoundLower--;
			idxBoundUpper--;
			cell.v_image = cellData[idxBoundLower].cache;
			cell.v_title = cellData[idxBoundLower].title;
			cell.v_desc = cellData[idxBoundLower].desc;
			cell.v_rate = cellData[idxBoundLower].rate;
			cell.v_path = cellData[idxBoundLower].vidpath;
			topCell = cell
		}
		public function disable():void{
			visTimer.stop();
			visTimer.removeEventListener(TimerEvent.TIMER, restrictDisplay);
			content_mc.removeEventListener(MouseEvent.CLICK, H_click);
			content_mc.removeEventListener(MouseEvent.MOUSE_DOWN, ON_MOUSE_DOWN);
			content_mc.removeEventListener(MouseEvent.MOUSE_UP, ON_MOUSE_UP);
			barSearch.btnSearch.removeEventListener(MouseEvent.CLICK, onSearchBarClick);
			barSearch.txtSearch.removeEventListener(FocusEvent.FOCUS_IN, onSearchTxtFocus);
			stateObj.x = x;
			stateObj.y = y;
			stateObj.alpha = alpha;
			stateObj.visible = visible;
		}
		
		public function enable():void{
			x = stateObj.x;
			y = stateObj.y;
			alpha = stateObj.alpha;
			visible = stateObj.visible;
			barSearch.txtSearch.addEventListener(FocusEvent.FOCUS_IN, onSearchTxtFocus);
			barSearch.btnSearch.addEventListener(MouseEvent.CLICK, onSearchBarClick);
			content_mc.addEventListener(MouseEvent.MOUSE_DOWN, ON_MOUSE_DOWN);
			content_mc.addEventListener(MouseEvent.MOUSE_UP, ON_MOUSE_UP);
			content_mc.addEventListener(MouseEvent.CLICK, H_click, true);
			visTimer.addEventListener(TimerEvent.TIMER, restrictDisplay);
			visTimer.start();
		}
		
		private function initList() {
			cells = new Vector.<CellRender>(numCells);
			content_mc = new Sprite();
			for (i=0; i< numCells; i++ ) {
				cells[i] = new CellRender();
				content_mc.addChildAt(cells[i], i );
			}
			with(content_mc){ x = y = z = 0;}
		}

		public function resetList(_cellData:Vector.<CellData>, vspace:uint):void{
			cellData = _cellData;
			idxBoundMax = cellData.length-1;
			trace("idxBoundMax:"+idxBoundMax);
			for(i=0; i< numCells; i++ ) {
				if(i<cellData.length){
					with(tmpCell = cells[i]){
						v_title = cellData[i].title;
						v_desc = cellData[i].desc;
						v_rate = cellData[i].rate;
						v_path = cellData[i].vidpath;
						v_index = cellData[i].index;
						y = i * (height + vspace ) + vspace;
						visible = true;
					}
				}
				else{
					with(tmpCell = cells[i]){
						v_title = "";
						v_desc = "";
						v_rate = "";
						v_path = "";
						v_index = i;
						y = i * (height + vspace ) + vspace;
						visible = false;
					}
				}
			}
			topCell = cells[0];
			bottomCell = cells[6];
			startLoadImages();
		}
		
		private function H_click(evt:MouseEvent):void{
			evt.stopPropagation();
			owner.transitPane(evt.target.parent.v_title, evt.target.parent.v_desc, evt.target.parent.v_path);
		}
		
		public function notifyComplete(obj:Object):void{
				var xml:XML = new XML(obj.result);
				var len:uint = xml.children().length();
				if(len>0){
					cellData = new Vector.<CellData>(len);
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
					barSearch.txtSearch.text = len+" results returned.";
					resetList(cellData,1);
				}
				else{
					barSearch.txtSearch.text = "No results returned.";
				}
			    enable();
		}
		public function notifyError(obj:Object):void{
			barSearch.txtSearch.text = obj.toString();
		}
		private function onSearchBarClick(evt:MouseEvent):void{
			evt.stopPropagation();
			disable();
			MBSWebService.getList(this, barSearch.txtSearch.text);
		}
		private function onSearchTxtFocus(evt:FocusEvent):void{
			evt.stopPropagation();
			barSearch.txtSearch.text = "";
		}
		// need to refactor...
		private function restrictDisplay(evt:Event):void{
			evt.stopPropagation();
			// for stick to touch
			var child_mc:CellRender;
			//trace("os:"+offsetY+" ibl:"+idxBoundLower+" ibu:"+idxBoundUpper+" ibm:"+idxBoundMin+" ibM:"+idxBoundMax);
			if(mDown){
				scaling = (scaling <= 0) ? 0 : scaling*MOUSE_DOWN_DEC_FACRTOR;
				if(mouseY != oldMouseY){
					offsetY = mouseY - oldMouseY;
					
					if(offsetY<0){ // go upward 
						if(idxBoundUpper==idxBoundMax){
							if(bottomCell.y > (stageHeight-bottomCell.height)){
								for(w=0; w<content_mc.numChildren; w++){
									child_mc = content_mc.getChildAt(w) as CellRender;
									child_mc.y += offsetY;
								}
							}
						}
						else if(idxBoundUpper<idxBoundMax) {
							for(w=0; w<content_mc.numChildren; w++){
								child_mc = content_mc.getChildAt(w) as CellRender;
								child_mc.y += offsetY;
						 		if(child_mc.y < -child_mc.height) {
									sendCellBottom(child_mc);
								}
							}
						}
					}
					else if(offsetY>0) {// go downward
						if(idxBoundLower==idxBoundMin){
							if(topCell.y < 0){
								for(w=0; w<content_mc.numChildren; w++){
									child_mc = content_mc.getChildAt(w) as CellRender;
									child_mc.y += offsetY;
								}
							}
						}
						else if(idxBoundLower>idxBoundMin){
							for(w=0; w<content_mc.numChildren; w++){
								child_mc = content_mc.getChildAt(w) as CellRender;
								child_mc.y += offsetY;
								if(child_mc.y > lowerBound) {
									sendCellTop(child_mc);	
								}
							}
						}
					}
					oldMouseY = mouseY;
					//trace(offsetY);
				}
			} else if(swipeStrategy.mode != 0) {
					if(swipeStrategy.mode == 1){
						if(idxBoundUpper<idxBoundMax) { // go upward
							for(w=0; w<content_mc.numChildren; w++) {
								child_mc = content_mc.getChildAt(w) as CellRender;
								if(child_mc.y < -child_mc.height) {
									sendCellBottom(child_mc);
								}
							}
						}
						else if(idxBoundUpper>=idxBoundMax){
							swipeStrategy.swipe(0);
						}
					}
					else if(swipeStrategy.mode == 2){
						if(idxBoundLower>idxBoundMin) {// go downward
							for(w=0; w<content_mc.numChildren; w++) {
								child_mc = content_mc.getChildAt(w) as CellRender;
								if(child_mc.y > lowerBound) {
									sendCellTop(child_mc);		
								}
							}
						}
						else if(idxBoundLower<=idxBoundMin){
							swipeStrategy.swipe(0);
						}
					}	
				}
				else if(idxBoundUpper==idxBoundMax){
					if(bottomCell.y < (stageHeight-bottomCell.height)){
						var displacement:Number = (stageHeight-bottomCell.height) - bottomCell.y;
						for(w=0; w<content_mc.numChildren; w++){
							child_mc = content_mc.getChildAt(w) as CellRender;
							child_mc.y += displacement;
						}
					}
				}
				else if(idxBoundLower==idxBoundMin){
					//trace(topCell.y);
					if(topCell.y > 0){
						var displacement2:int = topCell.y;
						for(w=0; w<content_mc.numChildren; w++){
							child_mc = content_mc.getChildAt(w) as CellRender;
							child_mc.y -= displacement2;
						}
					}
				}
		}
	}
	
}
