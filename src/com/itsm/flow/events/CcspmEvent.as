package com.itsm.flow.events
{
	import flash.events.Event;

	public class CcspmEvent extends Event
	{
		
		public var obj:Object;
		//初始化信息加载完成事件
		public static const	INFO_COMPLETE:String = "infoComplete";
		public static const DW_CLICK_EVENT:String="dwClickEvent";
		public static const DW_DEALCOMPLETE_EVENT:String = "dwDealcompleteEvent";
		public static const SHOWPROJECTINFO:String = "show_project_info";
		public function CcspmEvent(type:String, _obj:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.obj=_obj;
			super(type, bubbles, cancelable);
		}
	}
}