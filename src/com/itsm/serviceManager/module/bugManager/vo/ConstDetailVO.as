package com.itsm.serviceManager.module.bugManager.vo
{
	[Bindable]
	[RemoteClass(alias="com.sccl.framework.entity.ConstDetail")]
	public class ConstDetailVO
	{
		public function ConstDetailVO()
		{
		}
		
		public var id:int;
		
		public var constDetailCode:String;
		
		public var constDetailName:String;
		
		public var enabled:String;
		
		public var remark:String;
		
		public var constType:ConstTypeVO;
		
	}
}