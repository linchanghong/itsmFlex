package com.itsm.flow.events
{
	import com.vo.FlowNodeInstence;
	
	import flash.events.Event;
	
	public class FlowAdvancedatagridEvent extends Event
	{
		public static const OPENFLOWTODOWINDOW:String = "event_"+"openFlowTodoWindow";
		
		public  var flowNodeinstence:Object; 
		
		public function FlowAdvancedatagridEvent(flowNodeinstence:Object,type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.flowNodeinstence = flowNodeinstence;
		}
	}
}