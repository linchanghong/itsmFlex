package com.itsm.serviceManager.module.bugManager.vo
{

	[Bindable]
	[RemoteClass(alias="com.sccl.serviceManager.bugManager.dto.UserApplyDTO")]
	public class UserApplyVO extends Object
	{
		public function UserApplyVO()
		{
		}
	
		 //主键
		public var applyId:Number;
		 //用户请求单编号
		public var userApplyCode:String;
		 //请求类型1- 问题 2-bug 3-需求
		public var applyType:int;
		 //请求单的填写者，可以是用户，也可以是支撑人员
		public var applyEntry:Object;
		 //提出请求的具体用户
		public var sponsor:Object;
		//请求发起人对应的公司
		public var company:String;
		 //请求发起人对应的部门
		public var department:String;
		 //请求发起人的联系电话
		public var telephone:String;
		//请求发起时间
		public var applyStartDate:String;
		 //期望解决时间
		public var applyEndDate:String;
		 //请求来源，用户登录系统录入，用户通过QQ电话等提交
		public var applyOrigin:ConstDetailVO;
		 //请求的紧急程度
		public var urgent:ReplyLevelVO;
		 //问题可能影响的范围
		public var range:ConstDetailVO;
		 //请求对应的业务系统
		public var belongSystem:SupportSystemVO;
		 //请求所对应的业务模块
		public var sysModule:SystemModuleVO;
		 //响应时间
		public var replyTime:String;
		//受理人
		public var replyer:Object;
		//计划解决时间
		public var planFinishTime:String;
		//实际解决时间
		public var realFinishTime:String;
		//请求主题摘要
		public var applyTitle:String;
		//请求描述
		public var directions:String;
		//问题的实际影响范围
		public var realRange:ConstDetailVO;
		//原因分析
		public var reason:String;
		//处理方法
		public var solutions:String;
		//需求提出理由
		public var applyReason:String;
		//请求单状态
		public var applyStatus:uint;
		//请求单状态名称
		public var applyStatusStr:String;
		//是否删除：0-未删除；1-已删除
		public var DR:String;
		
//		public var applyEntryName:String;
//		
//		public var replyerName:String;
//		
//		public var sponsorName:String;
		
		public var attachments:Array;


	}
}