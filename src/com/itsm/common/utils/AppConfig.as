package com.itsm.common.utils
{
	
	/**
	 * 平台参数类</p>
	 * 
	 * 功能：config.xml配置文件的内容。通过对象configs属性访问。</br>
	 * 复用性很高的、要提前加载的参数放此类中；
	 * 
	 * */
	public class AppConfig
	{
		
		private var _configs:Object;
		
		public function AppConfig(aValue:XML):void{
			_configs = new Object();
			
			var childLen:int = aValue.children().length();
			if (childLen > 0) {
				for(var i:int = 0; i<childLen; i++)
				{
					_configs[QName(aValue.children()[i].name()).localName] = aValue.children()[i].toString();
				}
			}
		}   

		public function get configs():Object
		{
			return _configs;
		}

	}
}