package com.itsm.common.utils
{
	import com.adobe.serializers.json.JSONDecoder;
	import com.adobe.serializers.json.JSONEncoder;
	import com.framelib.utils.HashMap;
	import com.framelib.utils.Map;
	import com.framelib.utils.UserBehave;
	
	import common.utils.TAlert;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.StringUtil;
	
	/**
	 * 平台核心类</p>
	 * 
	 * 功能：</br>
	 * 1. 前台配置文件：appConfig，用法如：appCore.appConfig.configs.forumUrl；</br>
	 * 2. 后台交互类：dataDeal，</br>
	 * 3. 登录用户信息： loginUser,</br>
	 * 4. 后台常量：sConsts，用getConsts()方法直接读取</br>
	 * 5. 发送系统提示信息： 用sendSysInfo(aSysInfo:String, isTimer:Boolean=true)方法</br>
	 * 
	 * */
	public class AppCore
	{
		
		private static var appCore:AppCore;
		
		public var jsonDecoder:JSONDecoder;
		public var jsonEncoder:JSONEncoder;
		
		/**
		 * 前台配置文件
		 */
		public var appConfig:AppConfig;		
		/**
		 * 后台交互类
		 */
		public var dataDeal:DataDeal;
		/**
		 * 登录用户信息
		 */
		[Bindable]
		public var loginUser:Object; 
		/**
		 * 后台常量
		 */
		public var sConsts:XMLList;
		
		[Bindable]
		public var constTreeArr:ArrayCollection;
		[Bindable]
		public var setTreeArr:ArrayCollection;
		/**
		 * 用户的登录时间，从后台返回的
		 */
		public var loginDate:String;
		
		/**
		 * 菜单数据
		 */
		[Bindable]
		public var menuData:ArrayCollection = new ArrayCollection();
		
		/**
		 * 组织机构数据
		 */
		[Bindable]
		public var orgData:ArrayCollection = new ArrayCollection();
		
		/**
		 * 用户有权限的模块按钮
		 */
		[Bindable]
		public var userModuleButton:ArrayCollection = new ArrayCollection();
		
		/**
		 * 用户有权限的菜单上按钮
		 */
		[Bindable]
		public var userMenuUpButton:ArrayCollection = new ArrayCollection();
		
		/**
		 * 
		 */
		[Bindable]
		public var projectPlan:ArrayCollection = new ArrayCollection();
		
		/**
		 * 登录用户的角色数据
		 */
		[Bindable]
		public var roleData:ArrayCollection = new ArrayCollection();
		
		/**
		 * 登录用户可管理的org
		 */
		[Bindable]
		public var manageOrgData:ArrayCollection = new ArrayCollection();
		
		/**
		* 所有角色数据
		*/
		public var allRoleData:Map = new HashMap();
		
		/**
		 * 树结构的菜单数组
		 */
		[Bindable]
		public var menuDataTree:ArrayCollection = new ArrayCollection();
		
		public function AppCore()
		{
			if(appCore != null) { 
				throw new Error("单例，不能new! 请使用静态getInstance()方法。"); 
			} 
			
			jsonEncoder = new JSONEncoder();
			jsonDecoder = new JSONDecoder();
				
			//添加AppConfig 实例
			var mURLLoader:URLLoader = new URLLoader(new URLRequest("config.xml"));
			mURLLoader.addEventListener(Event.COMPLETE, 
				function(event:Event):void
				{
					appConfig = new AppConfig(XML(mURLLoader.data));
				}
			);	
			
			//添加其它实例
			loginUser = new Object();
			dataDeal =  new DataDeal();
		}
		
		public static function getInstance():AppCore {
			if(!appCore) { 
				appCore = new AppCore(); 
			} 
			return appCore; 
		}
		
		/**
		 * 重置所有存放在appCore里的数据，注销登录时调用 
		 * */
		public function reSet():void
		{
			loginUser.userCode = null;
			roleData.removeAll();
			userMenuUpButton.removeAll();
			userModuleButton.removeAll();
			orgData.removeAll();
			manageOrgData.removeAll();
			menuData.removeAll();
			projectPlan.removeAll();
		}
		
		/**
		 * 常量数据读取  
		 */
		public function readConstSetData():void{
			dataDeal.dataRemote("frameAPI","FrameAPI","findAllConstSetTree",[],false);
			dataDeal.remoteMethods.addEventListener(ResultEvent.RESULT,onReadConstSetDataResult);		
		}	
		
		//读取常量数据处理函数
		private function onReadConstSetDataResult(aEvent:ResultEvent):void{
			if (aEvent.result!=null) {				
				var obj:Object = jsonDecoder.decode(aEvent.result as String);
				
				constTreeArr = jsonDecoder.decode(obj.constTree as String) as ArrayCollection;
				setTreeArr =  jsonDecoder.decode(obj.setTree as String) as ArrayCollection;
			} else {
				trace("装载常量数据失败："+aEvent.result.ReturnInfo,"错误");	
			}
		}
		
		/**
		 *  根据常量类型id读取系统常量明细
		 * @param typeId 常量类型id
		 * @return 系统常量明细
		 */
		public function getConstDetail(typeId:int):ArrayCollection
		{
			var detailArr:ArrayCollection = new ArrayCollection();
			for each(var constType : Object in constTreeArr) {
				if(constType.id == typeId) {
					detailArr = constType.children;
				}
			}
			return detailArr;
		}
		
		/**
		 *  根据参数类型id读取系统参数
		 * @param typeId 参数类型id
		 * @return 系统参数
		 */
		public function getSetDetail(typeId:int):ArrayCollection
		{
			var detailArr:ArrayCollection = new ArrayCollection();
			for each(var setType : Object in setTreeArr) {
				if(setType.id == typeId) {
					detailArr = setType.children;
				}
			}
			return detailArr;
		}
		
		/**
		 * 调用数据处理函数，并指定操作类型和结果处理函数
		 * @param beanName:String 后台spring bean名字，比如usersFlex
		 * @param clazzName:String 要操作的类名，比如UsersFlex
		 * @param methodName:String 要访问的方法，比如add
		 * @param argObj:Object 要访问的方法的参数对象，比如add
		 * @param resultHandler:Function 操作完成后的处理函数，默认为null
		 * @param showWait:Boolean 是否显示忙指针
		 * @see com.itsm.common.utils.DataDeal
		 * */
		public function dealData(beanName:String, clazzName:String, methodName:String, argObj:Object, resultHandler:Function=null,showWait:Boolean=true):void 
		{
			dataDeal.dataRemote(beanName, clazzName, methodName, argObj, showWait);
			dataDeal.remoteMethods.addEventListener(ResultEvent.RESULT,resultHandler);
		}
		
		
		/**
		 * 发送系统提示信息
		 * @param aSysInfo 信息内容
		 * @param isTimer 是否启用过时清除，默认清除；
		 * 
		 */
		public function sendSysInfo(aSysInfo:String, isTimer:Boolean=true):void //发送系统消息到系统消息台显示      
		{
			FlexGlobals.topLevelApplication.lblSysInfo.text = aSysInfo;
			//系统信息 的提示，设置一个时间自动消失。以免老的提示误导新的操作。
			if(isTimer){
				var newTimer:Timer = new Timer(2000,5);  
				newTimer.addEventListener(TimerEvent.TIMER_COMPLETE,timerHandler);
				newTimer.start();
			}
		}
		
		private function timerHandler(event:TimerEvent):void
		{
			FlexGlobals.topLevelApplication.lblSysInfo.text = "";
		}
		
		//显示数据等待窗口
		public function showLoading(aParent:DisplayObject=null):void{   
			/*if(!isShowLoading){
				return;
			}
			if(aParent==null) aParent=DisplayObject(FlexGlobals.topLevelApplication);
			if (fDataLoading ==null) //aLoading=new DataLoading();		
				fDataLoading=DataLoading(PopUpManager.createPopUp(aParent,DataLoading , true));		  		  
			fDataLoading.addEventListener(CloseEvent.CLOSE,closeLoading);
			PopUpManager.centerPopUp(fDataLoading);*/
			
		}
		
		//关闭数据等待窗口
		public function closeLoading(aEvent:CloseEvent=null):void{ 
			/*if (fDataLoading!=null){
				setTimeout(
					function():void{	   
						PopUpManager.removePopUp(fDataLoading);
						fDataLoading=null;
					},500,null); 
			};*/
		}	
		
		/*******
		 * <p>后台使用Excel模板导出数据</p>
		 * 
		 * <p>服务器提供要导出Excel的模板，模板除了表头表尾，必须留一行示例数据，程序会按它的格式来导出。</p>
		 * 
		 * @param dataArr 数据：数据集 ；
		 * @param headerArr 列字对：要导出的列名和相应字段名，按导出顺序，列名必须和服务器模板名字一样；
		 * <pre>比如 凭证导出：
		 * headerArr = new Array(
		 * 	["摘要","theRemark"],
		 * 	["会计科目","bursary"],
		 * 	["明细科目","detailCourseId"],
		 * 	["借方本币","debitLocalCurrency"],
		 * 	["贷方本币","londersLocalCurrency"]);</pre>
		 * @param templateFileName 模板文件名：模板都在/exceltemplates目录下，所以只需提供文件名即可，不包括后缀名，如“凭证生成”。
		 * @author wbgen
		 *******/
		public function exportByData(dataArr:ArrayCollection, headerArr:Array, templateName:String):void
		{
			dataDeal.dataRemote("frameAPI","FrameAPI","exportByData",[dataArr, headerArr, templateName]);
			dataDeal.remoteMethods.addEventListener(ResultEvent.RESULT, exportHandler);
		}
		
		/*******
		 * <p>后台使用Excel模板导出数据</p>
		 * 
		 * <p>服务器提供要导出Excel的模板，模板除了表头表尾，必须留一行示例数据，程序会按它的格式来导出。</p>
		 * 
		 * @param javaMethod 对应后台的方法及方法的参数，用 JavaMethod类封装，不支持重载，后台方法应该返回json串；
		 * @param headerArr 列字对：要导出的列名和相应字段名，按导出顺序，列名必须和服务器模板名字一样；
		 * <pre>比如 凭证导出：
		 * headerArr = new Array(
		 * 	["摘要","theRemark"],
		 * 	["会计科目","bursary"],
		 * 	["明细科目","detailCourseId"],
		 * 	["借方本币","debitLocalCurrency"],
		 * 	["贷方本币","londersLocalCurrency"]);</pre>
		 * @param templateFileName 模板文件名：模板都在/exceltemplates目录下，所以只需提供文件名即可，不包括后缀名，如“凭证生成”。
		 * @author wbgen
		 *******/
		public function exportByMethod(javaMethod:JavaMethod, headerArr:Array, templateName:String):void
		{
			dataDeal.dataRemote("frameAPI","FrameAPI","exportByMethod",[jsonEncoder.encode(javaMethod), headerArr, templateName]);
			dataDeal.remoteMethods.addEventListener(ResultEvent.RESULT, exportHandler);
		}
		
		private function exportHandler(event:ResultEvent):void
		{
			var str:String = event.result as String;
			if(str.substr(0,5) != "path:") {
				TAlert.show(str,"提示");
			} else {
				exportExcel(str.substr(5));
			}
		}
		
		public  function exportExcel(str:String):void
		{
			closeLoading();
			
			var fileNameArr:Array = StringUtil.trim((str)).split('/');
			var fileName:String = fileNameArr[fileNameArr.length-1];
			var fileSufArr:Array = fileName.split('.');
			
			var webUrl:String = appCore.appConfig.configs.fWebServerURL;
			webUrl = webUrl.substring(0,webUrl.length);
			var downLoadUrl:String = StringUtil.trim(webUrl + str); //下载路径
			
			var urlRequest:URLRequest = new URLRequest(encodeURI(downLoadUrl));
			var fileReference:FileReference = new FileReference();
			
			fileReference.addEventListener(Event.COMPLETE,downLoadCompleteHandler);
			fileReference.addEventListener(IOErrorEvent.IO_ERROR,downLoadErrorHandler);
			fileReference.addEventListener(ProgressEvent.PROGRESS,downLoadProgressHandler);
			
			TAlert.show('点击"是",开始下载['+fileName+']',"提示",TAlert.YES|TAlert.NO,null,
				function sureDownLoad(event:CloseEvent):void
				{
					switch(event.detail) {
						case TAlert.YES:
							fileReference.download(urlRequest,fileName);
							break;
					}
				});
			
		}
		
		private function downLoadProgressHandler(event:ProgressEvent):void
		{
			var mProgress:int = event.bytesLoaded / event.bytesTotal * 100;
			sendSysInfo("文件正在下载中...已下载："+ mProgress.toString() + "%",false);
		}
		
		private function downLoadCompleteHandler(event:Event):void
		{
			sendSysInfo("文件下载成功！");
		}
		
		private function downLoadErrorHandler(event:IOErrorEvent):void
		{
			sendSysInfo("文件下载失败！");
		}
		
	}
}