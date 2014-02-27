package com.itsm.flow.events
{
	import flash.events.Event;
	
	public class PreWarningdatagridEvent extends Event
	{
		
		public static const OPENPREWARINGWINDOW:String = "event_"+"openPreWaringWindow";
		
		public var item:Object;
		
		public function PreWarningdatagridEvent(prewarningData:Object,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(OPENPREWARINGWINDOW, bubbles, cancelable);
			item = prewarningData;
		}
	}
}