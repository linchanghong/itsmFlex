package com.itsm.serviceManager.module.bugManager.vo
{
	[Bindable]
	[RemoteClass(alias="com.sccl.serviceManager.bugManager.entity.ReplyLevel")]
	public class ReplyLevelVO
	{
		public function ReplyLevelVO()
		{
		}
		
		public var replyLevelId:int;
		
		public var levelNameString:String;
		
		public var replyTimes:String;
		
		public var DR:String;
	}
}