package com
{
	import flash.events.Event;
	
	public class TestEvent extends Event
	{
		
		public static const SURE:String = "sure";
		
		public function TestEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public var isSelect:Boolean;
		public var o:Object;
		public function DataGridEvent(_o:Object,_isSelect:Boolean):void{
			o = _o;
			isSelect = _isSelect;
			super("selectRow");
		}

	}
}