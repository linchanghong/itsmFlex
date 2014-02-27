package com.itsm.serviceManager.module.bugManager.vo
{
	[Bindable]
	[RemoteClass(alias="com.sccl.serviceManager.bugManager.entity.SystemModule")]
	public class SystemModuleVO
	{
		public function SystemModuleVO()
		{
		}
		public var moduleID:String;
		
		public var constDetailCode:String;
		
		public var constDetailName:String;
		
		public var enabled:String;
		
		public var remark:String;
		
		public var constType:ConstTypeVO;
	}
}