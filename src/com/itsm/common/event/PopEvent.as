package com.itsm.common.event
{
	import flash.events.Event;

	public class PopEvent extends Event
	{
		public static const EVENT_NAME:String = "EventName";  //事件名字
		
		public var data:Object = null;  //传递数据
		
		public function PopEvent(type:String, data:Object, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);  
			this.data = data;
		}
	}
}