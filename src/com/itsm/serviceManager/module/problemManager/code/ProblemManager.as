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

import spark.components.List;
import spark.events.GridSelectionEvent;
import spark.events.IndexChangeEvent;

[Bindable]
private var now:Date = new Date();

private var appCore:AppCore;

//private var fAppCore:BugGlobalUtil = BugGlobalUtil.getInstence();
private var FAppCore:GlobalUtil = GlobalUtil.getInstence();

//2：代表查询bug
private static const FLAG:int = 1;

//一个请求单对象
[Bindable]
public var userApply:Object;

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

/**用户所选择的系统id*/
[Bindable]
public var systemID:int = -1;

//实际作用范围
[Bindable]
public var realBugScops:ArrayCollection;

//重要程度
[Bindable]
public var levels:ArrayCollection;

//主页表格数据集
[Bindable]
public var mainGridArray:Array = null;

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
private var reportTime:Date;

//流程模型类型
private static const FLOW_TYPE:String="1";

//呈报对象
[Bindable]
private var putObj:Object;

//记录主页表格弹起的是哪个流程的流程状态图
[Bindable]
private var flow_index:int = -1;

//排序方式:是否升序
private static const SORT_FLAG:Boolean = false;

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


//===============公共调用方法=============开始==========

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

//1、表格的初始化分页组件自带
//2、表格模糊查询->依据主题

/**
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
//	popWin.systems = systems;
	popWin.flag = FLAG;
	
	popWin.mainApp = this;
	
	PopUpManager.centerPopUp(popWin);
	
}

/**
 * 弹窗下拉菜单初始化
 */
private function initPopSearchUserApply():void{
	
	AppHistoryGrid.gridMain.OnlyInit();
	appCore = AppCore.getInstance();
	
	//主页表格数据初始化
	mainGridArray = ['bugManagerAPI', 'BugManagerAPI', 'initHomePageFast', [FLAG]];
	
//	//系统
//	if(!(systems != null))
//		handle_server_method("bugManagerAPI","BugManagerAPI","initSupportSystems",
//			[], function(event:ResultEvent):void{
//				systems = getResultObj(event) as ArrayCollection;
//			});
	
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
//3、删除

//点击bug管理界面首页的删除按钮触发
private function delApplypopWarn(event:MouseEvent):void{
	var item:Object = mainGrid.selectedItem;
	userApply = item;
	if(isSelect()){
		if(item != null && item.applyId > 0){
			if(item.applyStatus == 0)
				handle_server_method("bugManagerAPI","BugManagerAPI","getPersonIdByApplyId",
					[item.applyId],afterGetPersonIdHandle);
			else
				TAlert.show("限于“未提交”可删除!","温馨提示");
		}else{
			TAlert.show("系统繁忙,稍后再试!","温馨提示");
		}
	}else
		popUpSelect();
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
	var result:String = event.result as String;
	if(result == "1"){
		//					TAlert.show("服务器处理成功！");
		
		//更新表格数据
		mainGridArray = ['bugManagerAPI', 'BugManagerAPI', 'initHomePageFast', [FLAG]];
	}
	
}



//4、查看

//点击界面的查看按钮调用
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
					
					company = userApply != null ? userApply.company : '';
					dept = userApply != null ? userApply.department : '';
					
				});
			
			handle_server_method("bugManagerAPI","BugManagerAPI","getPersonIdByApplyId",
				[userApply.applyId],afterGetPersonId4queryHandle);
		}else{
			TAlert.show("系统繁忙,稍后再试!","温馨提示");
		}
	}
	
}

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
				else
					this.currentState = "query";
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
	
	// 标记表单有效的开始 
	formIsValid = applyStartDate.selectedDate <= new Date() &&
		applyEndDate.selectedDate >= applyStartDate.selectedDate;
	
	// 检查表单是否为空 
	formIsEmpty = telephoneInput.text == "" ||
		applyStartDate.text == "" ||
		applyEndDate.text == "" ||
		applyTitleInput.text == "" ||
		directionsArea.text == "" || 
		bugSystem.sText == "" || 
		bugSystem.sText == null || 
		bugModule.sText == null || 
		bugModule.sText == ""; 
	
	//运行每个验证器反过来,使用isValid() 
	//辅助方法和更新formIsValid的价值 
	//因此。 
	validateV(telephoneInputV); 
	validateV(applyStartDateV); 
	validateV(applyEndDateV); 
	validateV(applyTitleInputV); 
	validateV(directionsAreaV); 
	
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
	
	var info1:String = BugUtil.compareDate(applyStartDate.text, applyEndDate.text);
	if(info1 != "1"){
		formIsValid=false;
		if(info1 == "0")
			msg += "报告时间晚于期望解决时间!\n";
		else
			msg += info1;
	}else
		flag++;
	
	var info2:String = BugUtil.compareDate(applyStartDate.text, 
		DateField.dateToString(new Date(),"YYYY-MM-DD"));
	if(info2 != "1"){
		formIsValid=false;
		if(info2 == "0")
			msg += "报告时间晚于当前时间!\n";
		else
			msg += info2;
	}else
		flag++;
	
	if(!sponsorInput.selectObj.hasOwnProperty("userId")&&""==sponsorInput.sText){
		msg += "报告人未选择！\n";
		formIsValid=false;
	}else
		flag++;
	
	judgeFormIsEmpty();
	
	if(formIsEmpty){
		Alert.show("还有值域为空！","警告");
		formIsValid=false;
		return false;
	}
	
	if(flag == 3)
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
	formIsEmpty = telephoneInput.text == "" ||
		applyStartDate.text == "" ||
		applyEndDate.text == "" ||
		applyTitleInput.text == "" ||
		directionsArea.text == ""; 
}

/** 
 *  清除验证信息 重置功能 
 * */ 
private function clearFormHandler():void 
{ 
	// 清除所有的值 
	telephoneInput.text == "";
	applyStartDate.text == "";
	applyEndDate.text == "";
	applyTitleInput.text == "";
	directionsArea.text == ""; 
	
	// 清除错误信息 
	telephoneInput.errorString == "";
	applyStartDate.errorString == "";
	applyEndDate.errorString == "";
	applyTitleInput.errorString == "";
	directionsArea.errorString == ""; 
	
	// 标记为清空 
	formIsEmpty = true; 
	
	//				// 获取到焦点 
	//				resetFocus();                
} 

//点击保存调用到的方法
protected function saveBtn_clickHandler(event:MouseEvent):void
{
	if(validate()){
		
		if(this.currentState == "add"){
			//			var ac:ArrayCollection = new ArrayCollection();
			//			ac.addItem(storeValue2userApply());
			//			ac.addItem(fAppCore.FCusUser);
			
			//			handle_server_method("bugManagerAPI","BugManagerAPI","addBugUserApply",
			//				[JSON.stringify(ac.source)], saveBtn_clickHandle);
			handle_server_method("bugManagerAPI","BugManagerAPI","addProblemUserApply",
				[appCore.jsonEncoder.encode(storeSimpleValue2userApply())], saveBtn_clickHandle);
			return;
		}
		//updateBugUerApply
		handle_server_method("bugManagerAPI","BugManagerAPI","updateBugUerApplyAdd",
			[appCore.jsonEncoder.encode(storeSimpleValue2userApply())], saveBtn_clickHandle);	
	}
}

//将界面中的用户修改的值存入对象之中
private function storeSimpleValue2userApply():Object{
	
	var obj:Object = new Object();
	
	
	//对象处理:bug来源,bug模块,bug系统,bug影响范围,bug实际影响范围,bug重要程度,请求单状态
	var origin:ConstDetailVO = new ConstDetailVO();
	if(bugSource.selectedItem != null)
		origin.id = bugSource.selectedItem.id;
	obj.applyOrigin = origin;
	
	var module:SystemModuleVO = new SystemModuleVO();
	module.moduleID = bugModule.selectObj.hasOwnProperty("moduleID")
		?bugModule.selectObj.moduleID:bugModule.sText != "" 
		&& bugModule.sText != null 
		?userApply.sysModule.moduleID:"-1";
	obj.sysModule = module;
	
	var system:SupportSystemVO = new SupportSystemVO();
	system.systemID = bugSystem.selectObj.hasOwnProperty("systemID")
		?bugSystem.selectObj.systemID:bugSystem.sText != "" 
		&& bugSystem.sText != null 
		?userApply.belongSystem.systemID:-1;
	obj.belongSystem = system;
	
	var range:ConstDetailVO = new ConstDetailVO();
	if(bugRange.selectedItem != null)
		range.id = bugRange.selectedItem.id;
	obj.range = range;
	
	var urgent:ReplyLevelVO = new ReplyLevelVO();
	if(bugUrgent.selectedItem != null)
		urgent.replyLevelId = bugUrgent.selectedItem.replyLevelId;
	obj.urgent = urgent;
	
	
	//可以确定：主题摘要、电话、请求单id
	obj.applyTitle = applyTitleInput.text;
	obj.telephone = telephoneInput.text;
	if(this.currentState == "mod"){
		if(userApply != null){
			obj.applyType = userApply.applyType;
			obj.DR = userApply.DR;
			obj.applyStatus = userApply.applyStatus;
			obj.applyId = userApply.applyId;
		}else{
			TAlert.show("系统繁忙,稍后再试!","温馨提示");
		}
	}else{
		obj.applyType = FLOW_TYPE;
		obj.applyStatus = 0;
		obj.DR = 0;
	}
	
	
	//请求单填写者
	var applyEntry:Object = new Object();
	applyEntry.id = appCore.loginUser.id;
	applyEntry.personId = appCore.loginUser.msPerson.id;
	applyEntry.companyID = appCore.loginUser.companyId;
	obj.applyEntry = applyEntry;
	
	
	//提出请求的具体用户
	var sponsor:Object = new Object();
	if(sponsorInput.selectObj.hasOwnProperty("userId")){
		sponsor.id = sponsorInput.selectObj.userId;
		obj.sponsor = sponsor;
	}else{
		sponsor.id = userApply.sponsor.id;
		obj.sponsor = sponsor;
	}
	
	//时间处理
	applyDateHandle(obj);
	
	//公司与部门
	obj.company = companyInput.text;
	obj.department = departmentInput.text;
	
	
	//用户请求单编号
	/*编号格式按照这样，问题：WT201308120001这样编号下去，
	需求就XQ201308120001，BUG：BG201308120001*/
	//var codeStr:String = "BG";
	obj.userApplyCode = userApply != null ? 
		userApply.userApplyCode : null;
	
	//文本框
	obj.directions = directionsArea!=null?BugUtil.myTrim(directionsArea.text):"";
	
	
	return obj;
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
			fileGrid.saveDgToDb(Number(obj.type).toString(), applyTableName);
			fileGrid.reSetData();
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

/**更新主页表格*/
private function refreshMainGridAfterAddOrMod(applyIDNow:Number):void{
	var flagStr:String = "mod";
	if(this.currentState == "add"){
		if(SORT_FLAG){
			flagStr = "add";
			if(mainGrid.curPage == mainGrid.totalPage 
				&& (mainGrid.dataProvider as ArrayCollection).length < mainGrid.pageCount)
				handle_server_method("bugManagerAPI","BugManagerAPI","showUserApllyByID",
					[applyIDNow], addUserApllyAfterHandle);
			else
				mainGridArray = ['bugManagerAPI', 'BugManagerAPI', 'initHomePageFast', [FLAG],flagStr];
		}else
			//更新表格数据
			mainGridArray = ['bugManagerAPI', 'BugManagerAPI', 'initHomePageFast', [FLAG]];
	}else{
		handle_server_method("bugManagerAPI","BugManagerAPI","showUserApllyByID",
			[userApplyID], modUserApllyAfterHandle);
	}
	
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


//5、修改

//点击“修改”按钮触发的事件
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

/**"未提交"状态不能修改*/
private function judgeEnableMod():Boolean{
	if(mainGrid.selectedItem.applyStatus > 0){
		TAlert.show("限于\"未提交\"可修改!","温馨提示");
		return false;
	}
	return true;
}

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

//点击修改界面的bug来源下拉列表时调用==========bug来源
protected function bugSource_clickHandler(event:MouseEvent):void
{
	
	//先查看bugSources是否为null，为null再向服务器请求数据
	if(bugSources == null){
		handle_server_method("bugManagerAPI","BugManagerAPI","initBugSource",
			[], bugSource_clickHandle);
	}else{
		bugSource.dataProvider = bugSources;
	}
	//由于界面值有修改,so--将呈报按钮置灰,保存按钮激活
	enablePutBtn = false;
}

//点击修改界面的bug来源下拉列表后从后台传入的数据的处理
private function bugSource_clickHandle(event:ResultEvent):void{
	bugSources = getResultObj(event) as ArrayCollection;
	bugSource.dataProvider = bugSources;
}


//点击修改界面的bug来源下拉列表时调用==========重要程度
protected function bugUrgent_clickHandler(event:MouseEvent):void
{
	//先查看levels是否为null，为null再向服务器请求数据
	if(levels == null){
		handle_server_method("bugManagerAPI","BugManagerAPI","initLevels",
			[], bugUrgent_clickHandle);
	}else{
		bugUrgent.dataProvider = levels;
	}
	//由于界面值有修改,so--将呈报按钮置灰,保存按钮激活
	enablePutBtn = false;
}

//点击修改界面的bug来源下拉列表后从后台传入的数据的处理
private function bugUrgent_clickHandle(event:ResultEvent):void{
	levels = getResultObj(event) as ArrayCollection;
	bugUrgent.dataProvider = levels;
}


//点击修改界面的作用范围下拉列表时调用==========作用范围
protected function bugRange_clickHandler(event:MouseEvent):void
{
	//先查看bugScops是否为null，为null再向服务器请求数据
	if(bugScops == null){
		handle_server_method("bugManagerAPI","BugManagerAPI","initBugScope",
			[], bugRange_clickHandle);
	}else{
		bugRange.dataProvider = bugScops;
	}
	//由于界面值有修改,so--将呈报按钮置灰,保存按钮激活
	enablePutBtn = false;
}

//点击修改界面的作用范围下拉列表后从后台传入的数据的处理
private function bugRange_clickHandle(event:ResultEvent):void{
	bugScops = getResultObj(event) as ArrayCollection;
	bugRange.dataProvider = bugScops;
}

/**系统更改*/
protected function bugSystem_selectChangeHandler(event:Event):void
{
	bugModule.selectObj = "";
	bugModule.sText = "";
	systemID = bugSystem.selectObj.hasOwnProperty("systemID")
		?bugSystem.selectObj.systemID
		:(bugSystem.sText != "" && bugSystem.sText != null)
		?userApply.hasOwnProperty("belongSystem")
		?userApply.belongSystem.systemID:-1:-1;
	validateForm(event);
}

////点击修改界面的所属系统下拉列表时调用==========所属系统
//protected function bugSystem_clickHandler(event:MouseEvent):void
//{
//	//系统下拉被点击标志
//	isSystemBeClicked = true;
//	//由于界面值有修改,so--将呈报按钮置灰,保存按钮激活
//	enablePutBtn = false;
//	//先查看systems是否为null，为null再向服务器请求数据
//	if(systems == null){
//		handle_server_method("bugManagerAPI","BugManagerAPI","initSupportSystems",
//			[], bugSystem_clickHandle);
//	}else{
//		var sysid:uint = bugSystem.selectedItem.systemID;
//		bugSystem.dataProvider = systems;
//		if(bugSystem.selectedIndex == 0){
//			modules = systems.getItemAt(0).systemModules as ArrayCollection;
//			bugModule.dataProvider = modules;
//		}else{
//			var flag:Boolean = false;
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
//	}
//}
//
////点击修改界面的所属系统下拉列表后从后台传入的数据的处理
//private function bugSystem_clickHandle(event:ResultEvent):void{
//	systems = getResultObj(event) as ArrayCollection;
//	modules = systems.getItemAt(0).systemModules as ArrayCollection;
//	
//	bugSystem.dataProvider = systems;
//	bugModule.dataProvider = modules;
//}
//
////点击修改界面的所属模块下拉列表时调用==========所属模块
//protected function bugModule_clickHandler(event:MouseEvent):void
//{
//	var sysid:uint;
//	if(userApply == null || isSystemBeClicked){
//		sysid = bugSystem.selectedItem != null 
//			? bugSystem.selectedItem.systemID : -1;
//	}else
//		sysid = userApply.belongSystem.systemID;
//	if(modules == null || modules.getItemAt(0).systemID != sysid)
//		handle_server_method("bugManagerAPI","BugManagerAPI","initSystemModules",
//			[sysid], bugModule_clickHandle);
//	else
//		bugModule.dataProvider = modules;
//	//由于界面值有修改,so--将呈报按钮置灰,保存按钮激活
//	enablePutBtn = false;
//}
////点击修改界面的所属模块下拉列表后从后台传入的数据的处理
//private function bugModule_clickHandle(event:ResultEvent):void{
//	var obj:Object = getResultObj(event);
//	
//	modules = obj as ArrayCollection;
//	bugModule.dataProvider = modules;
//}

//点击修改界面的实际影响范围下拉列表时调用==========实际影响范围
protected function bugRealRange_clickHandler(event:MouseEvent):void
{
	//先查看realBugScops是否为null，为null再向服务器请求数据
	if(realBugScops == null){
		handle_server_method("bugManagerAPI","BugManagerAPI","initBugScope",
			[], bugRealRange_clickHandle);
	}else{
		bugRealRange.dataProvider = realBugScops;
	}
}

//点击修改界面的实际影响范围下拉列表后从后台传入的数据的处理
private function bugRealRange_clickHandle(event:ResultEvent):void{
	realBugScops = getResultObj(event) as ArrayCollection;
	
	bugRealRange.dataProvider = realBugScops;
}


//6、添加

//点击首页的添加按钮调用
protected function addBtn_clickHandler(event:MouseEvent):void
{
	reportTime = new Date();
	company = "";
	dept = "";
	userApplyID = 0;
	applyID4Word = "";
	userApply = null;
	
	selectUser = null;
	selectSys = null;
	//	createCode();//构造一个code;
	clean();
	idFlag.text = "";
	this.currentState = "add";
	
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
//	//系统
//	systems = list.getItemAt(3) as ArrayCollection;
//	//第一个系统的业务模块
//	modules = systems.getItemAt(0).systemModules as ArrayCollection;
	//实际作用范围
	realBugScops = bugScops;
	//重要程度
	levels = list.getItemAt(2) as ArrayCollection;
}


////所属系统更改时调用
//protected function bugSystem_changeHandler(event:IndexChangeEvent):void
//{
//	var sysID:int = bugSystem.selectedItem.systemID;
//	handle_server_method("bugManagerAPI","BugManagerAPI","initSystemModules",
//		[sysID], bugSystem_changeHandle);
//	//	if(replyerInput.sText != "" && replyerInput.selectObj != null){
//	//		TAlert.show("所属系统已经改变,请重新选择责任人!","温馨提示");
//	//		replyerInput.sText = "";
//	//		replyerInput.selectObj = null;
//	//	}
//}
//
//private function bugSystem_changeHandle(event:ResultEvent):void{
//	
//	modules = getResultObj(event) as ArrayCollection;
//	bugModule.dataProvider = modules;
//}

//private function addValue2userApply():UserApplyVO{
//	
//	apply = new UserApplyVO();
//	
//	//对象处理:bug来源,bug模块,bug系统,bug影响范围,bug实际影响范围,bug重要程度,请求单状态
//	var origin:ConstDetailVO = new ConstDetailVO();
//	if(bugSource.selectedItem != null)
//		origin.id = bugSource.selectedItem.id;
//	apply.applyOrigin = origin;
//	
//	var module:SystemModuleVO = new SystemModuleVO();
//	if(bugModule.selectedItem != null)
//		module.moduleID = bugModule.selectedItem.moduleID;
//	apply.sysModule = module;
//	
//	var system:SupportSystemVO = new SupportSystemVO();
//	if(bugSystem.selectedItem != null)
//		system.systemID = bugSystem.selectedItem.systemID;
//	apply.belongSystem = system;
//	
//	var range:ConstDetailVO = new ConstDetailVO();
//	if(bugRange.selectedItem != null)
//		range.id = bugRange.selectedItem.id;
//	apply.range = range;
//	
//	var urgent:ReplyLevelVO = new ReplyLevelVO();
//	if(bugUrgent.selectedItem != null)
//		urgent.replyLevelId = bugUrgent.selectedItem.replyLevelId;
//	apply.urgent = urgent;
//	
//	//这里的状态在具体的业务中会有不同的处理,比如说:呈报
//	//请求状态：0—未提交，1—未受理，2—处理中，3—完成
//	apply.applyStatus = 0;
//	
//	
//	//可以确定：主题摘要、电话、请求单id
//	apply.applyTitle = applyTitleInput.text;
//	apply.telephone = telephoneInput.text;
//	
//	
//	
//	//请求单填写者
//	var applyEntry:Object = new Object();
//	applyEntry.id = appCore.loginUser.id;
//	applyEntry.personId = appCore.loginUser.msPerson.id;
//	applyEntry.companyID = appCore.loginUser.companyId;
//	apply.applyEntry = applyEntry;
//	
//	
//	//提出请求的具体用户
//	var sponsor:Object = new Object();
//	if(sponsorInput.selectObj.hasOwnProperty("userId")){
//		sponsor.id = sponsorInput.selectObj.userId;
//		apply.sponsor = sponsor;
//	}else{
//		sponsor.id = userApply.sponsor.id;
//		apply.sponsor = sponsor;
//	}
//	
//	
//	//公司与部门
//	apply.company = companyInput.text;
//	apply.department = departmentInput.text;
//	
//	
//	//用户请求单编号
//	/*编号格式按照这样，问题：WT201308120001这样编号下去，
//	需求就XQ201308120001，BUG：BG201308120001*/
//	//var codeStr:String = "BG";
//	//	if(idFlag.text == ""){
//	//		apply.userApplyCode = codeStr;
//	//	}else
//	//		apply.userApplyCode = userApply.userApplyCode;
//	
//		//时间处理
//		applyDateHandle(apply);
//	
//	//文本框
//	//	apply.reason = reasonArea != null?myTrim(reasonArea.text):"";
//	apply.directions = directionsArea!=null?myTrim(directionsArea.text):"";
//	//	apply.solutions = solutionsArea!=null?myTrim(solutionsArea.text):"";
//	
//	
//	apply.applyType = FLAG;
//	apply.DR = "0";
//	
//	return apply;
//}


//将界面中的用户修改的值存入userApply对象之中
private function storeValue2userApply():UserApplyVO{
	
	apply = new UserApplyVO();
	
	
	//对象处理:bug来源,bug模块,bug系统,bug影响范围,bug实际影响范围,bug重要程度,请求单状态
	var origin:ConstDetailVO = new ConstDetailVO();
	if(bugSource.selectedItem != null)
		origin.id = bugSource.selectedItem.id;
	apply.applyOrigin = origin;
	
	var module:SystemModuleVO = new SystemModuleVO();
	module.moduleID = bugModule.selectObj.hasOwnProperty("moduleID")
		?bugModule.selectObj.moduleID:bugModule.sText != "" 
		&& bugModule.sText != null 
		?userApply.sysModule.moduleID:"-1";
	apply.sysModule = module;
	
	var system:SupportSystemVO = new SupportSystemVO();
	system.systemID = bugSystem.selectObj.hasOwnProperty("systemID")
		?bugSystem.selectObj.systemID:bugSystem.sText != "" 
		&& bugSystem.sText != null 
		?userApply.belongSystem.systemID:-1;
	apply.belongSystem = system;
	
	var range:ConstDetailVO = new ConstDetailVO();
	if(bugRange.selectedItem != null)
		range.id = bugRange.selectedItem.id;
	apply.range = range;
	
	var realRange:ConstDetailVO = new ConstDetailVO();
	if(bugRealRange.selectedItem != null)
		realRange.id = bugRealRange.selectedItem.id;
	apply.realRange = realRange;
	
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
	if(sponsorInput.selectObj.hasOwnProperty("userId")){
		sponsor.id = sponsorInput.selectObj.userId;
		apply.sponsor = sponsor;
	}else{
		sponsor.id = userApply.sponsor.id;
		apply.sponsor = sponsor;
	}
	
	//受理人
	var replyer:Object = new Object();
	if(replyerInput.selectObj.hasOwnProperty("userId")){
		replyer.id = replyerInput.selectObj.userId;
		apply.replyer = replyer;
	}else{
		replyer.id = userApply.replyer.id;
		apply.replyer = replyer;
	}
	
	
	//公司与部门
	apply.company = companyInput.text;
	apply.department = departmentInput.text;
	
	
	//用户请求单编号
	/*编号格式按照这样，问题：WT201308120001这样编号下去，
	需求就XQ201308120001，BUG：BG201308120001*/
	//var codeStr:String = "BG";
	if(idFlag.text == ""){
		apply.userApplyCode = codeStr;
	}else
		apply.userApplyCode = userApply.userApplyCode;
	
	//时间处理
	applyDateHandle(apply);
	
	//文本框
	apply.reason = reasonArea != null?BugUtil.myTrim(reasonArea.text):"";
	apply.directions = directionsArea!=null?BugUtil.myTrim(directionsArea.text):"";
	apply.solutions = solutionsArea!=null?BugUtil.myTrim(solutionsArea.text):"";
	
	if(userApply != null){
		apply.applyType = userApply.applyType;
		apply.DR = userApply.DR;
	}
	
	return apply;
}

private function applyDateHandle(apply:Object):void{
	//时间处理
	
	var df:DateFormatter = new DateFormatter();
	df.formatString="YYYY-MM-DD";
	
	
	//期望解决时间
	if(applyEndDate.selectedDate != null && applyEndDate.text != "")
		apply.applyEndDate = df.format(applyEndDate.selectedDate);
	else
		apply.applyEndDate = 
			StringUtil.trim(applyEndDate.text);
	
	//请求发起时间
	if(applyStartDate.selectedDate != null && applyStartDate.text != "")
		apply.applyStartDate = df.format(applyStartDate.selectedDate);
	else
		apply.applyStartDate = 
			BugUtil.myTrim(applyStartDate.text);
	
	//	//计划解决时间
	//	if(planFinishDate.selectedDate != null && planFinishDate.text != "")
	//		apply.planFinishTime = df.format(planFinishDate.selectedDate);
	//	else
	//		apply.planFinishTime = 
	//			myTrim(planFinishDate.text);
	//	
	//	//响应时间
	//	if(replyDate.selectedDate != null && replyDate.text != "")
	//		apply.replyTime = df.format(replyDate.selectedDate);
	//	else
	//		apply.replyTime = 
	//			myTrim(replyDate.text);
	//	
	//	//实际解决时间
	//	if(realFinishDate.selectedDate != null && realFinishDate.text != "")
	//		apply.realFinishTime = df.format(realFinishDate.selectedDate);
	//	else
	//		apply.realFinishTime = 
	//			myTrim(realFinishDate.text);
}

/**构造一个code*/
private function createCode():void{
	
	//得到所有的bug
	handle_server_method("bugManagerAPI","BugManagerAPI","findAllProblemApplyCodes",
		[], createCodeHandle);
	
}

private function createCodeHandle(event:ResultEvent):void{
	
/*	codeStr = "BG";
	
	var allBugs:ArrayCollection = getResultObj(event) as ArrayCollection;
	
	var date:Date = new Date();
	//当前日期(天)组成的字符串
	var dateStr:String = "";
	dateStr += date.fullYear;
	dateStr += date.month+1;
	dateStr += date.date;//BG20130819---还有4位数需要根据数据库来构造
	
	//当前日期字符串转化成的数字
	var dateNum:int = parseInt(BugUtil.myTrim(dateStr));
	var bugCodes:Array = new Array();
	for(var i:int; i < allBugs.length; i++){
		if(allBugs.getItemAt(i) != null 
			? (allBugs.getItemAt(i).split("BG")).length == 2 : false)
			bugCodes.push(parseInt(BugUtil.myTrim((allBugs.getItemAt(i).split("BG"))[1])));
	}
	
	//比对数字
	bugCodes.sort();//排序获得最大值
	var maxVal:Number = bugCodes[bugCodes.length-1];
	if(Math.floor(maxVal/10000) == dateNum){
		var num:Number =  maxVal % 10000 + 1;
		num = dateNum * 10000 + num;
		codeStr += num;
	}else
		codeStr += dateNum + "0001";*/
	
}

//清空额界面显示值
private function clean():void{
	
	userApply = null;
	
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
	
	//				TAlert.show(item.userApplyCode as String);
	
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

private function backToHomePage(event:Event):void{
	
	clean();
	this.currentState='normal';
	//resetDropDownList();
}

//重置下拉列表的项目以便其能够正常显示所选userApply中的对应值
/*private function resetDropDownList():void{
	//Bug来源
	bugSource.dataProvider = getArrayListFromObject(userApply.applyOrigin);
	bugSource.selectedIndex = 0;
	//重要程度
	bugUrgent.dataProvider = getArrayListFromObject(userApply.urgent);
	bugUrgent.selectedIndex = 0;
	//影响范围
	bugRange.dataProvider = getArrayListFromObject(userApply.range);
	bugRange.selectedIndex = 0;
	//所属系统
	bugSystem.dataProvider = getArrayListFromObject(userApply.belongSystem);
	bugSystem.selectedIndex = 0;
	//所属业务模块
	bugModule.dataProvider = getArrayListFromObject(userApply.sysModule);
	bugModule.selectedIndex = 0;
	//实际影响范围
	bugRealRange.dataProvider = getArrayListFromObject(userApply.realRange);
	bugRealRange.selectedIndex =0;
	
	infoList.selectedIndex = 1;	
}*/

//初始化验证器的提示信息
private function removeMyValidator():void{
	
	sponsorInput.errorString="";
	companyInput.errorString="";
	departmentInput.errorString="";
	telephoneInput.errorString="";
	
	applyStartDate.errorString="";
	applyEndDate.errorString="";
	
	bugSource.errorString="";
	bugUrgent.errorString="";
	bugRange.errorString="";
	bugSystem.errorString="";
	bugModule.errorString="";
	
	replyDate.errorString="";
	replyerInput.errorString="";
	planFinishDate.errorString="";
	realFinishDate.errorString="";
	applyTitleInput.errorString="";
	
	directionsArea.errorString="";
	bugRealRange.errorString="";
	reasonArea.errorString="";
	solutionsArea.errorString="";
}

//这里主要是因为dropDownList的dataProvider需要的是IList接口对象
private function getArrayListFromObject(obj:Object):ArrayCollection{
	return new ArrayCollection(new Array(obj));
}

/**
 * 报告人弹窗选择改变事件,主要用于更新界面的公司和部门的值,和责任人弹窗人员筛选
 */
protected function sponsorInput_selectChangeHandler(event:Event):void
{
	company = sponsorInput.selectObj.hasOwnProperty("companyName") ? sponsorInput.selectObj.companyName : "";
	dept = sponsorInput.selectObj.hasOwnProperty("companyName") ? sponsorInput.selectObj.orgName : "";
	selectUser = sponsorInput.selectObj;
	//由于界面值有修改,so--将呈报按钮置灰,保存按钮激活
	enablePutBtn = false;
}

//呈报功能
private var FISAfterFlowCommit:Boolean=false;

/**呈报按钮点击后将*/
protected function putBtn_clickHandler(event:MouseEvent):void
{
	var item:Object = mainGrid.selectedItem;
	userApply = item;
	
	if(item==null)
		TAlert.show("请选择要呈报的数据！", "温馨提示");
	else{
		if(userApply != null && userApply.applyId > 0){
			handle_server_method("bugManagerAPI","BugManagerAPI","getPersonIdByApplyId",
				[userApply.applyId],afterGetPersonId4putHandle);
		}else{
			TAlert.show("系统繁忙,稍后再试!","温馨提示");
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
				FAppCore.StartFlowInstence(sender, sender.id, FLOW_TYPE, userApply.applyId, arr, FISAfterFlowCommit, putBtn_clickHandle);
				
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
	
	//	//处理呈报对象的时间
	//	dateOfPutObjFormat(putObj);
	//	
	//	var str:String = appCore.jsonEncoder.encode(putObj);//updateUerApplyStatus
	//	handle_server_method("bugManagerAPI","BugManagerAPI","updateBugUerApply",
	//		[str], after_putBtn_clickHandle);
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

/**刷新点击后,初始化主页表格*/
protected function refreshBtn_clickHandler(event:MouseEvent):void
{
	//主页表格数据初始化
	mainGridArray = ['bugManagerAPI', 'BugManagerAPI', 'initHomePageFast', [FLAG]];
}

/**项选中事件:弹出或隐藏审批历史*/
protected function mainGrid_itemClickHandler(event:ListEvent):void
{
	userApply = mainGrid.selectedItem;
	
	if(flow_index != mainGrid.selectedIndex && mainGrid.selectedIndex > -1
		&& userApply.applyStatus > 0){
		
		flow_index = mainGrid.selectedIndex;
		
		if(userApply!=null){// && obj.flowId!=null
			AppHistoryGrid.getApproveHistory(FLOW_TYPE, userApply.applyId);
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
