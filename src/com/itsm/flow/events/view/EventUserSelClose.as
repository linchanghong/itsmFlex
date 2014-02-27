package com.itsm.flow.events.view
{
	import flash.events.Event;

	public class EventUserSelClose extends Event
	{
		public static const USERSELCLOSE:String = "UserSelClickOK";
		
		public function EventUserSelClose()
		{
			super(USERSELCLOSE, false, false);
		}
	}

}