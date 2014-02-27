package com.itsm.serviceManager.module.bugManager.vo
{
	public class SearchInfoVO
	{
		/**
		 * 请求单编号
		 */
		public var code:String;
		/**
		 * 所属系统
		 */
		public var system:int;
		/**
		 * 主题摘要
		 */
		public var theme:String;
		/**
		 * 重要程度
		 */
		public var degree:int;
		/**
		 * 影响范围
		 */
		public var range:int;
		/**
		 * 报告人
		 */
		public var sponsor:String;
		/**
		 * 状态
		 */
		public var status:int;
		/**
		 * 当前登录用户id
		 */
		public var userID:int = -1;
		/**
		 * 种类
		 */
		public var flag:int = 2;	
		/**其他*/
		public var other:String;
		
		public function SearchInfoVO()
		{
		}
	}
}