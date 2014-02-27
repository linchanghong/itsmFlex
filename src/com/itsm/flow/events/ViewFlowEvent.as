package com.itsm.flow.events
{
	import com.vo.FlowNodeInstence;
	
	import flash.events.Event;
	
	public class ViewFlowEvent extends Event
	{
		public static const EVENT_VIEWFLOW:String = "Event_ViewFlow";
		
		public var flowNodeInstence:Object;
		
		public function ViewFlowEvent(flowNodeInstence:Object,type:String=EVENT_VIEWFLOW, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.flowNodeInstence = flowNodeInstence;
			super(type, bubbles, cancelable);
		}
	}
}