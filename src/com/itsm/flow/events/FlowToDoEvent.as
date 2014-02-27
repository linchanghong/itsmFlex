package com.itsm.flow.events
{
	import com.vo.FlowNodeInstence;
	
	import flash.events.Event;
	
	public class FlowToDoEvent extends Event
	{
		
		public static const FLOWTODO_ARGEE_EVENT:String = "flowtodo_argee_event";
		public static const FLOWTODO_REFUSE_EVENT:String = "flowtodo_refuse_event";
		
		public var flowNodeInstence:FlowNodeInstence;
		//-1 开始  -2 结束    0 中间节点
		public var nodeNumber:int;
		
		public function FlowToDoEvent(type:String,flowNodeInstence:FlowNodeInstence,nodeNumber:int)
		{
			super(type, bubbles, cancelable);
			this.flowNodeInstence = flowNodeInstence;
			this.nodeNumber = nodeNumber;
		}
	}
}