package com.grandtech {
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public final class TimerTransition {
		
		private static var 
			self:TimerTransition;
			
		private var 
			steps:uint,
			duration:uint,
			timer:Timer,
			strategy:ITransitionStrategy,
			callback:Function;
		
		public static function transit(_function:Function,_duration:uint,_steps:uint,_strategy:ITransitionStrategy):void{
			getInstance();
			with(self){
				steps = _steps;
				duration = _duration;
				strategy = _strategy;
				callback = _function;
				timer.delay = duration/steps;
				timer.repeatCount = steps;
				start();
			}
		}
		
		public static function getInstance():TimerTransition{
			if(self == null){
				self = new TimerTransition(new SingletonEnforcer());
			}
			return self;
		}
		
		public function TimerTransition(foo:SingletonEnforcer) {
			timer = new Timer(0);
		}
		
		private function start():void{
			timer.addEventListener(TimerEvent.TIMER, onTimerTick);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			timer.start();
		}
		
		private function onTimerTick(evt:TimerEvent):void{
			evt.stopPropagation();
			strategy.transit(); 
		}
		
		private function reset():void{
			timer.reset();
			timer.removeEventListener(TimerEvent.TIMER, onTimerTick);
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			if(callback != null){
				callback();
			}
		}
		
		private function onTimerComplete(evt:TimerEvent):void{
			evt.stopPropagation();
			reset();
		}
	}
}
internal class SingletonEnforcer {}