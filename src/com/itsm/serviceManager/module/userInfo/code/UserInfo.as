import com.adobe.serializers.json.JSONDecoder;
import com.adobe.serializers.json.JSONEncoder;
import com.itsm.common.utils.AppCore;
import com.itsm.flow.app.GlobalUtil;
import com.itsm.serviceManager.flow.app.BugGlobalUtil;
import com.itsm.serviceManager.module.bugManager.code.BugUtil;
import com.itsm.serviceManager.module.bugManager.mxml.PopSearchUserApply;
import com.itsm.serviceManager.module.bugManager.vo.ConstDetailVO;
import com.itsm.serviceManager.module.bugManager.vo.MsUserVO;
import com.itsm.serviceManager.module.bugManager.vo.ReplyLevelVO;
import com.itsm.serviceManager.module.bugManager.vo.SupportSystemVO;
import com.itsm.serviceManager.module.bugManager.vo.SystemModuleVO;
import com.itsm.serviceManager.module.bugManager.vo.UserApplyVO;
import com.itsm.serviceManager.module.problemManager.mxml.PopProblemSearchUserApply;

import common.utils.TAlert;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.containers.FormItem;
import mx.containers.TabNavigator;
import mx.controls.Alert;
import mx.controls.DateField;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.events.CalendarLayoutChangeEvent;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.events.ListEvent;
import mx.events.ValidationResultEvent;
import mx.formatters.DateFormatter;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;
import mx.utils.ArrayUtil;
import mx.utils.StringUtil;
import mx.validators.Validator;

import org.hamcrest.mxml.object.Null;

import spark.components.Button;
import spark.components.List;
import spark.components.NavigatorContent;
import spark.components.TabBar;
import spark.events.GridSelectionEvent;
import spark.events.IndexChangeEvent;


private var appCore:AppCore = AppCore.getInstance();

private var FAppCore:GlobalUtil = GlobalUtil.getInstence();

[Bindable]
private var now:Date = new Date();

//用户所选择的系统id
[Bindable]
public var systemID:uint;

//一个请求单对象
[Bindable]
public var userApply:Object;

//一个需求单请求对象
[Bindable]
public var userApplyObj:Object;

//一个子需求单对象
[Bindable]
public var subDemandObj:Object;

//子需求单集合
[Bindable]
public var subDemandsArray:Array = null;

//子需求单的id
[Bindable]
public var subDemandID:String = "";

//流程模型类型
private static const US_FLOW_TYPE:String="6";

//请求的id
[Bindable]
public var userApplyID:Number = 0;

//文档上传所对应的业务表单ID
[Bindable]
public var applyID4Word:String = "";

//请求单所在数据库表名
[Bindable]
public var applyTableName:String = "T_USER_APPLY";

//需要构建的code
[Bindable]
private var codeStr:String;

//选中树数据
[Bindable]
private var selectUnit:Object = null; 

//给dropDownList传数据
[Bindable]
public var list:ArrayCollection;	

//bug来源
[Bindable]
public var bugSources:ArrayCollection;

//bug作用范围
[Bindable]
public var bugScops:ArrayCollection;

//所属系统
[Bindable]
public var systems:ArrayCollection;

//所属系统的业务模块
[Bindable]
public var modules:ArrayCollection;

//实际作用范围
[Bindable]
public var realBugScops:ArrayCollection;

//重要程度
[Bindable]
public var levels:ArrayCollection;

//主页表格数据集
[Bindable]
public var mainGridArray:Array = null;

//brother表格数据集
[Bindable]
public var b_mainGridArray:Array = null;

//弹窗选择人员后,单位存储
[Bindable]
public var company:String = "";

//弹窗选择人员后,部门存储
[Bindable]
public var dept:String = "";

//当前在编辑对象
[Bindable]
private var apply:UserApplyVO;

//选择的报告人对象
[Bindable]
private var selectUser:Object = "";

//选择的系统对象
[Bindable]
private var selectSys:Object = "";

//报告时间
[Bindable]
private var reportTime:Date = new Date();

//1:代表查询problem 2：代表查询bug
[Bindable]
private var FLAG:int;
//流程模型类型
[Bindable]
private var FLOW_TYPE:String;

//呈报对象
[Bindable]
private var putObj:Object;

//记录主页表格弹起的是哪个流程的流程状态图
[Bindable]
private var flow_index:int = -1;

//排序方式:是否升序
private static const SORT_FLAG:Boolean = false;

//呈报时判断
[Bindable]
private var FISAfterFlowCommit:Boolean=false;

//是否在查看页面显示"呈报"按钮
[Bindable]
private var viewPutBtn:Boolean = false;

//呈报按钮是否有效
[Bindable]
private var enablePutBtn:Boolean = false;

//持有该目前集中控制的对象。 
private var focussedFormControl:DisplayObject;

//表单是否有效 
[Bindable] 
private var formIsValid:Boolean = true;

//表单是否为空 
[Bindable] 
public var formIsEmpty:Boolean = true; 

//判断系统下拉是否被点击,没有就说明其值是userApply的原始值
[Bindable]
private var isSystemBeClicked:Boolean = false;

//验证各个控件的信息
//[Bindable]
//private var validatorArr:Array;


//===============公共调用方法=============开始==========
//增加里面的两种状态的选择
[Bindable]
private var arrayType:ArrayCollection = new ArrayCollection([{type:"问题请求"},{type:"BUG请求"},{type:"需求"}]);
//请选择请求类型
protected function selectType_changeHandler(event:IndexChangeEvent):void
{
	// TODO Auto-generated method stub
	if(selectType.selectedIndex==0){
		
		this.currentState="problem";
		removeInfo();
	}
	
	
	if(selectType.selectedIndex==1){
		
		this.currentState="bug";
		removeInfo();
	}
	
	if(selectType.selectedIndex==2){
		this.currentState="demand";
		removeInfo();
	}
	
}

//将远程服务器返回的数据进行处理
private function getResultObj(event:ResultEvent):Object{
	var resultStr:String = event.result.toString();	
	
	trace("远程服务器返回的数据为："+resultStr);
	
	return new JSONDecoder().decode(resultStr);
}

//弹出提示选择记录的信息框
private function popUpSelect():void{
	TAlert.show("请选择一条记录！","温馨提示");
}

//判断是否选择了一条请求单记录
private function isSelect():Boolean{
	if(mainGrid.selectedIndex == -1){
		return false;
	}
	return true;
}

//公共方法，用于调用服务器端相应的方法处理
private function handle_server_method(
	componentName:String, className:String, methodName:String, arguments:Array, handleName:Function):void{
	
	appCore = AppCore.getInstance();
	
	appCore.dataDeal.dataRemote(componentName,className,methodName,arguments);
	appCore.dataDeal.remoteMethods.addEventListener(ResultEvent.RESULT, handleName);
}

//===============公共调用方法==============结束=========

/**
 * 初始化
 * 
 * 主菜单
 */
private function initPopSearchUserApply():void{
	
	AppHistoryGrid.gridMain.OnlyInit();
	appCore = AppCore.getInstance();
	
	//主页表格数据初始化
	mainGridArray = ['bugManagerAPI', 'BugManagerAPI', 'uServiceHomePageFast',[appCore.loginUser.id]];
	
	//系统
	if(!(systems != null))
		handle_server_method("bugManagerAPI","BugManagerAPI","initSupportSystems",
			[], function(event:ResultEvent):void{
				systems = getResultObj(event) as ArrayCollection;
			});
	
	//重要程度
	if(!(levels != null))
		handle_server_method("bugManagerAPI","BugManagerAPI","initLevels",
			[], function(event:ResultEvent):void{
				levels = getResultObj(event) as ArrayCollection;
			});
	
	//影响范围
	if(!(bugScops != null))
		handle_server_method("bugManagerAPI","BugManagerAPI","initBugScope",
			[], function(event:ResultEvent):void{
				bugScops = getResultObj(event) as ArrayCollection;
			});
	
}

//格式化查看,新增界面的时间
private function formateDate(currentDate:String):String{
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


//格式化日期
private function changeToArabicNum(month:String):String{
	
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

//格式化主页表格日期字段方法。myDateF是一个DateFormatter。
private function formatDateTime(item:Object,column:DataGridColumn):String{
	
	//TAlert.show(item.userApplyCode as String);
	
	function formateDate(item:Object, flag:int):String{
		
		var dateStr:String;
		
		if(flag == 0){
			dateStr = BugUtil.myTrim(item.applyStartDate);				
		}else if(flag == 1)
			dateStr = BugUtil.myTrim(item.applyEndDate);
		else if(flag == 2)
			dateStr == BugUtil.myTrim(item.replyTime);
		else if(flag == 3)
			dateStr == BugUtil.myTrim(item.planFinishTime);
		else if(flag == 4)
			dateStr == BugUtil.myTrim(item.planFinishTime);
		
		if(!dateStr.match(/\d{4}-\d{2}-\d{2}/)){
			
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
	
	if(column.dataField == "applyStartDate")
		return formateDate(item, 0);
	else if(column.dataField == "applyEndDate")
		return formateDate(item, 1);
	else if(column.dataField == "replyTime")
		return formateDate(item, 2);
	else if(column.dataField == "planFinishTime")
		return formateDate(item, 3);
	else //planFinishTime
		return formateDate(item, 4);
	
	
}

//这里主要是因为dropDownList的dataProvider需要的是IList接口对象
private function getArrayListFromObject(obj:Object):ArrayCollection{
	return new ArrayCollection(new Array(obj));
}


/**验证方法*/
private function validateForm(event:Event):void  
{                     
	//由于界面值有修改,so--将呈报按钮置灰,保存按钮激活
	enablePutBtn = false;
	//检查验证传递和返回一个布尔值相应。 
	//保存引用当前集中表单控件 
	//这样isValid()辅助方法可以只通知 
	//当前集中形式控制和不影响 
	//任何其他的表单控件。 
	focussedFormControl = event.target as DisplayObject;   
	
	// 检查表单是否为空 
	if(this.currentState=="problem" || this.currentState=="bug" || this.currentState=="demand"){
		// 标记表单有效的开始 
		formIsValid = applyEndDate.selectedDate >= new Date();
		
		formIsEmpty = telephoneInput.text == "" ||
			applyEndDate.text == "" ||
			applyTitleInput.text == "" ||
			directionsArea.text == ""; 
		
		//运行每个验证器反过来,使用isValid() 
		//辅助方法和更新formIsValid的价值 
		//因此。 
		validateV(telephoneInputV); 
		validateV(applyEndDateV); 
		validateV(applyTitleInputV); 
		validateV(directionsAreaV); 
	}
	
	if(this.currentState=="mod"){
		var df:DateFormatter = new DateFormatter();
		df.formatString="YYYY-MM-DD";
		// 标记表单有效的开始 
		if(applyEndDateQ.selectedDate != null){
			formIsValid = applyEndDateQ.selectedDate >= new Date();	
		}
		
			
		formIsEmpty = telephoneInputQ.text == "" ||
			applyTitleInputQ.text == "" ||
			directionsAreaQ.text == ""; 
		
		//运行每个验证器反过来,使用isValid() 
		//辅助方法和更新formIsValid的价值 
		//因此。 
		validateV(applyEndDateQV); 
		validateV(applyTitleInputQV); 
		validateV(directionsAreaQV); 
	}
	
	
} 

/** 
 * 验证方法 
 * */ 
private function validateV(validator:Validator):Boolean 
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

/**验证用户输入数据*/
private function validate():Boolean{
	
	//定义一个返回错误信息的集合
	var msg:String = "";
	var flag:uint = 0;
	
	/*var info1:String = BugUtil.compareDate(applyStartDate.text, applyEndDate.text);
	if(info1 != "1"){
		formIsValid=false;
		if(info1 == "0")
			msg += "报告时间晚于期望解决时间!\n";
		else
			msg += info1;
	}else
		flag++;*/
	
	judgeFormIsEmpty();
	
	if(formIsEmpty){
		Alert.show("还有值域为空！","警告");
		formIsValid=false;
		return false;
	}
	
	if(flag == 1)
		formIsValid = true;
	
	if(!formIsValid){
		msg += "请注意页面警告信息!";
		TAlert.show(msg,"警告");
		return false;
	}else {
		//		Alert.show("验证成功！","信息");
		//		return true;
	}
	
	if(!formIsEmpty && formIsValid)
		return true;
	else
		return false;
	
}

/**判断是否有空字段*/
private function judgeFormIsEmpty():void{
	// 检查表单是否为空
	if(this.currentState=="problem" || this.currentState=="bug" || this.currentState=="demand"){
		formIsEmpty = telephoneInput.text == "" ||
			applyEndDate.text == "" ||
			applyTitleInput.text == "" ||
			directionsArea.text == ""; 
	}
	if(this.currentState=="mod"){
		formIsEmpty = telephoneInputQ.text == "" ||
			applyTitleInputQ.text == "" ||
			directionsAreaQ.text == ""; 
	}
	
}
/**
 * 验证添加按钮内的控件
 * 
 * */
/*private function validate():Boolean{
	
	//定义一个返回错误信息的集合
	var results:String="";	
	var flag:Boolean=true;
	
	
	//初始化需要验证的控件ID
	validatorArr = new Array();
	
	validatorArr.push(sponsorInput_id);
	validatorArr.push(companyInput_id);
	validatorArr.push(departmentInput_id);
	validatorArr.push(telephoneInput_id);
	
	if(this.currentState=="problem"){
		//初始化问题模块各个属性的验证
		validatorArr.push(applyEndDateP_id);
		
		validatorArr.push(bugSourceP_id);
		validatorArr.push(bugUrgentP_id);
		validatorArr.push(bugRangeP_id);
		validatorArr.push(bugSystemP_id);	
		validatorArr.push(bugModuleP_id);
		
		validatorArr.push(applyTitleInputP_id);	
		validatorArr.push(directionsAreaP_id);
		
		if(applyEndDateP.text<DateField.dateToString(reportTime,"YYYY-MM-DD")){
			results+="期望解决的时间不能小于当前时间！\n";
			flag=false;
		}
	}
	
	if(this.currentState=="bug"){
		//初始化bug模块各个属性的验证
		validatorArr.push(applyEndDate_id);
		
		validatorArr.push(bugSource_id);
		validatorArr.push(bugUrgent_id);
		validatorArr.push(bugRange_id);
		validatorArr.push(bugSystem_id);	
		validatorArr.push(bugModule_id);
		
		validatorArr.push(applyTitleInput_id);	
		validatorArr.push(directionsArea_id);
		
		if(applyEndDate.text<DateField.dateToString(reportTime,"YYYY-MM-DD")){
			results+="期望解决的时间不能小于当前时间！\n";
			flag=false;
		}
	}
	
	
	//开始验证
	var validatorErrorArray:Array = Validator.validateAll(validatorArr);
	var isValidForm:Boolean = validatorErrorArray.length == 0;
	
	if(!sponsorInput.selectObj.hasOwnProperty("userId")&&""==sponsorInput.sText){
		results+="报告人未选择！\n";
		flag=false;
	}
	
	if(!isValidForm){
		Alert.show("还有值域为空！","警告");
		return false;
	}else if(!flag){
		Alert.show(results,"警告");
		return false;
	}else {
		//Alert.show("验证成功！","信息");
		return true;
	}
	return false;
	
}*/

//重置下拉列表的项目以便其能够正常显示所选userApply中的对应值
private function removeInfo():void{
	
	if(this.currentState=="problem" || this.currentState=="bug" || this.currentState=="demand"){
		
		//重置bug模块的各个属性
		//重要程度
		bugUrgent.selectedIndex = -1;
		//影响范围
		bugRange.selectedIndex = -1;
		//所属系统
//		bugSystem.selectedIndex = -1;
		//所属业务模块
//		bugModule.selectedIndex = -1;
		
		//期望解决时间
		applyEndDate.text="";
		//主题摘要
		applyTitleInput.text="";	
		//bug描述
		directionsArea.text="";
		//所属系统
		bugSystem.sText = "";
		//所属业务模块
		bugModule.sText = "";		
		//清除bug模块的验证的提示信息
		applyEndDate.errorString="";
		
		bugUrgent.errorString="";
		bugRange.errorString="";
		bugSystem.errorString="";
		bugModule.errorString="";
		
		//期望解决时间
		applyEndDate.errorString="";
		//主题摘要
		applyTitleInput.errorString="";
		//bug描述
		directionsArea.errorString="";
		
		if(this.currentState == "demand"){
			reasonArea.text="";
			
			reasonArea.errorString="";
		}
	}
}

//================首页各个按钮的事件：查看、修改、新增、删除、呈报、查询、刷新、明细===================

/**
 * 获取需求服务单明细
 */
protected function btnBrother_clickHandler(event:MouseEvent):void{
	var item:Object = mainGrid.selectedItem as Object;
	userApplyObj = item;
	if(item==null)
		TAlert.show("请选择一条数据！", "温馨提示");
	else{
		if(userApplyObj.applyType != 3){
			TAlert.show("您选择的数据不符合要求,重新选择需求单！","温馨提示");
		}else{
			if(userApplyObj.applyStatusStr == "处理中"){
				if(userApplyObj.subDemandCount > 0){
					this.currentState = "brother";
					b_mainGridArray = ["bugManagerAPI", "BugManagerAPI", 'getSubDemandsByApplyID', 
						[userApplyObj.applyId]];
				}else{
					TAlert.show("您选择的需求单还未添加子需求单！","温馨提示");
				}
			}else{
				TAlert.show("仅限于状态为“处理中”的需求单！","温馨提示");
			}
		}
	}
}

/**
 * 查看
 * 
 * */
protected function queryBtn_clickHandler(event:MouseEvent):void
{
	/*初始化系统是否被点击状态,这里用于模块下拉菜单加载使用,这里也设置,
	是因为当请求单是"未提交"状态时,是会跳转到修改界面的*/
	isSystemBeClicked = false;
	//判断是否选择数据
	if(!isSelect()){
		popUpSelect();
		return;
	}
	
	var item:Object = mainGrid.selectedItem;
	userApply = item;
	if(item==null)
		TAlert.show("请选择要修改的数据！", "温馨提示");
	else{
		
		if(userApply != null && userApply.applyId > 0){
			
			userApplyID = mainGrid.selectedItem.applyId;
			applyID4Word = userApplyID.toString();
			
			handle_server_method("bugManagerAPI","BugManagerAPI","showUserApllyByID",
				[userApplyID], function(event:ResultEvent):void{
					userApply = getResultObj(event) != 0 ? getResultObj(event) : null;
					applyID4Word = ""+userApplyID;
					
					if(userApply.hasOwnProperty("subDemandCount") && userApply.subDemandCount > 0)
						subDemandsArray = 
						['bugManagerAPI', 'BugManagerAPI', 'getSubDemandsByUserApplyID', [userApplyID]];
					
					company = userApply != null ? userApply.company : '';
					dept = userApply != null ? userApply.department : '';
					
//					company = userApply != null ? userApply.company : '';
//					dept = userApply != null ? userApply.department : '';
					
				});
			
			handle_server_method("bugManagerAPI","BugManagerAPI","getPersonIdByApplyId",
				[userApply.applyId],afterGetPersonId4queryHandle);
		}else{
			TAlert.show("系统繁忙,稍后再试!","温馨提示");
		}
	}
	
}

//查看的回调函数
private function afterGetPersonId4queryHandle(event:ResultEvent):void{
	
	var obj:Object = getResultObj(event);
	var persons:ArrayCollection;
	
	if(obj != "0" ){
		persons = (obj as ArrayCollection).getItemAt(0) as ArrayCollection;
		if(persons != null && persons.length > 0){
			//是否是填单人或者报告人查看,如果是就可以编辑
			if(persons.getItemAt(0) == FAppCore.FCusUser.UserId
				|| persons.getItemAt(1) == FAppCore.FCusUser.UserId){
				//如果说请求单的状态为"未提交"则显示激活"呈报"按钮并且将"保存"按钮置灰
				viewPutBtn = userApply != null && userApply.applyStatus == 0;
				enablePutBtn = viewPutBtn;
				if(viewPutBtn)
					this.currentState = "mod";
				else{
					if(userApply.applyType == 3){
						this.currentState="demandquery";
					}else{
						this.currentState = "query";	
					}
				}
					
				if(userApply != null){
					if(userApply.applyType == 3){
						bugDirBtnQ.label = "需求描述";
					}else{
						if(userApply.applyType == 1){
							bugDirBtnQ.label = "问题描述";	
							bugTypeBtn.label = "问题类型";
							bugReasonAna.label = "问题原因分析";
							bugResolvent.label = "问题解决方案";
						}else if(userApply.applyType == 2){
							bugDirBtnQ.label = "BUG描述";
							bugTypeBtn.label = "bug类型";
							bugReasonAna.label = "bug原因分析";
							bugResolvent.label = "bug解决方案";
						}
					}
				}
			}else{
				//如果说请求单的状态为"未提交"则显示激活"呈报"按钮并且将"保存"按钮置灰
				enablePutBtn = viewPutBtn = false;
				this.currentState = "query";
			}
		}else
			TAlert.show("系统繁忙,稍后再试!","温馨提示");
	}else
		TAlert.show("系统繁忙,稍后再试!","温馨提示");
}



/**
 * 修改
 * 
 * */
protected function modfiyBtn_clickHandler(event:MouseEvent):void
{
	
	//初始化系统是否被点击状态,这里用于模块下拉菜单加载使用
	isSystemBeClicked = false;
	if(!isSelect()){
		popUpSelect();
		return;
	}else{
		
		var item:Object = mainGrid.selectedItem;
		userApply = item;
		if(item==null)
			TAlert.show("请选择要修改的数据！", "温馨提示");
		else{
			
			if(userApply != null && userApply.applyId > 0){
				handle_server_method("bugManagerAPI","BugManagerAPI","getPersonIdByApplyId",
					[userApply.applyId],afterGetPersonId4modHandle);
			}else{
				TAlert.show("系统繁忙,稍后再试!","温馨提示");
			}
		}
	}
	
}

//未提交"状态不能修改
private function judgeEnableMod():Boolean{
	if(mainGrid.selectedItem.applyStatus > 0){
		TAlert.show("限于\"未提交\"可修改!","温馨提示");
		return false;
	}
	return true;
}

//修改的回调函数
private function afterGetPersonId4modHandle(event:ResultEvent):void{
	
	
	var obj:Object = getResultObj(event);
	var persons:ArrayCollection;
	
	if(!judgeEnableMod())
		return;
	
	if(obj != "0" ){
		persons = (obj as ArrayCollection).getItemAt(0) as ArrayCollection;
		if(persons != null && persons.length > 0){
			if(persons.getItemAt(0) == FAppCore.FCusUser.UserId
				|| persons.getItemAt(1) == FAppCore.FCusUser.UserId){
				
				//修改
				userApplyID = mainGrid.selectedItem.applyId;
				applyID4Word = userApplyID.toString();
				
				handle_server_method("bugManagerAPI","BugManagerAPI","showUserApllyByID",
					[userApplyID], function(event:ResultEvent):void{
						userApply = getResultObj(event) != 0 ? getResultObj(event) : null;
						applyID4Word = ""+userApplyID;
						
						//如果说请求单的状态为"未提交"则显示激活"呈报"按钮并且将"保存"按钮置灰
						viewPutBtn = userApply != null && userApply.applyStatus == 0;
						enablePutBtn = viewPutBtn;
						
						company = userApply != null ? userApply.company : '';
						dept = userApply != null ? userApply.department : '';
						
					});
				
				this.currentState = "mod";
				
			}else{
				TAlert.show("请联系填单人或报告人!","温馨提示");
			}
		}else{
			TAlert.show("系统繁忙,稍后再试!","温馨提示");
		}
	}else{
		TAlert.show("系统繁忙,稍后再试!","温馨提示");
	}
	
}

//=====================下拉列表的初始化=======================

//点击问题来源下拉列表时调用==========重要程度
//点击bug来源下拉列表时调用==========重要程度
protected function bugUrgent_clickHandler(event:MouseEvent):void
{
	//先查看levels是否为null，为null再向服务器请求数据
	if(levels == null){
		handle_server_method("bugManagerAPI","BugManagerAPI","initLevels",
			[], bugUrgent_clickHandle);
	}else if(this.currentState=="problem" || this.currentState=="bug" || this.currentState=="demand"){
		bugUrgent.dataProvider = levels;
	}else{
		bugUrgentQ.dataProvider = levels;
	}
	
	//由于界面值有修改,so--将呈报按钮置灰,保存按钮激活
	enablePutBtn = false;
}

//点击问题来源下拉列表后从后台传入的数据的处理
//点击bug来源下拉列表后从后台传入的数据的处理
private function bugUrgent_clickHandle(event:ResultEvent):void{
	levels = getResultObj(event) as ArrayCollection;
	
	if(this.currentState == "problem" || this.currentState=="bug" || this.currentState == "demand"){
		bugUrgent.dataProvider = levels;
	}
	
	if(this.currentState=="mod"){
		bugUrgentQ.dataProvider = levels;
	}
	
	
}

//点击问题的作用范围下拉列表时调用==========作用范围
//点击bug的作用范围下拉列表时调用==========作用范围
protected function bugRange_clickHandler(event:MouseEvent):void
{
	//先查看bugScops是否为null，为null再向服务器请求数据
	if(bugScops == null){
		handle_server_method("bugManagerAPI","BugManagerAPI","initBugScope",
			[], bugRange_clickHandle);
	}else if(this.currentState == "problem" || this.currentState=="bug" || this.currentState == "demand"){
		bugRange.dataProvider = bugScops;
	}else{
		bugRangeQ.dataProvider = bugScops;
	}
	//由于界面值有修改,so--将呈报按钮置灰,保存按钮激活
	enablePutBtn = false;
}

//点击问题的作用范围下拉列表后从后台传入的数据的处理
//点击bug的作用范围下拉列表后从后台传入的数据的处理
private function bugRange_clickHandle(event:ResultEvent):void{
	bugScops = getResultObj(event) as ArrayCollection;
	
	if(this.currentState == "problem" || this.currentState=="bug" || this.currentState == "demand"){
		bugRange.dataProvider = bugScops;
	}
	
	if(this.currentState=="mod"){
		bugRangeQ.dataProvider = bugScops;
	}
	
}

//点击修改界面的所属模块下拉列表时调用==========所属模块
//protected function bugModule_clickHandler(event:MouseEvent):void
//{
//	var sysid:uint;
//	
//	if(this.currentState=="problem" || this.currentState=="bug" || this.currentState=="demand"){
//		
//		if(userApply == null || isSystemBeClicked){
//			sysid = bugSystem.selectedItem != null 
//				? bugSystem.selectedItem.systemID : -1;
//		}else
//			sysid = userApply.belongSystem.systemID;
//		if(modules == null || modules.getItemAt(0).systemID != sysid)
//			handle_server_method("bugManagerAPI","BugManagerAPI","initSystemModules",
//				[sysid], bugModule_clickHandle);
//		else
//			bugModule.dataProvider = modules;
//	}
//	
//	if(this.currentState=="mod"){
//		
//		if(userApply == null || isSystemBeClicked){
//			sysid = bugSystemQ.selectedItem != null 
//				? bugSystemQ.selectedItem.systemID : -1;
//		}else
//			sysid = userApply.belongSystem.systemID;
//		if(modules == null || modules.getItemAt(0).systemID != sysid)
//			handle_server_method("bugManagerAPI","BugManagerAPI","initSystemModules",
//				[sysid], bugModule_clickHandle);
//		else
//			bugModuleQ.dataProvider = modules;
//	}
//	
//	//由于界面值有修改,so--将呈报按钮置灰,保存按钮激活
//	enablePutBtn = false;
//}

////点击修改界面的所属模块下拉列表后从后台传入的数据的处理
//private function bugModule_clickHandle(event:ResultEvent):void{
//	var obj:Object = getResultObj(event);
//	
//	modules = obj as ArrayCollection;
//	
//	if(this.currentState=="problem" || this.currentState=="bug" || this.currentState=="demand"){
//		bugModule.dataProvider = modules;
//	}
//	
//	if(this.currentState=="mod"){
//		bugModuleQ.dataProvider = modules;
//	}
//	
//}


//点击问题的所属系统下拉列表时调用==========所属系统
//点击bug的所属系统下拉列表时调用==========所属系统
//protected function bugSystem_clickHandler(event:MouseEvent):void
//{
//	
//	//系统下拉被点击标志
//	isSystemBeClicked = true;
//	//由于界面值有修改,so--将呈报按钮置灰,保存按钮激活
//	enablePutBtn = false;
//	//先查看systems是否为null，为null再向服务器请求数据
//	var sysid:uint;
//	var flag:Boolean;
//	
//	if(systems == null){
//		handle_server_method("bugManagerAPI","BugManagerAPI","initSupportSystems",
//			[], bugSystem_clickHandle);
//	}else if(this.currentState=="problem" || this.currentState=="bug" || this.currentState=="demand"){
//			sysid= bugSystem.selectedItem.systemID;
//			bugSystem.dataProvider = systems;
//			if(bugSystem.selectedIndex == 0){
//			modules = systems.getItemAt(0).systemModules as ArrayCollection;
//			bugModule.dataProvider = modules;
//		}else{
//			flag = false;
//			if(modules != null){
//				if(modules.getItemAt(0).systemID == sysid)
//					bugModule.dataProvider = modules;
//				else
//					flag = true;
//			}else
//				flag = true;
//			if(flag)
//				handle_server_method("bugManagerAPI","BugManagerAPI","initSystemModules",
//					[sysid], bugModule_clickHandle);
//		}
//		
//	}else{
//		sysid = bugSystemQ.selectedItem.systemID;
//		bugSystemQ.dataProvider = systems;
//		if(bugSystemQ.selectedIndex == 0){
//			modules = systems.getItemAt(0).systemModules as ArrayCollection;
//			bugModuleQ.dataProvider = modules;
//		}else{
//			flag= false;
//			if(modules != null){
//				if(modules.getItemAt(0).systemID == sysid)
//					bugModuleQ.dataProvider = modules;
//				else
//					flag = true;
//			}else
//				flag = true;
//			if(flag)
//				handle_server_method("bugManagerAPI","BugManagerAPI","initSystemModules",
//					[sysid], bugModule_clickHandle);
//		}
//	}
//}

//点击问题的所属系统下拉列表后从后台传入的数据的处理
//点击bug的所属系统下拉列表后从后台传入的数据的处理
//private function bugSystem_clickHandle(event:ResultEvent):void{
//	systems = getResultObj(event) as ArrayCollection;
//	modules = systems.getItemAt(0) as ArrayCollection;
//	
//	if(this.currentState=="problem" || this.currentState == "bug" || this.currentState=="demand"){
//		bugSystem.dataProvider = systems;
//		bugModule.dataProvider = modules;
//	}
//	
//	if(this.currentState == "mod"){
//		bugSystemQ.dataProvider = systems;
//		bugModuleQ.dataProvider = modules;
//	}
//	
//}

/**
 * 新增 
 * 
 * */
protected function addBtn_clickHandler(event:MouseEvent):void
{
	
	this.currentState = "add";
	
	
	userApply = null;
	selectUser = null;
	
	company = "";
	dept = "";
	telephoneInput.text="";
	userApplyID = 0;
	idFlag.text = "";
	applyID4Word = "";
	//清除nomal状态下的验证提示信息
	
	telephoneInput.errorString="";
	
	removeInfo();
	selectType.selectedIndex=-1;
	
	if(list == null){
		handle_server_method("bugManagerAPI","BugManagerAPI","initDropDownList4AddPage",
			[], addBtn_clickHandle);
	}
}

//点击首页的新增按钮后，会从数据库中查询出bug来源、bug作用范围、所属系统、所属业务模块、实际作用范围的列表
//该方法的作用就是处理这些数据，并将数据绑定到对应的变量上
public function addBtn_clickHandle(event:ResultEvent):void{
	//后台传来数据的暂存
	list = getResultObj(event) as ArrayCollection;
	//分类存储
	//来源
	bugSources = list.getItemAt(1) as ArrayCollection;
	//作用范围
	bugScops = list.getItemAt(0) as ArrayCollection;
	//系统
	systems = list.getItemAt(3) as ArrayCollection;
	//第一个系统的业务模块
	modules = systems.getItemAt(0).systemModules as ArrayCollection;
	//实际作用范围
	realBugScops = bugScops;
	//重要程度
	levels = list.getItemAt(2) as ArrayCollection;
}


//所属系统更改时调用
protected function bugSystem_changeHandler(event:Event):void
{
	var sysID:int ;
	
	if(this.currentState=="problem" || this.currentState=="bug" || this.currentState=="demand"){
		bugModule.selectObj = "";
		bugModule.sText = "";
		systemID = bugSystem.selectObj.hasOwnProperty("systemID")
			?bugSystem.selectObj.systemID:(bugSystem.sText != "" 
				&& bugSystem.sText != null)
			?userApply.hasOwnProperty("belongSystem")
			?userApply.belongSystem.systemID:-1:-1;
	}
	
	if(this.currentState=="mod"){
		bugModuleQ.selectObj = "";
		bugModuleQ.sText = "";
		systemID = bugSystemQ.selectObj.hasOwnProperty("systemID")
			?bugSystemQ.selectObj.systemID:(bugSystemQ.sText != "" 
				&& bugSystemQ.sText != null)
			?userApply.hasOwnProperty("belongSystem")
			?userApply.belongSystem.systemID:-1:-1;
	}
	
//	handle_server_method("bugManagerAPI","BugManagerAPI","initSystemModules",
//		[sysID], bugSystem_changeHandle);
}

//private function bugSystem_changeHandle(event:ResultEvent):void{
//	
//	//由于界面值有修改,so--将呈报按钮置灰,保存按钮激活
//	enablePutBtn = false;
//	modules = getResultObj(event) as ArrayCollection;
//	
//	if(this.currentState=="problem" || this.currentState=="bug" || this.currentState=="demand"){
//		bugModule.dataProvider = modules;
//	}
//	
//	if(this.currentState=="mod"){
//		bugModuleQ.dataProvider = modules;
//	}
//	
//}


/**
 * 删除
 * 
 * */
private function delApplypopWarn(event:MouseEvent):void{
	var item:Object = mainGrid.selectedItem;
	userApply = item;
	if(isSelect()){
		if(userApply.applyStatusStr != "未提交"){
			TAlert.show("仅限于“未提交”的数据！","温馨提示");
		}else{
			if(item != null && item.applyId > 0){
				handle_server_method("bugManagerAPI","BugManagerAPI","getPersonIdByApplyId",
					[item.applyId],afterGetPersonIdHandle);
			}else{
				TAlert.show("系统繁忙,稍后再试!","温馨提示");
			}
		}
	}else{
		popUpSelect();
	}
}

private function afterGetPersonIdHandle(event:ResultEvent):void{
	var obj:Object = getResultObj(event);
	var persons:ArrayCollection;
	if(obj != "0" ){
		persons = (obj as ArrayCollection).getItemAt(0) as ArrayCollection;
		if(persons != null && persons.length > 0){
			if(persons.getItemAt(0) == FAppCore.FCusUser.UserId
				|| persons.getItemAt(1) == FAppCore.FCusUser.UserId){
				popWwarn(delApplyProcess);
			}else{
				TAlert.show("请联系填单人或报告人!","温馨提示");
			}
		}else{
			TAlert.show("系统繁忙,稍后再试!","温馨提示");
		}
	}else{
		TAlert.show("系统繁忙,稍后再试!","温馨提示");
	}
}

//弹出确认按钮panel
private function popWwarn(method:Function):void{
	TAlert.show("您确认删除吗？","删除",TAlert.OK|TAlert.NO,this,method,null,TAlert.YES);
}

//删除请求单调用
private function delApplyProcess(event:CloseEvent):void{
	idFlag.text = mainGrid.selectedItem.applyId;
	if(event.detail == TAlert.OK)
		handle_server_method("bugManagerAPI","BugManagerAPI","delUserApplyById",
			[idFlag.text],afterDelApplyHandle);
}

//执行删除后调用
private function afterDelApplyHandle(event:ResultEvent):void{
	appCore = AppCore.getInstance();
	var result:String = event.result as String;
	if(result == "1"){
		//					TAlert.show("服务器处理成功！");
		
		//更新表格数据
		mainGridArray = ['bugManagerAPI', 'BugManagerAPI', 'uServiceHomePageFast',[appCore.loginUser.id]];
	}
	
}

/**
 * 呈报
 * 
 * */

/**呈报按钮点击后将*/
protected function putBtn_clickHandler(event:MouseEvent):void
{
	var item:Object = mainGrid.selectedItem;
	userApply = item;
	//处理报告时间
	//格式化报告时间
	var df:DateFormatter = new DateFormatter();
	df.formatString="YYYY-MM-DD";
	//系统生成报告时间--即当天提交的时间
	apply.applyStartDate=df.format(reportTime);
	
	trace("呈报的类型：");
	trace(userApply.applyType);
	
	if(item==null)
		TAlert.show("请选择要呈报的数据！", "温馨提示");
	else{
		if(userApply.applyStatusStr != "未提交"){
			TAlert.show("呈报仅限于“未提交”的数据！","温馨提示");
		}else{
			if(userApply != null && userApply.applyId > 0){
				handle_server_method("bugManagerAPI","BugManagerAPI","getPersonIdByApplyId",
					[userApply.applyId],afterGetPersonId4putHandle);
			}else{
				TAlert.show("系统繁忙,稍后再试!","温馨提示");
			}	
		}
	}
}

private function afterGetPersonId4putHandle(event:ResultEvent):void{
	
	var obj:Object = getResultObj(event);
	var persons:ArrayCollection;
	if(obj != "0" ){
		persons = (obj as ArrayCollection).getItemAt(0) as ArrayCollection;
		if(persons != null && persons.length > 0){
			if(persons.getItemAt(0) == FAppCore.FCusUser.UserId
				|| persons.getItemAt(1) == FAppCore.FCusUser.UserId){
				
				//呈报的具体业务处理
				var arr:Array = new  Array();
				var Oitem:String= "department:"+FAppCore.FCusUser.DeptId;
				arr.push(Oitem);
				
				putObj = userApply;
				//if (item.flowState == 138) FISAfterFlowCommit = true;
				var sender:Object = new Object();
				sender.id=FAppCore.FCusUser.UserId;
				sender.personName=FAppCore.FCusUser.UserName;
				//		fAppCore.StartFlowInstence(sender, item.applyEntry.id, FLOW_TYPE, item.applyId, arr, FISAfterFlowCommit, putBtn_clickHandle);
				FAppCore.StartFlowInstence(sender, sender.id, userApply.applyType, userApply.applyId, arr, FISAfterFlowCommit, putBtn_clickHandle);
				
			}else{
				TAlert.show("请联系填单人或报告人!","温馨提示");
			}
		}else{
			TAlert.show("系统繁忙,稍后再试!","温馨提示");
		}
	}else{
		TAlert.show("系统繁忙,稍后再试!","温馨提示");
	}
	
}

private function putBtn_clickHandle(event:ResultEvent):void{
	
	//修改数据库请求单的状态
	//请求状态：0—未提交，1—未受理，2—处理中，3—完成
	putObj.applyStatus = 1;
	putObj.applyStatusStr = "未受理";
	
	handle_server_method("bugManagerAPI","BugManagerAPI","updateUerApplyStatus",
		[putObj.applyId, putObj.applyStatus], after_putBtn_clickHandle);
	
}

/**
 * 处理呈报对象的时间
 */
private function dateOfPutObjFormat(putObj:Object):void{
	
	//期望解决时间
	putObj.applyEndDate = putObj.applyEndDate != null && putObj.applyEndDate != ""
		? formateDate(putObj.applyEndDate) : "";
	
	//请求发起时间
	putObj.applyStartDate = putObj.applyStartDate != null && putObj.applyStartDate != ""
		? formateDate(putObj.applyStartDate) : "";
	
	//计划解决时间
	putObj.planFinishTime = putObj.planFinishTime != null && putObj.planFinishTime != ""
		? formateDate(putObj.planFinishTime) : "";
	
	//响应时间
	putObj.replyTime = putObj.replyTime != null && putObj.replyTime != ""
		? formateDate(putObj.replyTime) : "";
	
	//实际解决时间
	putObj.realFinishTime = putObj.realFinishTime != null && putObj.realFinishTime != ""
		? formateDate(putObj.realFinishTime) : "";
	
	//所属系统的上线时间
	putObj.belongSystem.onlineDate = putObj.belongSystem.onlineDate != null 
		&& putObj.belongSystem.onlineDate != ""
		? formateDate(putObj.belongSystem.onlineDate) : "";
}

private function after_putBtn_clickHandle(event:ResultEvent):void{
	//更新主页表格
	var obj:Object = getResultObj(event);
	if(obj != 0){
		obj.applyStatusStr = obj.applyStatus ==1 ? "未受理" : "未提交";
		(mainGrid.dataProvider as ArrayCollection).setItemAt(obj,mainGrid.selectedIndex);
		this.currentState = "normal";
	}else
		putBtn_clickHandle(null);
}



/**
 * 查询
 * 
 * 查询按钮事件,在此处需要传送一些列数据给弹窗的下拉菜单,以便实现初始化
 */ 
public function btnSearch_clickHandler(event:MouseEvent):void{
	
	var popWin:PopSearchUserApply = PopSearchUserApply(PopUpManager.createPopUp(this,PopSearchUserApply,true));
	
	//状态---请求状态：0—未提交，1—未受理，2—处理中，3—完成
	popWin.statusLst = 
		new ArrayCollection(
			[{"id":0,"describe":"未提交"},{"id":1,"describe":"未受理"},
				{"id":2,"describe":"处理中"},{"id":3,"describe":"完成"}]);
	popWin.ranges = bugScops;
	popWin.degrees = levels;
	popWin.systems = systems;
	popWin.userID = appCore.loginUser.id;
	//popWin.flag = FLAG;
	popWin.userID = appCore.loginUser.id;
	
	popWin.mainApp = this;
	
	PopUpManager.centerPopUp(popWin);
	
}

/**
 * 刷新点击后,初始化主页表格
 * 
 * */
protected function refreshBtn_clickHandler(event:MouseEvent):void
{
	appCore = AppCore.getInstance();
	//主页表格数据初始化
	mainGridArray = ['bugManagerAPI', 'BugManagerAPI', 'uServiceHomePageFast',[appCore.loginUser.id]];
}

//================首页各个按钮的事件：查看、修改、新增、删除、呈报、查询、刷新===================

//========================修改和新增状态下的按钮事件：的保存、取消、呈报=========================
/**
 * 
 * 点击修改、新增状态下的保存调用到的方法
 * 
 * */
protected function saveBtn_clickHandler(event:MouseEvent):void
{
	if(validate()){
		
		if(this.currentState == "problem"){		
			handle_server_method("bugManagerAPI","BugManagerAPI","addUProblemApply",
				[appCore.jsonEncoder.encode(storeSimpleValue2userApply())], saveBtn_clickHandle);
		}
		
		if(this.currentState=="bug"){
			handle_server_method("bugManagerAPI","BugManagerAPI","addUBugApply",
				[appCore.jsonEncoder.encode(storeSimpleValue2userApply())], saveBtn_clickHandle);
		}
		
		if(this.currentState=="demand"){
			handle_server_method("bugManagerAPI","BugManagerAPI","addUDemandApply",
				[appCore.jsonEncoder.encode(storeSimpleValue2userApply())], saveBtn_clickHandle);
		}
		
		if(this.currentState=="mod"){
			handle_server_method("bugManagerAPI","BugManagerAPI","updateBugUerApplyAdd",
				[appCore.jsonEncoder.encode(storeSimpleValue2userApply())], saveBtn_clickHandle);	
		}
		
	}
}

//将界面中的用户修改的值存入对象之中
private function storeSimpleValue2userApply():Object{
	
	var obj:Object = new Object();
	//请求单填写者
	var applyEntry:Object = new Object();
	//提出请求的具体用户-报告人
	var sponsor:Object = new Object();
	
	//存放各个下拉列表的属性
	var urgent:ReplyLevelVO = new ReplyLevelVO();
	var range:ConstDetailVO = new ConstDetailVO();
	var system:SupportSystemVO = new SupportSystemVO();
	var module:SystemModuleVO = new SystemModuleVO();
	var origin:ConstDetailVO = new ConstDetailVO();
	//==========================================
	if(this.currentState=="mod"){
		//对象处理:问题模块,问题系统,问题影响范围,问题实际影响范围,问题重要程度,请求单状态
		module.moduleID = bugModuleQ.selectObj.hasOwnProperty("moduleID")
			?bugModuleQ.selectObj.moduleID:bugModuleQ.sText != ""
			?userApply.sysModule.moduleID:"-1";
		obj.sysModule = module;
		
		system.systemID = bugSystemQ.selectObj.hasOwnProperty("systemID")
			?bugSystemQ.selectObj.systemID:bugSystemQ.sText != ""
			?userApply.belongSystem.systemID:-1;
		obj.belongSystem = system;
		
//		if(bugModuleQ.selectedItem != null)
//			module.moduleID = bugModuleQ.selectedItem.moduleID;
//		obj.sysModule = module;
//		
//		if(bugSystemQ.selectedItem != null)
//			system.systemID = bugSystemQ.selectedItem.systemID;
//		obj.belongSystem = system;
		
		if(bugRangeQ.selectedItem != null)
			range.id = bugRangeQ.selectedItem.id;
		obj.range = range;
		
		if(bugUrgentQ.selectedItem != null)
			urgent.replyLevelId = bugUrgentQ.selectedItem.replyLevelId;
		obj.urgent = urgent;
		
		//问题模块的主题摘要
		obj.applyTitle = applyTitleInputQ.text;
		//问题模块的问题描述
		obj.directions = directionsAreaQ!=null?BugUtil.myTrim(directionsAreaQ.text):"";
		
		//联系电话
		obj.telephone = telephoneInputQ.text;
		
		
		if(userApply != null){
			obj.applyType = userApply.applyType;
			obj.DR = userApply.DR;
			obj.applyStatus = userApply.applyStatus;
			obj.applyId = userApply.applyId;
		}else{
			TAlert.show("系统繁忙,稍后再试!","温馨提示");
		}
		
		//联系电话
		obj.telephone = telephoneInputQ.text;
		
		//请求id
		applyEntry.id = appCore.loginUser.id;
		applyEntry.personId = appCore.loginUser.msPerson.id;
		applyEntry.companyID = appCore.loginUser.companyId;
		obj.applyEntry = applyEntry;
		
		//时间处理
		applyDateHandle(obj);
		
		//公司与部门
		obj.company = FAppCore.FCusUser.DeptName;
//		obj.department = appCore.loginUser.department;
		
		//用户请求单编号
		obj.userApplyCode = userApply != null ? 
			userApply.userApplyCode : null;
	}else{
		
		if(this.currentState=="problem" || this.currentState=="bug" || this.currentState=="demand"){
			if(this.currentState=="problem"){
				FLOW_TYPE="1";	
			}else if(this.currentState == "bug"){
				FLOW_TYPE="2";
			}else if(this.currentState=="demand"){
				obj.applyReason = reasonArea!=null?BugUtil.myTrim(reasonArea.text):"";
				FLOW_TYPE="3";
			}
			
			//对象处理:bug模块,bug系统,bug影响范围,bug实际影响范围,bug重要程度,请求单状态
			
			module.moduleID = bugModule.selectObj.hasOwnProperty("moduleID")
				?bugModule.selectObj.moduleID:bugModule.sText != ""
				?userApply.sysModule.moduleID:"-1";
			obj.sysModule = module;
			
			system.systemID = bugSystem.selectObj.hasOwnProperty("systemID")
				?bugSystem.selectObj.systemID:bugSystem.sText != ""
				?userApply.belongSystem.systemID:-1;
			obj.belongSystem = system;
			
//			if(bugModule.selectedItem != null)
//				module.moduleID = bugModule.selectedItem.moduleID;
//			obj.sysModule = module;
//			
//			
//			if(bugSystem.selectedItem != null)
//				system.systemID = bugSystem.selectedItem.systemID;
//			obj.belongSystem = system;
			
			if(bugRange.selectedItem != null)
				range.id = bugRange.selectedItem.id;
			obj.range = range;
			
			if(bugUrgent.selectedItem != null)
				urgent.replyLevelId = bugUrgent.selectedItem.replyLevelId;
			obj.urgent = urgent;
			
			//联系电话
			obj.telephone = telephoneInput.text;
			
			//bug模块的主题摘要
			obj.applyTitle = applyTitleInput.text;
			//bug模块的问题描述
			obj.directions = directionsArea!=null?BugUtil.myTrim(directionsArea.text):"";
			
			//时间处理
			applyDateHandle(obj);
			
			//公司与部门
			obj.department = FAppCore.FCusUser.DeptName;
//			obj.department = userApply != null ? userApply.department : '';
			
			//用户请求单编号
			obj.userApplyCode = userApply != null ? 
				userApply.userApplyCode : null;
		}
		
	}
	
	
	
	obj.applyType = FLOW_TYPE;
	obj.applyStatus = 0;
	obj.DR = 0;
	
	//请求id
	applyEntry.id = appCore.loginUser.id;
	applyEntry.personId = appCore.loginUser.msPerson.id;
	applyEntry.companyID = appCore.loginUser.companyId;
	obj.applyEntry = applyEntry;
	
	//报告人
	sponsor.id = appCore.loginUser.id;
	obj.sponsor = sponsor;
	
	return obj;
}

//日期格式处理
private function applyDateHandle(apply:Object):void{
	
	//格式化报告时间
	var df:DateFormatter = new DateFormatter();
	df.formatString="YYYY-MM-DD";
	//系统生成报告时间--即当天提交的时间
//	apply.applyStartDate=df.format(reportTime);
	
	if(this.currentState=="problem" || this.currentState=="bug" || this.currentState=="demand"){
		//期望解决时间
		if(applyEndDate.selectedDate != null && applyEndDate.text != "")
			apply.applyEndDate = df.format(applyEndDate.selectedDate);
		else
			apply.applyEndDate = StringUtil.trim(applyEndDate.text);
	}
	
	if(this.currentState=="mod"){
		//期望解决时间
		if(applyEndDateQ.selectedDate != null && applyEndDateQ.text != "")
			apply.applyEndDate = df.format(applyEndDateQ.selectedDate);
		else
			apply.applyEndDate = 
				StringUtil.trim(applyEndDateQ.text);
	}
	
}


//保存请求单的回调函数
private function saveBtn_clickHandle(event:ResultEvent):void{
	
	var json:String = event.result as String;
	var obj:Object = JSON.parse(json) as Object;
	var applyIDNow:Number = 0;
	
	if(this.currentState == "mod"){
		if(obj == "0"){
			TAlert.show("系统繁忙，请稍后再试！","温馨提示");
			return;
		}else if(obj == "1")
			//呈报按钮激活,保存按钮置灰
			enablePutBtn = true;
	}else{
		if(obj.type>=1) {
			if(obj.type > 1)
				applyIDNow = Number(obj.type);
			
			if(this.currentState=="problem" || this.currentState=="bug" || this.currentState=="demand"){
				fileGrid.saveDgToDb(Number(obj.type).toString(), applyTableName);
				fileGrid.reSetData();
			}
			
		}
		else if(obj.type==-2){
			TAlert.show("保存失败！", "系统提示");
			return;
		}
		else if(obj.type==-1){
			TAlert.show("后台异常！", "系统提示");
			return;
		}
		else if(obj.type==0){
			TAlert.show("请建Model！", "系统提示");
			return;
		}
	}
	//更新主页表格
	refreshMainGridAfterAddOrMod(applyIDNow);
	//由于修改页面有呈报按钮,所以呈报后跳转页面
	if(!enablePutBtn)
	this.currentState = "normal";
}




/**
 * 点击同胞状态下的取消按钮时
 * 
 * */
private function backToHomePage(event:Event):void{
	
	this.currentState="normal";
	
	//主页表格数据初始化
	mainGridArray = ['bugManagerAPI', 'BugManagerAPI', 'uServiceHomePageFast',[appCore.loginUser.id]];
}


/**更新主页表格*/
private function refreshMainGridAfterAddOrMod(applyIDNow:Number):void{
	
	
	//更新表格数据
	appCore = AppCore.getInstance();
	mainGridArray = ['bugManagerAPI', 'BugManagerAPI', 'uServiceHomePageFast',[appCore.loginUser.id]];
	
	/*var flagStr:String = "mod";
	if(this.currentState == "add"){
		if(SORT_FLAG){
			flagStr = "add";
			if(mainGrid.curPage == mainGrid.totalPage 
				&& (mainGrid.dataProvider as ArrayCollection).length < mainGrid.pageCount)
				handle_server_method("bugManagerAPI","BugManagerAPI","showUserApllyByID",
					[applyIDNow], addUserApllyAfterHandle);
			else
				mainGridArray = ['bugManagerAPI', 'BugManagerAPI', 'uServiceHomePageFast', [],flagStr];
		}else
			//更新表格数据
			mainGridArray = ['bugManagerAPI', 'BugManagerAPI', 'uServiceHomePageFast', []];
	}else{
		handle_server_method("bugManagerAPI","BugManagerAPI","showUserApllyByID",
			[userApplyID], modUserApllyAfterHandle);
	}*/
	
}

/**
 * 如果当前页码为最后一页,并且表格未满,就直接向表格追加用户刚刚插入的数据
 */
private function addUserApllyAfterHandle(event:ResultEvent):void{
	var obj:Object = getResultObj(event);
	(mainGrid.dataProvider as ArrayCollection).addItem(obj);
	mainGrid.totalCount = mainGrid.totalCount+1;
}

/**
 * 将从后台查询到的一条更新请求记录存入主页表格选择的数据位置处
 * 此函数主要是为了减少对数据库的分页查询
 */ 
private function modUserApllyAfterHandle(event:ResultEvent):void{
	var obj:Object = getResultObj(event);
	(mainGrid.dataProvider as ArrayCollection).setItemAt(obj,mainGrid.selectedIndex);
}



//将界面中的用户修改的值存入userApply对象之中
private function storeValue2userApply():UserApplyVO{
	
	apply = new UserApplyVO();
	
	
	//对象处理:bug系统,bug影响范围,bug实际影响范围,bug重要程度,请求单状态
	var module:SystemModuleVO = new SystemModuleVO();
	module.moduleID = bugModule.selectObj.hasOwnProperty("moduleID")
		?bugModule.selectObj.moduleID:bugModule.sText != ""
		?userApply.sysModule.moduleID:"-1";
	apply.sysModule = module;
	
	var system:SupportSystemVO = new SupportSystemVO();
	system.systemID = bugSystem.selectObj.hasOwnProperty("systemID")
		?bugSystem.selectObj.systemID:bugSystem.sText != ""
		?userApply.belongSystem.systemID:-1;
	apply.belongSystem = system;
	
//	var module:SystemModuleVO = new SystemModuleVO();
//	if(bugModule.selectedItem != null)
//		module.moduleID = bugModule.selectedItem.moduleID;
//	apply.sysModule = module;
//	
//	var system:SupportSystemVO = new SupportSystemVO();
//	if(bugSystem.selectedItem != null)
//		system.systemID = bugSystem.selectedItem.systemID;
//	apply.belongSystem = system;
	
	var range:ConstDetailVO = new ConstDetailVO();
	if(bugRange.selectedItem != null)
		range.id = bugRange.selectedItem.id;
	apply.range = range;
	
	//var realRange:ConstDetailVO = new ConstDetailVO();
	//if(bugRealRange.selectedItem != null)
		//realRange.id = bugRealRange.selectedItem.id;
	//apply.realRange = realRange;
	
	var urgent:ReplyLevelVO = new ReplyLevelVO();
	if(bugUrgent.selectedItem != null)
		urgent.replyLevelId = bugUrgent.selectedItem.replyLevelId;
	apply.urgent = urgent;
	
	//这里的状态在具体的业务中会有不同的处理,比如说:呈报
	//请求状态：0—未提交，1—未受理，2—处理中，3—完成
	var statusID:uint = 0;
	if(this.currentState == "mod")
		apply.applyStatus = userApply != null?userApply.applyStatus:statusID;
	else
		apply.applyStatus = statusID;
	
	
	//可以确定：主题摘要、电话、请求单id
	apply.applyTitle = applyTitleInput.text;
	apply.telephone = telephoneInput.text;
	apply.applyId = Number(idFlag.text);
	
	
	
	//请求单填写者
	var applyEntry:Object = new Object();
	applyEntry.id = appCore.loginUser.id;
	applyEntry.personId = appCore.loginUser.msPerson.id;
	applyEntry.companyID = appCore.loginUser.companyId;
	apply.applyEntry = applyEntry;
	
	
	//提出请求的具体用户
	var sponsor:Object = new Object();
	
	sponsor.id = appCore.loginUser.id;
	apply.sponsor = sponsor;
	
	
	//公司与部门
	apply.company = appCore.loginUser.company;
	apply.department = appCore.loginUser.department;
	
	
	//用户请求单编号
	if(idFlag.text == ""){
		apply.userApplyCode = codeStr;
	}else
		apply.userApplyCode = userApply.userApplyCode;
	
	//时间处理
	applyDateHandle(apply);
	
	//文本框
	//apply.reason = reasonArea != null?BugUtil.myTrim(reasonArea.text):"";
	apply.directions = directionsArea!=null?BugUtil.myTrim(directionsArea.text):"";
	//apply.solutions = solutionsArea!=null?BugUtil.myTrim(solutionsArea.text):"";
	
	if(userApply != null){
		apply.applyType = userApply.applyType;
		apply.DR = userApply.DR;
	}
	
	return apply;
}



//========================修改和新增状态下的按钮事件：的保存、取消、呈报=========================

/**项选中事件:弹出或隐藏审批历史*/
protected function b_mainGrid_itemClickHandler(event:ListEvent):void
{
	
	subDemandObj = b_mainGrid.selectedItem;
	subDemandID = subDemandObj != null ? subDemandObj.userDemandId : "";
	if(flow_index != b_mainGrid.selectedIndex && b_mainGrid.selectedIndex > -1
		&& subDemandObj.demandStatus > 0){
		
		flow_index = b_mainGrid.selectedIndex;
		
		if(subDemandObj!=null){// && obj.flowId!=null
			b_AppHistoryGrid.getApproveHistory(US_FLOW_TYPE, subDemandObj.userDemandId);
		}
		
		b_AppHistoryGrid.visible = true;
		b_AppHistoryGrid.includeInLayout = true;
		
	}else{
		
		b_hideFlowHistory();
		if(subDemandObj.demandStatus > 0){
			b_mainGrid.selectedIndex = -1;
		}
	}
}

/**项选中事件:弹出或隐藏审批历史*/
protected function mainGrid_itemClickHandler(event:ListEvent):void
{
	userApply = mainGrid.selectedItem;
	
	if(userApply.applyType == 3){
		brotherBtn.visible = true;
	}else{
		brotherBtn.visible = false;
	}
	
	if(flow_index != mainGrid.selectedIndex && mainGrid.selectedIndex > -1
		&& userApply.applyStatus > 0){
		
		flow_index = mainGrid.selectedIndex;
		
		if(userApply!=null){// && obj.flowId!=null
			AppHistoryGrid.getApproveHistory(userApply.applyType, userApply.applyId);
		}
		
		AppHistoryGrid.visible = true;
		AppHistoryGrid.includeInLayout = true;
		
	}else{
		
		hideFlowHistory();
		if(userApply.applyStatus > 0){
			mainGrid.selectedIndex = -1;
		}
	}
}

/**隐藏流程审批历史表格图*/
private function b_hideFlowHistory():void{
	b_AppHistoryGrid.visible = false;
	b_AppHistoryGrid.includeInLayout = false;
	
	flow_index = -1;
}

/**隐藏流程审批历史表格图*/
private function hideFlowHistory():void{
	AppHistoryGrid.visible = false;
	AppHistoryGrid.includeInLayout = false;
	
	flow_index = -1;
}

/**预测用户操作:查看,修改等,隐藏审批历史*/
public function hgroup1_mouseOverHandler(event:MouseEvent):void
{
	hideFlowHistory();
}
