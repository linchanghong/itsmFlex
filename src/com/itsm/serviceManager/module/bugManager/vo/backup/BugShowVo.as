package com.itsm.serviceManager.module.bugManager.vo.backup
{
	[Bindable]
	[RemoteClass(alias="com.sccl.serviceManager.bugManager.dto.BugShowDto")]
	public class BugShowVo
	{
		
		//报告人
		private var speaker:String;
		//联系电话
		private var phoneNumber:String;
		//bug来源
		private var bugSource:String;
		//所属系统
		private var systemName:String;
		//责任人
		private var responsible:String;
		//主题摘要
		private var item:String;
		//所属单位
		private var unitName:String;
		//报告时间
		private var putTime:Date;
		//重要程度
		private var importance:String;
		//所属业务
		private var business:String;
		//计划解决时间
		private var planTime:Date;
		//所属部门
		private var department:String;
		//期望解决时间
		private var hopeTime:Date;
		//影响范围
		private var influence:String;
		//bug受理时间
		private var bugAcceptedTime:String;
		//完成时间
		private var achieveTime:Date;
		//bug描述
		private var bugDescription:String;
		//bug时间影响范围
		private var realAffect:String;
		//bug原因分析
		private var bugCauseAnalysis:String;
		//bug解决方案
		private var bugHandle:String;
		
		
		public function BugShowVo()
		{
		}
	}
}