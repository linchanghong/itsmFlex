package com.itsm.common.event
{
	public class EventArgExtend
	{
		public function EventArgExtend()
		{
		}
		
		public static function create(f:Function,... arg):Function
		{
			var F:Boolean=false;
			var _f:Function=function(e:*,..._arg):*
			{
				_arg=arg
				if(!F)
				{
					F=true
					_arg.unshift(e)
				}
				f.apply(null,_arg)
			};
			return _f;
		}
		
		public static function toString():String
		{
			return "Class JEventDelegate";
		}
	}
}