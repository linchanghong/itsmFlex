package com.itsm.flow.app
{
	import com.itsm.common.utils.AppCore;
	import com.itsm.flow.base.ComApproveHistoryModi;
	import com.itsm.flow.base.TDataLoading;
	import com.itsm.flow.events.ReloadFlowtodoEvent;
	import com.services.flow.FlowNodeInstenceService;
	import com.vo.CusUserSet;
	import com.vo.CusUsers;
	
	import common.FlowGlobal;
	import common.components.CustLabel;
	import common.effect.LoadingProgressBar;
	import common.utils.FAppCoreUtil;
	import common.utils.TAlert;
	
	import flash.display.DisplayObject;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.formatters.DateFormatter;
	import mx.managers.PopUpManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import spark.components.ComboBox;
	import spark.components.HGroup;
	import spark.components.Label;
	
	
	[Bindable]
	public class GlobalUtil extends common.FlowGlobal
	{
		
		private static var _instence:GlobalUtil;
		public var  FCusUserSet:CusUserSet;              //用户个性化设置信息
		public var FUserRightXmlMenuArray:ArrayCollection=new ArrayCollection();  //存放当前用户权限的xml结构树。，包括模块内部的功能按钮		
		public var FRightsArr:ArrayCollection=new ArrayCollection();
		public var FServerDate:String;					//服务器断时间	     
		public var FcsProjectProgressConst:XMLList;///(系统参数常量,级联结构 ) -产品类型对应项目进度
		public var PrjCon:Boolean;  			//系统标志   true  false 
		public var FUrlParams:Object;
		public var FIsLogin:Boolean=false;  //登陆标志   true：已登陆   false： 未登陆
		public var FIsSinglePointLogin:Boolean=false;  //单点登陆标志   true：已登陆   false：未登陆
		public var SingleFlowInsId:int=0;  //单点打开待办
		public var FCurMoudleName:String="";  //当前窗口的父模块名 "客户化" 
		public var FCurWinName:String="";  //当前窗口名 cusuer
		public var FDoRefreshInterval:Number = 0;
		
		public var  FSysParamArray:Array=new Array();     //系统参数数组  {data:"1",type:"3",id:"",param:""}  {data:"1,2,3",type:"4",id:"",param:"20"}
		public var FSysParamStr:String="3,4,5,6,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46";     //系统参数字符串
		//预算控制参数设置 type 3（data:  0不控制，1强制，2提示）
		//费用报销方式参数设置 type4(vdata: 1回款比例报销，2进度比例报销，3合同签订报销(param 为未签订合同的报销比例))
		//是否需要差旅订票 type5(data: true ,false)
		//是否需要差旅订票 type 5(data: true ,false)
		//是否按总项目预算呈报 type 6(data: true ,false)
		
		public var FDocsUrl:String="";//
		public var FSecPolicyDoc:String=""; //
		public var FDocsRootPath:String="E:/Docs"
		public var FDocsPath:String="Documents/Private";//文档上传文件夹
		
		
		/** JMS下载通道 */
		public static const JMS_DOWNLOAD_URL:String="Documents/Private";
		//public static const JMS_DOWNLOAD_URL:String="http://localhost/Jms/";
		//public static const JMS_DOWNLOAD_URL:String="http://10.206.4.71/JMS_TEST/";
		
		
		public var FTepUrl:String ="http://218.6.169.108/Pcmsp/template/初始化信息导入表.xls"; //模板下载路径
		public var FImportPath:String="";//报表路径
		public var FExcelPath:String="";//Execl服务器保存路径
		public var FExcelUrl:String=""; //Execl下载路径
		public var FBatchRigthDir:String="";  //批量审批 上级名称 
		public var sysInfo:String="";
		//sender:CusUsers,,billid:int,conditions:Array,isReSubmit:Boolean,startFlowInstenceOk:Function
		/*private var Isender:CusUsers;
		private var IflowTypeId:int;
		private var Ibillid:int;
		private var Iconditions:Array;
		private var IisReSubmit:Boolean;
		private var IstartFlowInstenceOk:Function;*/
		public var FDataLoading:TDataLoading; 
		
		public function GlobalUtil(single:Single)
		{
			if (single==null)
				throw new Error("CcspmGlobal不能new操作");
		}
		
		public static function getInstence():GlobalUtil{
			if (_instence==null)
				_instence = new GlobalUtil(new Single());
			return _instence;
		}
		
		// 格式化传入的DateTime数据  
		public function GetDateTimeFormat(aValue:Object):String{
			var  mDateFormat:DateFormatter= new DateFormatter();
			mDateFormat.formatString="YYYY-MM-DD HH:NN:SS";
			return mDateFormat.format(aValue);		      
		}	
		
		public function parseStringToDateTime(aDateStr:String):Date   //YYYY-MM-DD HH:NN:SS
		{
			var mDate:Date=new Date;			
			if(aDateStr!=""&& aDateStr.indexOf("1900-01-01")<0)
			{
				//aDateStr=GetDateFormat("2009/4/3 15:30:02");
				aDateStr=GetDateTimeFormat(aDateStr);	
				
				mDate.setFullYear(Number(aDateStr.substr(0,4)));	
				mDate.setMonth(Number(aDateStr.substr(5,2))-1);  
				mDate.setDate(Number(aDateStr.substr(8,2)));	
				
				mDate.setHours(Number(aDateStr.substr(11,2)));
				mDate.setMinutes(Number(aDateStr.substr(14,2)));
				mDate.setSeconds(Number(aDateStr.substr(17,2)));
				//trace(mDate.getFullYear()+","+mDate.getMonth()+","+mDate.getDate()); // 2000	
				//trace(mDate.getHours()+","+mDate.getMinutes()+","+mDate.getSeconds()); // 2000
			}	      
			return mDate;
		}
		
		// 格式化传入的日期数据  
		public function GetDateFormat(aValue:Object):String{
			var  mDateFormat:DateFormatter= new DateFormatter();
			mDateFormat.formatString="YYYY-MM-DD";		        
			//return mDateFormat.format(aValue);		
			var mValue:String=mDateFormat.format(aValue);
			return (mValue.indexOf("1900-01-01")>=0)?"":mValue;      
		}
		
		public function parseStringToDate(aDateStr:String):Date   //YYYY-MM-DD 
		{
			var mDate:Date=new Date;			
			if(aDateStr!=""&& aDateStr.indexOf("1900-01-01")<0)
			{
				var dateArray:Array=new Array();
				
				aDateStr=GetDateFormat(aDateStr);	
				dateArray=aDateStr.split("-");
				mDate.setFullYear(Number(dateArray[0]));	
				mDate.setMonth(Number(dateArray[1])-1);  
				mDate.setDate(Number(dateArray[2]));			
			}	      
			return mDate;
		}
		
		/**
		 * 设置ComboBox的值
		 * */
		public function setComboBox(aComboBox:ComboBox,aID:int):void
		{
			var xml:XMLListCollection = aComboBox.dataProvider as XMLListCollection;
			var len:int = xml.length;
			for(var i:int = 0;i <len;i++)
			{
				if (xml[i].@id == aID)
				{
					aComboBox.selectedIndex = i;
					break;	
				}							 
			}
		}
		
		public function setComboBoxForArray(aComboBox: ComboBox,aID:int):void
		{
			
			for(var i:int = 0;i < (aComboBox.dataProvider as ArrayCollection).length;i++)
			{
				if ((aComboBox.dataProvider as ArrayCollection)[i].id == aID)
				{
					aComboBox.selectedIndex = i;
					break;	
				}							 
			}
		}
		
		
		public function getComboBoxIndex(aComboBox:ComboBox,aID:int):int{
			for(var i:int = 0;i < (aComboBox.dataProvider).length;i++)	{
				if (aComboBox.dataProvider[i].@id == aID)
					return i;
			}
			return 0;
		}
		
		/**
		 * 得到参数设置的值  
		 * 返回值Object ( id,data,param)
		 * */
		public function getUserSetBySetTypeID(SetTypeID:int):Object{
			var item:Object;
			for (var i:int=0;i<FSysParamArray.length;i++)
			{
				if (FSysParamArray[i].type== String(SetTypeID))
					item = FSysParamArray[i];
			}
			//如果转换类型则设置
			switch (SetTypeID)
			{
				case 17:
				case 15:
				case 19:
				case 20:
				case 21:
				case 38:
				case 30:
					if(item==null) item = new Object();
					item.data=((item==null || item.data==null || item.data=="0"||item.data=="")?false:true);
					item.param=int(item.param);
					break;
				case 22:
				case 23:
				case 24:
				case 27:
				case 45:
				case 46:					
					if(item==null) item = new Object();
					item.data=((item==null || item.data==null || item.data=="0"||item.data=="") ? false:true);
					item.param=String(item.param);
					break;
				case 37:
					if(item==null) item = new Object();
					item.data=((item==null || item.data==null || item.data=="0"||item.data=="")?false:true);
					item.param=int(item.param);
					break;
				case 40:
					if(item==null) item = new Object();
					item.subMustBgn = ((item==null || item.data==null || item.data=="0"||item.data=="" ||item.data=="1")?false:true);
					item.data=((item==null || item.data==null || item.data=="0"||item.data=="" ||item.data=="1")?1:2);
					item.param=int(item.param);
					break;
				case 44:
					if(item==null) item = new Object();
					item.CGBgnMustSub = ((item!=null && item.data=="1")?true:false);
					item.param=int(item.param);
					break;
			}
			return item;
		}
		
		/**
		 * 发送系统消息到弹出窗口
		 * */
		override public function sendSysInfo(aSysInfo:String):void     
		{
			TAlert.show(aSysInfo,"系统提示");
		}
		
		/**
		 * 发送系统消息到系统消息台左下角显示  
		 * */
		override public function showInfotoLeftLowerCorner(sendSysInfo:String):void{
			AppCore.getInstance().sendSysInfo(sendSysInfo);
		}
		
		
		public function downloadFiles(aTypeID:int,KeyValue:String):void  //下载文件
		{		
			var mURL:String=FDocsUrl+"esDownload.aspx?TypeID="+aTypeID.toString()+"&KeyValue="+KeyValue;
			navigateToURL(new URLRequest(mURL));
		} 
		
		public function GetUrl():String
		{
			var Url:String =  FlexGlobals.topLevelApplication.loaderInfo.url;
			var Url1:String = Url.substring(7,Url.length);           
			return Url.substring(0,Url1.indexOf("/",0)+7);
		}	   
		/**
		 * 流程呈报
		 * 呈报人，发起人,类型，数据ID，部门条件，是否在次呈报，呈报成功回调方法
		 * */
		public function StartFlowInstence(sender:Object, sendId:String, flowTypeId:String,billid:String,conditions:Array,isReSubmit:Boolean,startFlowInstenceOk:Function):void{
			
			var flow:FlowNodeInstenceService = new FlowNodeInstenceService("flowGlobal", "FlowGlobal");
			//LoadingProgressBar.addPopUp(DisplayObject(FlexGlobals.topLevelApplication),false);
			showLoading();
			flow.StartFlowInstence(sender, sendId, flowTypeId,billid,conditions,isReSubmit)
				.addResultListener(
					function remove(event:ResultEvent):void{
						//LoadingProgressBar.removePop();
						closeLoading();
						//提示流程到了哪儿
						
						var json:String=event.result as String;
						var item:Object =JSON.parse(json) as Object;
						
						if(item==null) {
							sendSysInfo("流程模型设置有误!");
							return;
						}else{
							sendSysInfo(item.msg);
							
							if(item.result){
								startFlowInstenceOk.call(null,event);
								if(isReSubmit){
									var closeevent:ReloadFlowtodoEvent = new ReloadFlowtodoEvent(null);
									FlexGlobals.topLevelApplication.dispatchEvent(closeevent);
								}
							}
						}
						//	var result:Array = event.result as Array;
//						if(result==null) {
//							sendSysInfo("流程模型设置有误!");
//							return;
//						}
//						//如果流程模板设置为可修改流程
//						if (result!==null && result.length>1 && result[0]["IsSubmitModify"]){
//							var aParent:DisplayObject=DisplayObject(FlexGlobals.topLevelApplication);
//							var apphismodi:ComApproveHistoryModi=ComApproveHistoryModi(PopUpManager.createPopUp(aParent, ComApproveHistoryModi, true));
//							apphismodi.setApproveHistory(result);
//							PopUpManager.centerPopUp(apphismodi);
//							apphismodi.addEventListener(ComApproveHistoryModi.EVENT_APPHIS_EDIT_OK,
//								function onEditOK():void{
//									apphismodi.removeEventListener(ComApproveHistoryModi.EVENT_APPHIS_EDIT_OK,onEditOK);
//									startFlowInstenceOk.call(null,event);
//								});
//						}
//						else if (result.length==2){
//							sendSysInfo("流程已经通过，请到待办中处理通过通知!");
//						}else if (result.length>2){
//							for each(var item:Object in result){
//								var checkStte:int = FAppCoreUtil.getNumber(item.CheckState);
//								if (checkStte==142){
//									if (item.HandlerName && item.HandlerName!=""){
//										sendSysInfo("呈报成功，待办已经发送到:"+item.HandlerName+"  ");
//									}
//									break;
//								}
//							}
//							startFlowInstenceOk.call(null,event);
//						}else
//							sendSysInfo("流程模型设置有误!");
					})
				.addFaultListener(function faultRmove(evnet:FaultEvent):void{
					//LoadingProgressBar.removePop();
					closeLoading();
					TAlert.show("流程模型设置有误,请联系公司管理员修改后再呈报----"+evnet.fault.faultString);
				});
				//.addResultListener(startFlowInstenceOk);			
			
		}
		
		/**
		 * 得到四舍五入的数
		 * */
		public function getNumber(value:*,fractionDigits:int=4):Number
		{
			value = Number(value);
			if (isNaN(value)) value=0;
			return Number(value.toFixed(fractionDigits));
		}
		
		/**
		 * 初始化项目过程是否必填
		 * 红色/黑色显示
		 * 最多包扩2个容器的所有元素，超过请重写或者更改为递归
		 * */
		public function initComponetTro(aParantObject:Object,PscSetS:ArrayCollection):Array
		{
			if(PscSetS==null&&PscSetS.length<=0)
				return null;
			var btnArr:Array = new Array();
			var index:int=0;	
			var len:int = aParantObject.numElements;
			for(index=0;index<len;index++){
				var vlen:int = (aParantObject.getElementAt(index) as Object).numElements;
				if(vlen==0){
					btnArr.push(aParantObject.getElementAt(index));
					continue;
				}
				for(var vindex:int=0;vindex<vlen;vindex++){			
					btnArr.push((aParantObject.getElementAt(index) as Object).getElementAt(vindex));			
				}			
			}
			for each(var o:Object in btnArr)
			{
				for each(var item:Object in PscSetS)
				{
					if (o.id==item.LabelId){
						if(item.IsInto==1){
							if(item.IsEdit==1)//允许进行非填入控制
							{
								o.text="*"+item.LabelTxt;
								o.setStyle("color","#FF0000");
							}							
							(o as CustLabel).isMustfill=true; 
						}
						else
						{
							if(item.IsEdit==1)//允许进行非填入控制
							{
								o.text=item.LabelTxt;
								o.setStyle("color","#000000");
							}								
							(o as CustLabel).isMustfill=false;
						}
					}
				}
			}
			return btnArr;
		}
		
		/**
		 * 初始化按钮权限
		 * */
		public function initModelMight(aParantObject:Object):void{
			var btnArr:Array = new Array();
			var index:int=0;
			/*try{
			while (aParantObject.getElementAt(index)){
			btnArr.push(aParantObject.getElementAt(index));
			index++;
			}} catch(e:Error)
			{
			trace(index.toString()+ '---'+ e.toString());
			}
			finally{*/
			var len:int = aParantObject.numElements;
			for(index=0;index<len;index++){
				btnArr.push(aParantObject.getElementAt(index));
			}
			var Module:int=0;
			var Levels:String="";
			var righArr:Array=new Array();
			for (var i:int=0;i<FRightsArr.length;i++){
				var item:Object = FRightsArr[i];
				var classPath:String = (item.ClassPath as String)==null?"":(item.ClassPath as String);
				var className:String = classPath.substring(classPath.lastIndexOf(".")+1,classPath.length);
				if (className==aParantObject.document.className) {
					Module=item.Module as int;
					Levels=item.Levels as String;
					for (var j:int=i+1;j<FRightsArr.length;j++){
						var btn:Object = FRightsArr[j];
						if (btn.Module==Module && (btn.Levels as String).indexOf(Levels)!=-1 && btn.IsButton)
							righArr.push(btn);
						else
							break;
					}
					break;
				}
			}
			for each(var o:Object in righArr){
				var viewbtn:Object = getChildById(btnArr,o.ControlName);
				if (viewbtn!=null) viewbtn.enabled=true; 
			}
			/*}*/
		} 
		
		
		//显示数据等待窗口
		public function showLoading(aParent:DisplayObject=null):void{   
			if(aParent==null) aParent=DisplayObject(FlexGlobals.topLevelApplication);
			if (FDataLoading ==null) //aLoading=new TDataLoading();		
				FDataLoading=TDataLoading(PopUpManager.createPopUp(aParent,TDataLoading , true));		  		  
			FDataLoading.addEventListener(CloseEvent.CLOSE,closeLoading);
			PopUpManager.centerPopUp(FDataLoading);
			
		}
		
		//关闭数据等待窗口
		public function closeLoading(aEvent:CloseEvent=null):void{ 
			if (FDataLoading!=null){
				/*  flash.utils.setTimeout(
				function():void{	 */	    
				PopUpManager.removePopUp(FDataLoading);
				FDataLoading=null;
				/*  },1000,null);  */
			};
		}
		
		private function getChildById(btnArr:Array,id:String):Object {
			if (btnArr==null || btnArr.length==0) return null;
			for each(var item:Object in btnArr)
			if (item.id==id) return item;
			return null;
		}	
		
		/**
		 * 得到货币字符的值
		 * */
		public function currencyClearSybolValue(value:String,sybol:String="￥",thousands:String=","):Number
		{
			if (value==null || value=="") return 0;
			//取消货币符号
			var indx:int=value.indexOf(sybol);
			if (indx>=0) value = value.substr(0,indx)+ value.substring(indx+1,value.length); 
			//循环取消分号
			var indxth:int=value.indexOf(thousands);
			while (indxth>=0)
			{
				value = value.substr(0,indxth) + value.substring(indxth+1,value.length);
				indxth=value.indexOf(thousands);
			}
			
			var valueFloat:Number = Number(value);
			if (isNaN(valueFloat)) return 0;
			return valueFloat;
		}
		
		//得到合同编号
//		public function getNewBargainCode(provinceId:int,compId:int,profCode:String,onResultEvent:Function = null):void //
//		{
//			new BgnBargainService().GetNewBargainCode(provinceId,compId,profCode).addResultListener(onResultEvent).addFaultListener(onServicefault);
//		}
		private function onServicefault(aEvent:FaultEvent):void{
			FlexGlobals.topLevelApplication.canCheckLoadingBestrow.visible=false;       	 
		} 
		
		public function setComboBoxForSysArray(aComboBox: ComboBox,aID:int):void
		{
			
			for(var i:int = 0;i < (aComboBox.dataProvider as ArrayCollection).length;i++)
			{
				if ((aComboBox.dataProvider as ArrayCollection)[i].data == aID)
				{
					aComboBox.selectedIndex = i;
					break;	
				}							 
			}
		}	
		/**
		 * 成本查看范围
		 * detpColumnName 部门字段名称
		 * userColumnName 录入人用户字段名称
		 * proManageColumnName 项目经理字段名称
		 * user2ColumnName  发起人字段名
		 * */
		public function getCostViewWhere(detpColumnName:String="",userColumnName:String="",proManageColumnName:String="",user2ColumnName:String=""):String
		{
			var where:String = " 1=1 ";
			for (var index:String in FSysParamArray)
			{
				if ("15"==FSysParamArray[index].type)
				{
					var costControl:String = FSysParamArray[index].data;
					if ("1"==costControl)
					{
						var depts:String = FCusUser.CostViewDepts;
						if (depts==null || depts=="") depts="0";
						if (depts.charAt(0)==',')depts=depts.substr(1,depts.length-1);
						where = " (";
						if (detpColumnName!=null && detpColumnName!="")
							where = where + detpColumnName + " in("+depts+") ";
						if (userColumnName!=null && userColumnName!="")
							where = where+ " or " + userColumnName + "=" +  FCusUser.UserId.toString();
						if (proManageColumnName!=null && proManageColumnName!="")
							where = where + " or " + proManageColumnName + "=" + FCusUser.UserId.toString();
						if (user2ColumnName!=null && user2ColumnName!=""){
							where = where + " or " + user2ColumnName + "=" + FCusUser.UserId.toString();
						}
						where += ") ";
					}
					break;
				}
			}
			return where;
		}
		
		//根据省份获取城市数据
		public function  getCityDataByProId(aProvinceId:String,aResultEvent:Function=null):void
		{
//			ConstService.GetCityDataByProId(aProvinceId).addFaultListener(onServicefault);
//			ConstService.GetCityDataByProId(aProvinceId).addResultListener(aResultEvent);
		}
		
	}
}

class Single
{
	
}