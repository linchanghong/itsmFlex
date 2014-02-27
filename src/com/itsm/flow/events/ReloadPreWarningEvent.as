package com.itsm.flow.events
{
	import flash.events.Event;
	
	import rich.controls.flow.classes.unils.BodyState;
	
	public class ReloadPreWarningEvent extends Event
	{
		public static const EVENT_RELOADPREWARNING:String = "Event_ReloadPreWarning";
		
		public var displayObj:*;
		public var isCloseWin:Boolean;
		public var isReload:Boolean=false;
		
		public function ReloadPreWarningEvent(displayObj:*,isCloseWin:Boolean=true,isReload:Boolean=true,type:String=EVENT_RELOADPREWARNING)
		{
			super(type);
			this.displayObj=displayObj;
			this.isCloseWin = isCloseWin;
			this.isReload = isReload;
		}
	}
}