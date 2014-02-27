package com.itsm.serviceManager.module.bugManager.vo.backup
{
	[Bindable]
	[RemoteClass(alias="com.sccl.serviceManager.bugManager.dto.InitBugDto")]
	public class InitBugVo
	{
		//bug编号
		private var bugID:String;
		//所属系统
		private var systemName:String;
		//主题摘要
		private var item:String;
		//重要程度
		private var importance:String;
		//影响范围
		private var influence:String;
		//报告人
		private var speaker:String;
		//bug报告时间
		private var bugPutTime:Date;
		//期望解决时间
		private var hopeTime:Date;
		//责任人
		private var responsible:String;
		//状态
		private var state:String;
		
		
		public function InitBugVo()
		{
		}
	}
}