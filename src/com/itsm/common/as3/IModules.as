package com.itsm.common.as3
{
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	public interface IModules extends IEventDispatcher
	{
		function setWindowObj(obj:Object):void; 
	}
}