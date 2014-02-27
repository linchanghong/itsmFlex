package com.itsm.flow.events
{
	import flash.events.Event;
	
	public class ReloadFlowtodoEvent extends Event
	{
		public static const EVENT_RELOADFLOWTODO:String = "Event_ReloadFlowtodo";
		
		public var displayObj:*;
		public var isCloseWin:Boolean;
		
		public function ReloadFlowtodoEvent(displayObj:*,isCloseWin:Boolean=true,type:String=EVENT_RELOADFLOWTODO)
		{
			super(type);
			this.displayObj=displayObj;
			this.isCloseWin = isCloseWin;
		}
	}
}