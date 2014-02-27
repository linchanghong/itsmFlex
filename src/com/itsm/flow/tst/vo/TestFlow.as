package com.itsm.flow.tst.vo
{
	[RemoteClass(alias="com.itsm.domain.flow.TestFlow")]
	public class TestFlow
	{
		private var _id:String;
		private var _name:String;
		private var _wage:String;
		private var _remark:String;
		private var _sendId:String;
		
		public function TestFlow()
		{
		}

		public function get remark():String
		{
			return _remark;
		}

		public function set remark(value:String):void
		{
			_remark = value;
		}

		public function get wage():String
		{
			return _wage;
		}

		public function set wage(value:String):void
		{
			_wage = value;
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

		public function get id():String
		{
			return _id;
		}

		public function set id(value:String):void
		{
			_id = value;
		}

		public function get sendId():String
		{
			return _sendId;
		}

		public function set sendId(value:String):void
		{
			_sendId = value;
		}


	}
}