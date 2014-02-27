package com.itsm.common.vo
{
	import mx.collections.ArrayCollection;

	public class OrgTreeVO
	{
		public var id:int;
		public var orgName:String;
		public var orgCode:String;
		public var orgType:int;
		public var parentId:int;
		public var parentPath:String;
		public var companyId:String;
		public var remark:String;
		public var children:ArrayCollection;
		
		public function OrgTreeVO()
		{
		}
	}
}