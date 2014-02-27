package com.itsm.flow.events
{
	import flash.events.Event;
	
	public class ApplicationModuleEvent extends Event
	{
		public static const ApplicationModuleEvent:String = "ApplicationModuleEvent";
		
		public var module:int=0;
		
		public function ApplicationModuleEvent(module:int, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(ApplicationModuleEvent, bubbles, cancelable);
			this.module = module;
			
		}
	}
	
	
}