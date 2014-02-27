package com.itsm.serviceManager.module.bugManager.vo
{
	[Bindable]
	[RemoteClass(alias="com.sccl.serviceManager.bugManager.dto.MsUserDTO")]
	public class MsUserVO
	{
		public function MsUserVO()
		{
		}
		
		public var oid:String;
		
		public var nameString:String;
	}
}