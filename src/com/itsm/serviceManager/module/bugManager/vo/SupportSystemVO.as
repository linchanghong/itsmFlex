package com.itsm.serviceManager.module.bugManager.vo
{
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="com.sccl.serviceManager.bugManager.dto.SupportSystemDTO")]
	public class SupportSystemVO
	{
		public function SupportSystemVO()
		{
		}
		
		public var systemID:int;
		
		public var systemName:String;
		
		public var systemCode:String;
		
		public var onlineDate:Date;
		
		public var remark:String;
		
		public var DR:String;
		
		public var modules:ArrayCollection;
	}
}