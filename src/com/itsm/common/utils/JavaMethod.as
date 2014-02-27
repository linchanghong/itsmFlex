package com.itsm.common.utils
{
	/**
	 * 指定后台java方法的类
	 * 
	 * 
	 * */
	public class JavaMethod
	{
		/**spring bean名*/
		private var _bean:String;
		/**方法名*/
		private var _method:String;
		/**方法参数*/
		private var _parameters:Array;
		
		public function JavaMethod()
		{
		}

		public function get parameters():Array
		{
			return _parameters;
		}

		public function set parameters(value:Array):void
		{
			_parameters = value;
		}

		public function get method():String
		{
			return _method;
		}

		public function set method(value:String):void
		{
			_method = value;
		}

		public function get bean():String
		{
			return _bean;
		}

		public function set bean(value:String):void
		{
			_bean = value;
		}

	}
}