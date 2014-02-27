package com.itsm.serviceManager.module.bugManager.vo
{
	import flashx.textLayout.formats.Float;

	[RemoteClass(alias="com.sccl.serviceManager.bugManager.dto.AttachmentsDTO")]
	[Bindable]
	public class AttachmentsVO
	{
		public function AttachmentsVO()
		{
		}
		
		public var attachmentId:String;
		
		public var userApplyIDStr:String;
		
		public var apply:UserApplyVO;
		
		public var fileName:String;
		
		public var fileType:String;
		
		public var uploaderID:String;
		
		public var directions:String;
		
		public var uploadDate:Date;
		
		public var fileURL:String;
		
		public var fileSize:String;
		
		public var attachmentType:String;
		
		public var DR:String;
		
		public var uploaderName:String;
		
		public var fileTypeName:String;
	}
}