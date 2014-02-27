package com.itsm.serviceManager.module.bugManager.vo
{
	[Bindable]
	[RemoteClass(alias="com.sccl.framework.entity.ConstType")]
	public class ConstTypeVO
	{
		public function ConstTypeVO()
		{
		}
		
		public var id:String;
		
		public var constTypeCode:String;
		
		public var constTypeName:String;
		
		public var remark:String;
	}
}