// ActionScript file
import com.itsm.common.utils.AppCore;
import com.itsm.flow.app.GlobalUtil;
import com.itsm.serviceManager.module.bugManager.code.BugUtil;

import common.utils.TAlert;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.controls.DateField;
import mx.effects.Fade;
import mx.events.FlexEvent;
import mx.events.ListEvent;
import mx.events.ValidationResultEvent;
import mx.formatters.DateFormatter;
import mx.rpc.events.ResultEvent;
import mx.validators.Validator;

import spark.events.IndexChangeEvent;
import spark.filters.GlowFilter;

[Bindable]
public var billId:String;
//流程模型
public var oprtTypeId:String;
//请求单所在数据库表名
[Bindable]
public var applyTableName:String = "T_USER_APPLY";
//审批意见
[Bindable]
public var opinion:String;
//提醒消息
[Bindable]
public var fadeMsg:String;
//工具类
private var appCore:AppCore=AppCore.getInstance();
//主需求业务单对象
[Bindable]
public var userApply:Object;
//子需求单
[Bindable]
public var subDemandObj:Object;
//当前系统id：限制需求人员选择--只能选择当前系统的需求人员
[Bindable]
private var sysID:int = -1;
//子需求单id
[Bindable]
public var subDemandID:String = "";
//子需求单业务数据表格
[Bindable]
public var subDemandTableName:String = "T_DEMANDS_PART";
//当前时间--主要用于“计划完成时间选择控制”
[Bindable]
private var now:Date = new Date();
//表单是否有效 
[Bindable] 
private var formIsValid:Boolean = false;
//表单是否为空 
[Bindable] 
public var formIsEmpty:Boolean = true; 
//是否可以修改“开发经理”和“计划完成时间”
[Bindable]
public var canModify:Boolean = false;
//闪烁使用的filter
[Bindable]
private var filter:GlowFilter = new spark.filters.GlowFilter();
//默认情况下选择不同意(发布事件)
[Bindable]
private var FlowBillModi:Event;
//持有该目前集中控制的对象。 
private var focussedFormControl:DisplayObject; 
//用于自动取消显示保存后的提示信息
private var timer:Timer;
//已选择开发经理名称
[Bindable]
private var developerManagerName:String;
//作用范围
[Bindable]
public var scops:ArrayCollection;
//重要程度
[Bindable]
public var levels:ArrayCollection;
//子需求单集合
[Bindable]
public var subDemandsArray:Array;
//呈报使用
private var FAppCore:GlobalUtil = GlobalUtil.getInstence();
//流程模型类型
private static const FLOW_TYPE:String="6";
//呈报对象
[Bindable]
private var putObj:Object;
//判断系统下拉是否被点击,没有就说明其值是subDemand的原始值
[Bindable]
private var isSystemBeClicked:Boolean = false;
//“呈报”按钮是否可用
[Bindable]
private var putBtnIsEnable:Boolean = false;


/**闪烁提示方法*/
private var fade:Fade;
private function showAndHideLabel(isshow:Boolean):void{
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

/**判断表单是否为空：任一为空即为空*/
private function judgeFormIsEmpty():void{
	//判断页面必填字段是否为空
	var flag:Boolean = !subDemandAnalyst.selectObj.hasOwnProperty("userId") && 
		!subDemandAnalyst.selectObj.hasOwnProperty("id");
	formIsEmpty = flag || 
		subDemandUrgent.selectedItem == undefined || 
		subDemandRange.selectedItem == undefined || 
		analysisDate.selectedDate == null || 
		developDate.selectedDate == null || 
		unitTestDate.selectedDate == null || 
		functionalTestDate.selectedDate == null || 
		subDemandTitle.text == "" || 
		subDemandDirection.text == "";
}

/**挂载页面初始化:1、主需求单信息，2、子需求单集合（通过主需求单id查询），3、初始化4个下拉列表*/
public function initPage(event:FlexEvent):void{
	this.currentState = "add";
	//1、初始化主需求单,2、初始化子需求单集合
	BugUtil.handle_server_method("demandManagerAPI","DemandManagerAPI","showDemand4FlowByID",
		[billId], loadDemand4FlowInfoInfo);
	//3、初始化4个下拉列表
	BugUtil.handle_server_method("bugManagerAPI","BugManagerAPI","initDropDownList4AddPage",
		[], initDropDownList4AddPageHandle);
	//判断表单是否有任一必填字段为空
	judgeFormIsEmpty();
	//闪烁
	if(formIsEmpty)
		showAndHideLabel(!formIsValid);
	
	this.addEventListener("willAgreeEvent",doWillAgreeeEventHandle);
	
}

private function initDropDownList4AddPageHandle(event:ResultEvent):void{
	var list:ArrayCollection;
	//后台传来数据的暂存
	list = BugUtil.getResultObj(event) as ArrayCollection;
	//分类存储
	//作用范围
	scops = list.getItemAt(0) as ArrayCollection;
	//重要程度
	levels = list.getItemAt(2) as ArrayCollection;
}

/**当需要控制流程页面的“同意”、“不同意”按钮时，可以用该方法设置提示信息*/
private function giveMsg(opinion:String, fadeMsg:String):void{
	this.opinion = opinion;
	this.fadeMsg = fadeMsg;
}

/**初始化处理方法查询请求单后返回数据处理方法*/
private function loadDemand4FlowInfoInfo(event:ResultEvent):void{
	var obj:Object = BugUtil.getResultObj(event);
	
	if(obj != "0"){
		userApply = obj;
		sysID = userApply!=null?userApply.hasOwnProperty("belongSystem")?userApply.belongSystem.systemID:-1:-1;
		subDemandsArray = ['bugManagerAPI', 'BugManagerAPI', 'getSubDemandsByUserApplyID', [userApply.applyId]];
		developerManagerName = userApply!=null?
			userApply.developManager!=null?
			userApply.developManager.userName:'':'';
	}
	//判断主需求单的所有子需求单是否都完成
	BugUtil.handle_server_method("demandManagerAPI","DemandManagerAPI","judgeAllSubDemandsIsSubmit",
		[billId], judgeAllSubDemandsIsSubmitHnadle);
	
	//加载该需求单的流程进度记录
	AppHistoryGrid.gridMain.OnlyInit();
	AppHistoryGrid.getApproveHistory(oprtTypeId, billId);
	
}

/**如果主需求单的所有子需求都已经“完成”，则可以通过。否则只要有子需求单存在就不应该回退*/
protected function judgeAllSubDemandsIsSubmitHnadle(event:ResultEvent):void{
	var obj:Object = BugUtil.getResultObj(event);
	if(userApply.subDemandCount > 0){
		if(obj == userApply.subDemandCount){
			giveMsg("业务批准","业务完成");
			FlowBillModi = new Event("FlowBillDisagreeForbit");				
			this.dispatchEvent(FlowBillModi);
		}else{
			giveMsg("业务正在处理中，请等待……","业务处理中");
			FlowBillModi = new Event("FlowBillDoubleForbit");				
			this.dispatchEvent(FlowBillModi);
		}
	}else{
		giveMsg("不批准","可回退");
		FlowBillModi = new Event("FlowBillAgreeForbit");				
		this.dispatchEvent(FlowBillModi);
	}
}


/**根据返回的子需求单状态为“0”的数量与主需求单中的子需求单总数做比较：如果相同则可以修改*/
private function judgeAnySubDemandsIsSubmit(apply:Object):Boolean{
	var subDemandsArr:ArrayCollection = subDemandsGrid.dataProvider as ArrayCollection;
	var flag:uint = 0;
	if(subDemandsArr != null && subDemandsArr.length > 0){
		for each(var obj:Object in subDemandsArr){
			if(obj.demandStatus == 0)
				flag++;
		}
	}
	if(flag == 0 || flag == subDemandsArr.length){
		return false;
	}
	
	return true;
	
}


/**将要同意*/
public function doWillAgreeeEventHandle(event:Event):void{}

/**重置页面服务单添加容器字段*/
protected function resetBtn_click_handle(event:MouseEvent):void{
	subDemandObj = null;
	subDemandID = "";
	subDemandsGrid.selectedIndex = -1;
	putBtnIsEnable = false;
	clearFormHandler();
}

/**向数据库存入子需求单数据*/
protected function saveBtn_click_handle(event:MouseEvent):void{
	if(formIsValid && !formIsEmpty){
		if(this.currentState == "add")
			BugUtil.handle_server_method("demandManagerAPI","DemandManagerAPI","addSubDemandUserApply",
				[appCore.jsonEncoder.encode(createObject4Save())], addSubDemandUserApplyHandle);
		else
			BugUtil.handle_server_method("demandManagerAPI","DemandManagerAPI","updateSubDemandUserApply",
				[appCore.jsonEncoder.encode(createObject4Save())], modSubDemandUserApplyHandle);
	}else
		TAlert.show("输入有误,请查看页面提示信息!","温馨提示");
	formIsValid = false;
}

/**修改子需求单后，页面数据处理*/
protected function modSubDemandUserApplyHandle(event:ResultEvent):void{
	var obj:Object = BugUtil.getResultObj(event);
	if(obj == 1){
		msg.text = "修改成功！";
		msg.visible = true;
		subDemandObj = null;
		subDemandID = "";
		subDemandsGrid.selectedIndex = -1;
		putBtnIsEnable = false;
		subDemandsArray = ['bugManagerAPI', 'BugManagerAPI', 'getSubDemandsByUserApplyID', [userApply.applyId]];
		clearFormHandler();
	}else{
		msg.text = "系统繁忙，稍后再试！";
		msg.visible = true;
	}
	timer = new Timer(3000, 1);
	timer.addEventListener(TimerEvent.TIMER,deferredMethod);
	timer.start();
}

/**
 * 同意后处理结果
 */
public function flowResult():void{
	
	appCore.dataDeal.dataRemote("bugManagerAPI","BugManagerAPI","updateUerApplyStatusNoDataBack",[billId, 3]);
	appCore.dataDeal.remoteMethods.addEventListener(ResultEvent.RESULT, flowHanelResult);
	
}

/**
 * 同意处理前调用
 */
public function agreeBefore():void{}

private function beforeHandle(event:ResultEvent):void{
	
}


private function flowHanelResult(event:ResultEvent):void {
	TAlert.show("数据生效");
}

/**
 * 不同意后处理结果
 */
public function disagree():void{}

private function disagreeResult(event:ResultEvent):void {
	//TAlert.show("数据生效");
}

/**向数据库存入页面修改数据后的处理*/
private function addSubDemandUserApplyHandle(event:ResultEvent):void{
	var obj:Object = BugUtil.getResultObj(event);
	if(obj.type > 0){
		msg.text = "保存成功！";
		if(obj.type > 1)
			subDemandID = obj.type;
		subDemandFileGrid.saveDgToDb((obj.type).toString(), subDemandTableName);
		subDemandFileGrid.reSetData();
		msg.visible = true;
		subDemandObj = null;
		subDemandID = "";
		subDemandsGrid.selectedIndex = -1;
		putBtnIsEnable = false;
		clearFormHandler();
		
		giveMsg("业务正在处理中，请等待……","业务处理中");
		FlowBillModi = new Event("FlowBillDoubleForbit");				
		this.dispatchEvent(FlowBillModi);
		//初始化主需求单--更新主需求信息
		BugUtil.handle_server_method("demandManagerAPI","DemandManagerAPI","showDemand4FlowByID",
			[billId], loadDemand4FlowInfoInfoAfterAdd);
		subDemandsArray = ['bugManagerAPI', 'BugManagerAPI', 'getSubDemandsByUserApplyID', [userApply.applyId]];
		this.currentState == "add";
	}else{
		msg.text = "系统繁忙，稍后再试！";
		msg.visible = true;
	}
	timer = new Timer(3000, 1);
	timer.addEventListener(TimerEvent.TIMER,deferredMethod);
	timer.start();
}

/**更新流程处理界面的主需求信息*/
private function loadDemand4FlowInfoInfoAfterAdd(event:ResultEvent):void{
	var obj:Object = BugUtil.getResultObj(event);
	
	if(obj != "0"){
		userApply = obj;
		developerManagerName = userApply!=null?
			userApply.developManager!=null?
			userApply.developManager.userName:'':'';
	}
}

/**取消显示隐藏信息*/
private function deferredMethod(event:TimerEvent):void{
	msg.visible = false;
}

/**将页面值封装到对象里*/
public function createObject4Save():Object{
	var obj:Object = new Object();
	
	//start==================================================================
	//对象处理:subDemand模块,subDemand系统,subDemand影响范围,subDemand重要程度
	var module:Object = new Object();
	if(userApply != null)
		module.moduleID = userApply.sysModule.moduleID;
	obj.belongsBusiness = module;
	
	var system:Object = new Object();
	if(userApply != null)
		system.systemID = userApply.belongSystem.systemID;
	obj.belongsSystem = system;
	
	var range:Object = new Object();
	if(subDemandRange.selectedItem != null)
		range.id = subDemandRange.selectedItem.id;
	obj.range = range;
	
	var urgent:Object = new Object();
	if(subDemandUrgent.selectedItem != null)
		urgent.replyLevelId = subDemandUrgent.selectedItem.replyLevelId;
	obj.urgent = urgent;
	
	//服务单填写者--项目经理
	var sponsor:Object = new Object();
	sponsor.id = appCore.loginUser.id;
	sponsor.personId = appCore.loginUser.msPerson.id;
	sponsor.companyID = appCore.loginUser.companyId;
	obj.sponsor = sponsor;
	
	//开发经理
	var developManager:Object = new Object();
	developManager.id = userApply!=null?userApply.developManager.id:-1;
	obj.developManager = developManager;
	
	//需求人员
	var analyst:Object = new Object();
	analyst.id = 
		subDemandAnalyst.selectObj.hasOwnProperty("userId") 
		?subDemandAnalyst.selectObj.userId:
		subDemandAnalyst.selectObj.hasOwnProperty("id")
		?subDemandAnalyst.selectObj.id:-1;
	obj.analyst = analyst;
	
	//功能测试人员--需求人员
	obj.funcTester = analyst;
	
	//时间处理
	applyDateHandle(obj);
	
	//主题摘要
	obj.demandTitle = subDemandTitle.text;
	//需求描述
	obj.directions = subDemandDirection.text;
	
	//主需求单id
	obj.userApplyId = billId;
	//状态
	obj.demandStatus = 0;
	//是否删除
	obj.dr = 0;
	
	//子需求单主键id
	if(this.currentState == "mod")
		obj.userDemandId = subDemandObj.userDemandId;
	
	//===================================================================end
	
	return obj;
}

/**时间处理*/
private function applyDateHandle(apply:Object):void{
	
	var df:DateFormatter = new DateFormatter();
	df.formatString="YYYY-MM-DD";
	
	//子需求发起时间
	apply.initDate = df.format(new Date());
	//项目经理填写预计需求分析完成时间
	if(analysisDate.selectedDate != null)
		apply.planAnalysisDate = df.format(analysisDate.selectedDate);
	//项目经理填写预计开发完成时间
	if(developDate.selectedDate != null)
		apply.planDevelopDate = df.format(developDate.selectedDate);
	//项目经理填写预计单元测试完成时间
	if(unitTestDate.selectedDate != null)
		apply.planUtestDate = df.format(unitTestDate.selectedDate);
	//项目经理填写预计功能测试完成时间
	if(functionalTestDate.selectedDate != null)
		apply.planFtestDate = df.format(functionalTestDate.selectedDate);
	
}

/**呈报按钮点击后将*/
private var FISAfterFlowCommit:Boolean=false;
protected function putBtn_clickHandler(event:MouseEvent):void
{
	var item:Object = subDemandsGrid.selectedItem;
//	subDemandObj = item;
	if(item==null)
		TAlert.show("请选择要呈报的数据！", "温馨提示");
	else{
		if(item.demandStatus == 0){
			putObj = item;
			//呈报的具体业务处理
			var arr:Array = new  Array();
			var Oitem:String= "department:"+FAppCore.FCusUser.DeptId;
			arr.push(Oitem);
			
			var sender:Object = new Object();
			sender.id=FAppCore.FCusUser.UserId;
			sender.personName=FAppCore.FCusUser.UserName;
			//		fAppCore.StartFlowInstence(sender, item.applyEntry.id, FLOW_TYPE, item.applyId, arr, FISAfterFlowCommit, putBtn_clickHandle);
			FAppCore.StartFlowInstence(sender, sender.id, FLOW_TYPE, putObj.userDemandId, arr, FISAfterFlowCommit, putBtn_clickHandle);
		}else
			TAlert.show("限于“未提交”可呈报","温馨提示");
	}
}

/**当流程创建成功后，修改子需求单的状态为“1”*/
private function putBtn_clickHandle(event:ResultEvent):void{
	
	//修改数据库请求单的状态
	//需求状态，0：未提交，1：需求分析，2：开发经理指派人员，3：开发，4：单元测试，5：功能测试，6：项目经理审核，7：完成
	putObj.demandStatus = 1;
	putObj.status = "需求分析";
	
	BugUtil.handle_server_method("demandManagerAPI","DemandManagerAPI","updateSubDemandStatusNoDataBack",
		[putObj.userDemandId, putObj.demandStatus], after_putBtn_clickHandle);
}

private function after_putBtn_clickHandle(event:ResultEvent):void{
	var obj:Object = BugUtil.getResultObj(event);
	if(obj == 0)
		putBtn_clickHandle(null);
	if(obj == 1){
		subDemandsGrid.selectedIndex = -1;
		putBtnIsEnable = false;
	}
}

//判断是否选择了一条请求单记录
private function isSelect():Boolean{
	if(subDemandsGrid.selectedIndex == -1){
		return false;
	}
	return true;
}

//如果被点击子需求单是“未提交”状态，可以呈报与修改
protected function subDemandsGrid_itemClickHandler(event:ListEvent):void
{
	var obj:Object = subDemandsGrid.selectedItem;
	if(obj != null && obj.demandStatus == 0){
		putBtnIsEnable = true;
	}else
		putBtnIsEnable = false;
}

/**修改按钮点击后，将会对页面中的“添加需求服务单”块里的字段赋值，以便可以修改值*/
protected function modfiyBtn_clickHandler(event:MouseEvent):void{
	if(isSelect()){
		subDemandObj = subDemandsGrid.selectedItem;
		subDemandID = subDemandObj.userDemandId;
		subDemandFileGrid.refreshData();
		this.currentState = "mod";
		judgeFormIsValid();
		judgeFormIsEmpty();
	}else
		BugUtil.popUpSelect();
}



/**验证方法*/
private function validateForm(event:Event):void  
{                     
	//检查验证传递和返回一个布尔值相应。 
	//保存引用当前集中表单控件 
	//这样isValid()辅助方法可以只通知 
	//当前集中形式控制和不影响 
	//任何其他的表单控件。 
	focussedFormControl = event.target as DisplayObject;   
	
	// 标记表单有效的开始 
	judgeFormIsValid();
	
	// 检查表单是否为空 
	judgeFormIsEmpty();
					
	/*运行每个验证器反过来,使用isValid() 
	辅助方法和更新formIsValid的价值 
	因此。 */
	BugUtil.validate(analysisDateV,formIsValid,focussedFormControl);
	BugUtil.validate(developDateV,formIsValid,focussedFormControl);
	BugUtil.validate(unitTestDateV,formIsValid,focussedFormControl);
	BugUtil.validate(functionalTestDateV,formIsValid,focussedFormControl);
	BugUtil.validate(subDemandTitleV,formIsValid,focussedFormControl);
	BugUtil.validate(subDemandDirectionV,formIsValid,focussedFormControl);
	
	//闪烁提示
	if(formIsEmpty)
		showAndHideLabel(!formIsValid);
	if(!formIsEmpty && !formIsValid){
		msg.text = "阶段计划完成时间有误！";
		msg.visible = true;
	}else
		msg.visible = false;
} 

 

/**判断表单是否有效*/
private function judgeFormIsValid():void{
	var obj:Object = new Object();
	obj = subDemandAnalyst.selectObj;
	var flag:Boolean = obj.hasOwnProperty("userId")||obj.hasOwnProperty("id");
	formIsValid = subDemandUrgent.selectedItem != undefined && 
	subDemandRange.selectedItem != undefined && 
	analysisDate.selectedDate != null && 
	developDate.selectedDate != null && 
	unitTestDate.selectedDate != null && 
	functionalTestDate.selectedDate != null && 
	analysisDate.selectedDate <= developDate.selectedDate && 
	developDate.selectedDate <= unitTestDate.selectedDate && 
	unitTestDate.selectedDate <= functionalTestDate.selectedDate && 
	subDemandTitle.text != "" && 
	subDemandDirection.text != "" && 
	flag;
}

/** 
 *  清除验证信息 重置功能 
 * */ 
private function clearFormHandler():void 
{ 
	//表单字段清空
	//判断页面必填字段是否为空
	subDemandAnalyst.selectObj = new Object();
	subDemandAnalyst.sText = "";
		subDemandUrgent.selectedItem = undefined;
		subDemandRange.selectedItem = undefined;
		analysisDate.selectedDate = null;
		developDate.selectedDate = null;
		unitTestDate.selectedDate = null;
		functionalTestDate.selectedDate = null;
		subDemandTitle.text = "";
		subDemandDirection.text = "";
	// 标记为清空 
	formIsEmpty = true; 
} 