package com.itsm.common.utils
{
	import com.framelib.utils.UserBehave;
	
	import common.utils.TAlert;
	
	import mx.core.FlexGlobals;
	import mx.messaging.ChannelSet;
	import mx.messaging.channels.AMFChannel;
	import mx.rpc.AbstractOperation;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	
	/**
	 * 远程数据处理类，调用后台方法
	 * */
	public class DataDeal
	{
		//业务方法用
		public var remoteMethods:AbstractOperation;       //得到数据源的方法
		private var remoteObject:RemoteObject;            //远程对象
		private var asyncT:AsyncToken;
		
		//验证登录方法用
		private var remoteMethods_:AbstractOperation;       //得到数据源的方法
		private var remoteObject_:RemoteObject;            //远程对象
		private var asyncT_:AsyncToken;
		
		private var remoteDest:String;
		private var remoteSource:String;
		private var remoteOperation:String;
		private var arguments:Object;
		private var showWait:Boolean;
		
		public function DataDeal()
		{
		}
		
		/**
		 * 
		 * 远程调用获取数据，并验证登录是否有效
		 * @param RemoteDest: 远程数据源，要调用的后台bean名
		 * @param RemoteSource: 远程命名空间及类，要调用的后台service类名
		 * @param RemoteOperation: 要调用的后台方法名
		 * @param Agt: 后台方法需要的参数，一个对象数组，如[1,2,"A","B"]
		 * */
		public function dataRemote(remoteDest:String, remoteSource:String, 
											remoteOperation:String, agt:Object, 
											showWait:Boolean=true):void
		{
			//访问业务方法
			remoteObject = new RemoteObject();
			remoteObject.endpoint = AppCore.getInstance().appConfig.configs.fWebChannelSet;
			remoteObject.source = remoteSource;
			remoteObject.destination = remoteDest;
			remoteObject.showBusyCursor = showWait;
			remoteMethods = remoteObject.getOperation(remoteOperation);
			remoteMethods.addEventListener(FaultEvent.FAULT,getErrorHandle);
			remoteMethods.arguments = agt;
			
//			if(AppCore.getInstance().loginUser.userCode != null) {
//				trace(AppCore.getInstance().loginUser.userCode);
//				//先验证是否登录
//				remoteObject_ = new RemoteObject();
//				remoteObject_.endpoint = AppCore.getInstance().appConfig.configs.fWebChannelSet;
//				remoteObject_.source = AppCore.getInstance().appConfig.configs.remoteSource;
//				remoteObject_.destination = AppCore.getInstance().appConfig.configs.remoteDest;
//				
//				remoteObject_.showBusyCursor = showWait;
//				
//				remoteMethods_ = remoteObject.getOperation(AppCore.getInstance().appConfig.configs.remoteOperation);
//				remoteMethods_.addEventListener(FaultEvent.FAULT,getErrorHandle);
//				remoteMethods_.addEventListener(ResultEvent.RESULT,isLoginHandler);
//				remoteMethods_.arguments = [AppCore.getInstance().loginUser.userCode, UserBehave.getBehave(), agt.toString()];
//				
//				asyncT_ = remoteMethods_.send();
//			} else {
				//不验证登录
				asyncT = remoteMethods.send();
//			}
		}
		
		private function isLoginHandler(event:ResultEvent):void
		{
			var msUser:Object = event.result as Object;
			if(msUser == null) {
				TAlert.show("您的帐号需要重新登录", "提示");
			} else {
				
				if(AppCore.getInstance().getSetDetail(1).getItemAt(0).setValue == "1") {
					if(msUser.loginUid != AppCore.getInstance().loginUser.loginUid) {
						TAlert.show("您的帐号已在其它地方登录，你需要注销后重新登录。", "提示");
					} else {
						asyncT = remoteMethods.send();
					}
				} else {
					if(msUser.isSingleLogin == 1 && msUser.loginUid != AppCore.getInstance().loginUser.loginUid) {
						TAlert.show("您的帐号已在其它地方登录，你需要注销后重新登录。", "提示");
					} else {
						asyncT = remoteMethods.send();
					}
				}
			}
		}
		
		/**
		 * 调用的方法发生错误
		 * */
		private function getErrorHandle(event:FaultEvent):void
		{
			TAlert.show("对不起，本次操作失败。请重试或联系系统管理员。","服务器提示");
			trace("服务器报错"+event.fault.faultString +
				" ，错误详情： " + event.fault.faultDetail 
				+ " ，错误信息：" + event.fault.message + " ，错误原因：" + 
				event.fault.rootCause);
		}
	}
}