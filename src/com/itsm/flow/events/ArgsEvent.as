package com.itsm.flow.events
{
	import flash.events.Event;
	
	public class ArgsEvent extends Event
	{
		public var args:Object;
		
		public function ArgsEvent(args:Object,type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.args = args;
		}
	}
}