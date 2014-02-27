package com.itsm.serviceManager.module.bugManager.vo.backup
{
	[Bindable]
	[RemoteClass(alias="com.sccl.serviceManager.bugManager.dto.BugShowDocDto")]
	public class BugShowDocVo
	{
		//文件名称
		private var fileName:String;
		//文件类型
		private var fileType:String;
		//上传者
		private var loader:String;
		//上传日期
		private var loadTime:String;
		//文件说明
		private var fileDescription:String;
	
		
		public function BugShowDocVo()
		{
		}
	}
}