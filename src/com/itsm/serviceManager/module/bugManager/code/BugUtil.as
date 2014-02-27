package com.itsm.serviceManager.module.bugManager.code
{
	import com.itsm.common.utils.AppCore;
	import com.itsm.serviceManager.component.bugDataGrid.BugDataGrid;
	
	import common.utils.TAlert;
	
	import flash.display.DisplayObject;
	
	import mx.collections.ArrayCollection;
	import mx.controls.DateField;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.effects.Fade;
	import mx.events.ValidationResultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.StringUtil;
	import mx.validators.Validator;
	
	import spark.components.Label;
	
	public class BugUtil
	{
		/**工具类*/
		public static var appCore:AppCore=AppCore.getInstance();
		
		public function BugUtil(){}
		
		/**闪烁提示方法*/
		public static function showAndHideLabel(lbBeforeSave:Label,isshow:Boolean,fade:Fade):void{
			if (isshow){
				lbBeforeSave.width=220;
				lbBeforeSave.visible = true;
				if (!fade){
					fade = new Fade();
					fade.target = lbBeforeSave;
					fade.repeatCount=0;
					fade.repeatDelay=100;
					fade.alphaTo=0;
				}
				fade.play();
			}else{
				lbBeforeSave.width=0;
				lbBeforeSave.visible = false;
				if (fade){
					fade.end();
					fade.stop();
				}
			}
		}
		
		/**公共方法，用于调用服务器端相应的方法处理*/
		public static function handle_server_method(
			componentName:String, className:String, methodName:String, arguments:Array, handleName:Function):void{
			
			appCore.dataDeal.dataRemote(componentName,className,methodName,arguments);
			appCore.dataDeal.remoteMethods.addEventListener(ResultEvent.RESULT, handleName);
		}
		
		/**弹出提示选择记录的信息框*/
		public static function popUpSelect():void{
			TAlert.show("请选择一条记录！","温馨提示");
		}
		
		/**将远程服务器返回的数据进行处理*/
		public static function getResultObj(event:ResultEvent):Object{
			var resultStr:String = event.result.toString();	
			return appCore.jsonDecoder.decode(resultStr);
		}
		
		/** 
		 * 验证方法 
		 * */ 
		public static function validate(validator:Validator, formIsValid:Boolean, focussedFormControl:DisplayObject):Boolean 
		{                
			//得到验证对象 
			var validatorSource:DisplayObject = validator.source as DisplayObject; 
			
			//镇压事件如果当前控制被验证的不是 
			//当前集中控制的形式。这阻止了用户 
			//从接收视觉验证提示在其他表单控件。 
			var suppressEvents:Boolean = (validatorSource != focussedFormControl); 
			
			//执行验证。返回一个ValidationResultEvent。 
			//传递null作为第一个参数使验证器 
			//使用属性中定义的属性的标记 
			// < mx:Validator >标记。 
			var event:ValidationResultEvent = validator.validate(null, suppressEvents);  
			
			//检查验证传递和返回一个布尔值。 
			var currentControlIsValid:Boolean = (event.type == ValidationResultEvent.VALID); 
			
			// 修改验证标记 
			formIsValid = formIsValid && currentControlIsValid; 
			
			return currentControlIsValid; 
		}
		
		/**这里主要是因为dropDownList的dataProvider需要的是IList接口对象*/
		public static function getArrayListFromObject(obj:Object):ArrayCollection{
			return new ArrayCollection(new Array(obj));
		}
		
		/**通过'YYYY-MM-DD'文本解析转换比较两时间大小
		 * 1:date1小于等于date2
		 * 0:date1大于date2*/
		public static function compareDate(date1:String, date2:String):String{
			var msg:String = "";
			var pattern:RegExp=/201[3-9]-((0[1-9])|(1[0-2]))-((0[1-9])|([1-2][0-9])|(3[0-1]))/;
			var startDate:Date, endDate:Date;
			
			if(myTrim(date1).match(pattern) 
				&& myTrim(date2).match(pattern)){
				startDate = DateField.stringToDate(myTrim(date1),"YYYY-MM-DD");
				endDate = DateField.stringToDate(myTrim(date2),"YYYY-MM-DD");
				if(startDate > endDate)
					msg += "0";
				else
					msg += "1";
			}else{
				msg += "有时间输入格式不正确!\n";
			}
			return msg;
		}
		
		/**重新设置BUG、问题、主需求表格宽度*/
		public static function resetColumnWidth(mainGrid:BugDataGrid):void
		{
			var mainGridColumnArr:Array = mainGrid.columns;
			for each(var obj:DataGridColumn in mainGridColumnArr){
				if(obj.dataField == "userApplyCode")
					obj.width = mainGrid.width * 0.09;
				if(obj.dataField == "belongSystem.systemName")
					obj.width = mainGrid.width * 0.09;
				if(obj.dataField == "applyTitle")
					obj.width = mainGrid.width * 0.19;
				if(obj.dataField == "urgent.levelNameString")
					obj.width = mainGrid.width * 0.06;
				if(obj.dataField == "range.constDetailName")
					obj.width = mainGrid.width * 0.09;
				if(obj.dataField == "sponsor.userName")
					obj.width = mainGrid.width * 0.09;
				if(obj.dataField == "applyStartDate")
					obj.width = mainGrid.width * 0.09;
				if(obj.dataField == "applyEndDate")
					obj.width = mainGrid.width * 0.09;
				if(obj.dataField == "replyer.userName")
					obj.width = mainGrid.width * 0.09;
				if(obj.dataField == "序号")
					obj.width = mainGrid.width * 0.03;
				if(obj.dataField == "applyStatusStr")
					obj.width = mainGrid.width * 0.09;
			}
		}
		
		/**重新设置子需求表格宽度*/
		public static function resetSubDemandColumnWidth(mainGrid:BugDataGrid):void
		{
			var mainGridColumnArr:Array = mainGrid.columns;
			for each(var obj:DataGridColumn in mainGridColumnArr){
				if(obj.dataField == "belongsSystem.systemName")
					obj.width = mainGrid.width * 0.1;
				if(obj.dataField == "demandTitle")
					obj.width = mainGrid.width * 0.21;
				if(obj.dataField == "urgent.levelNameString")
					obj.width = mainGrid.width * 0.06;
				if(obj.dataField == "range.constDetailName")
					obj.width = mainGrid.width * 0.1;
				if(obj.dataField == "analyst.userName")
					obj.width = mainGrid.width * 0.1;
				if(obj.dataField == "initDate")
					obj.width = mainGrid.width * 0.1;
				if(obj.dataField == "planFtestDate")
					obj.width = mainGrid.width * 0.1;
				if(obj.dataField == "sponsor.userName")
					obj.width = mainGrid.width * 0.1;
				if(obj.dataField == "序号")
					obj.width = mainGrid.width * 0.03;
				if(obj.dataField == "status")
					obj.width = mainGrid.width * 0.1;
			}
		}
		
		/**
		 * 字符串的首尾空格截取
		 */
		public static function myTrim(str:String):String{
			if(str != null)
				return StringUtil.trim(str);
			return "";
		}
		
		/**格式化查看,新增界面的时间*/
		public static function formateDate(currentDate:String):String{
			var dateStr:String;
			dateStr = BugUtil.myTrim(currentDate);
			if(dateStr.split("-").length < 3){
				var root:Array = StringUtil.trim(dateStr).split(" ");
				
				var year:String = root[2].toString();
				var month:String = root[0].toString().split("月")[0].toString();
				month = changeToArabicNum(month);
				var day:String = root[1].toString().split(",")[0].toString();
				if(parseInt(day) < 10)
					day = "0" + day;
				dateStr = year + "-" + month + "-" + day;
			}
			
			return dateStr;
		}
		
		
		
		public static function changeToArabicNum(month:String):String{
			
			var tmpStr:String;
			
			switch (month){
				
				case "一":
					tmpStr = "01";
					break;
				case "二":
					tmpStr = "02";
					break;
				case "三":
					tmpStr = "03";
					break;
				case "四":
					tmpStr = "04";
					break;
				case "五":
					tmpStr = "05";
					break;
				case "六":
					tmpStr = "06";
					break;
				case "七":
					tmpStr = "07";
					break;
				case "八":
					tmpStr = "08";
					break;
				case "九":
					tmpStr = "09";
					break;
				case "十":
					tmpStr = "10";
					break;
				case "十一":
					tmpStr = "11";
					break;
				default:
					tmpStr = "12";
					break;
				
			}
			
			return tmpStr;
		}
	}
}