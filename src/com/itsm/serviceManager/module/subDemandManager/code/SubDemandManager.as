import com.itsm.common.utils.AppCore;
import com.itsm.flow.app.GlobalUtil;
import com.itsm.serviceManager.module.bugManager.code.BugUtil;
import com.itsm.serviceManager.module.subDemandManager.mxml.PopSearchSubDemand;

import common.utils.TAlert;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;

import mx.collections.ArrayCollection;
import mx.controls.DateField;
import mx.effects.Fade;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.events.ListEvent;
import mx.formatters.DateFormatter;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;

import spark.events.IndexChangeEvent;

private var FAppCore:GlobalUtil = GlobalUtil.getInstence();
private var appCore:AppCore = AppCore.getInstance();
//记录主页表格弹起的是哪个流程的流程状态图
[Bindable]
private var flow_index:int = -1;
//一个子需求单对象
[Bindable]
public var subDemandObj:Object;
//呈报对象
[Bindable]
private var putObj:Object;
//一个请求单对象
[Bindable]
public var userApply:Object;
//子需求单的id
[Bindable]
public var subDemandID:String = "";
//自需求但也无存储表格
public var subDemandTableName:String = "T_DEMANDS_PART";
//流程模型类型
private static const FLOW_TYPE:String="6";
//当前系统时间，用于界定用户选择时间
[Bindable]
private var now:Date = new Date();
//主页表格数据集
[Bindable]
public var mainGridArray:Array = null;
//当前系统id：限制需求人员选择--只能选择当前系统的需求人员
[Bindable]
private var sysID:int = -1;
////所属系统
//[Bindable]
//public var systems:ArrayCollection;
////所属系统的业务模块
//[Bindable]
//public var modules:ArrayCollection;
//重要程度
[Bindable]
public var levels:ArrayCollection;
//demand作用范围
[Bindable]
public var subDemandScops:ArrayCollection;
//呈报按钮是否有效
[Bindable]
private var enablePutBtn:Boolean = false;
//保存按钮是否有效
[Bindable]
private var enableSaveBtn:Boolean = false;
//判断系统下拉是否被点击,没有就说明其值是subDemand的原始值
[Bindable]
private var isSystemBeClicked:Boolean = false;
//表单是否有效 
[Bindable] 
private var formIsValid:Boolean = true;
//表单是否为空 
[Bindable] 
public var formIsEmpty:Boolean = true; 
//排序方式:是否升序
private static const SORT_FLAG:Boolean = false;
//是否在查看页面显示"呈报"按钮
[Bindable]
private var viewPutBtn:Boolean = false;
//持有该目前集中控制的对象。 
private var focussedFormControl:DisplayObject; 
//当前登录用户id
[Bindable]
private var currentPersonId:String;
//添加界面的需求单是否选择
[Bindable]
private var applyIsSelectedInAdd:Boolean = false;
//系统
[Bindable]
private var systemName:String;
//模块
[Bindable]
private var moduleName:String;
//功能测试人员
[Bindable]
private var fTesterName:String;


/**
 * 弹窗下拉菜单初始化
 */
private function initSubDemandInfo(event:FlexEvent):void{
	
	currentPersonId = FAppCore.FCusUser.UserId;
	
	AppHistoryGrid.gridMain.OnlyInit();
	
	//主页表格数据初始化
	mainGridArray = ["demandManagerAPI","DemandManagerAPI", 'initSubDemanHomePageFast', []];
	
//	//系统
//	if(!(systems != null))
//		BugUtil.handle_server_method("bugManagerAPI","BugManagerAPI","initSupportSystems",
//			[], function(event:ResultEvent):void{
//				systems = BugUtil.getResultObj(event) as ArrayCollection;
//				modules = systems.getItemAt(0).systemModules as ArrayCollection;
//			});
	
	//重要程度
	if(!(levels != null))
		BugUtil.handle_server_method("bugManagerAPI","BugManagerAPI","initLevels",
			[], function(event:ResultEvent):void{
				levels = BugUtil.getResultObj(event) as ArrayCollection;
			});
	
	//影响范围
	if(!(subDemandScops != null))
		BugUtil.handle_server_method("bugManagerAPI","BugManagerAPI","initBugScope",
			[], function(event:ResultEvent):void{
				subDemandScops = BugUtil.getResultObj(event) as ArrayCollection;
			});
	
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
	if(demandRange.selectedItem != null)
		range.id = demandRange.selectedItem.id;
	obj.range = range;
	
	var urgent:Object = new Object();
	if(demandUrgent.selectedItem != null)
		urgent.replyLevelId = demandUrgent.selectedItem.replyLevelId;
	obj.urgent = urgent;
	
	//服务单填写者--项目经理
	var sponsor:Object = new Object();
	sponsor.id = appCore.loginUser.id;
	sponsor.personId = appCore.loginUser.msPerson.id;
	sponsor.companyID = appCore.loginUser.companyId;
	obj.sponsor = sponsor;
	
	//开发经理
	var developManager:Object = new Object();
	developManager.id = subDemandObj!=null?subDemandObj.developManager.id
		:demandSelect.selectObj.hasOwnProperty("applyId")?demandSelect.selectObj.developManager.id:-1;
	obj.developManager = developManager;
	
	//需求人员
	var analyst:Object = new Object();
	analyst.id = 
		subDemandAnalyst.selectObj.hasOwnProperty("userId")
		?subDemandAnalyst.selectObj.userId:subDemandObj.analyst.id;
	obj.analyst = analyst;
	
	//功能测试人员--需求人员
	obj.funcTester = analyst;
	
	//时间处理
	applyDateHandle(obj);
	
	//主题摘要
	obj.demandTitle = demandTitle.text;
	//需求描述
	obj.directions = directions.text;
	
	//主需求单id
	if(userApply != null)
		obj.userApplyId = userApply.applyId;
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
	if(planAnalysisDate.selectedDate != null)
		apply.planAnalysisDate = df.format(planAnalysisDate.selectedDate);
	//项目经理填写预计开发完成时间
	if(planDevelopDate.selectedDate != null)
		apply.planDevelopDate = df.format(planDevelopDate.selectedDate);
	//项目经理填写预计单元测试完成时间
	if(planUtestDate.selectedDate != null)
		apply.planUtestDate = df.format(planUtestDate.selectedDate);
	//项目经理填写预计功能测试完成时间
	if(planFtestDate.selectedDate != null)
		apply.planFtestDate = df.format(planFtestDate.selectedDate);
	
}

//点击保存调用到的方法
protected function saveBtn_clickHandler(event:MouseEvent):void
{
	if(formIsValid && !formIsEmpty){
		if(this.currentState == "add")
			BugUtil.handle_server_method("demandManagerAPI","DemandManagerAPI","addSubDemandUserApply",
				[appCore.jsonEncoder.encode(createObject4Save())], saveBtn_clickHandle);
		else
			BugUtil.handle_server_method("demandManagerAPI","DemandManagerAPI","updateSubDemandUserApply",
				[appCore.jsonEncoder.encode(createObject4Save())], saveBtn_clickHandle);
	}else
		TAlert.show("输入有误,请查看页面提示信息!","温馨提示");
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
		}else if(obj == "1"){
			//呈报按钮激活,保存按钮置灰
			enablePutBtn = true;
			msg.text = "亲，可以呈报哦！";
			//保存按钮置灰
			enableSaveBtn = false;
		}
	}else{
		if(obj.type>=1) {
			if(obj.type > 1)
				applyIDNow = Number(obj.type);
			fileGrid.saveDgToDb(Number(obj.type).toString(), subDemandTableName);
			fileGrid.reSetData();
			enablePutBtn = false;
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
				BugUtil.handle_server_method("demandManagerAPI","DemandManagerAPI","showSubDemandByID",
					[applyIDNow], addUserApllyAfterHandle);
			else
				mainGridArray = ["demandManagerAPI","DemandManagerAPI", 'initSubDemanHomePageFast', [],flagStr];
		}else
			//更新表格数据
			mainGridArray = ["demandManagerAPI","DemandManagerAPI", 'initSubDemanHomePageFast', []];
	}else{
		BugUtil.handle_server_method("demandManagerAPI","DemandManagerAPI","showSubDemandByID",
			[subDemandID], modUserApllyAfterHandle);
	}
	
}

/**
 * 如果当前页码为最后一页,并且表格未满,就直接向表格追加用户刚刚插入的数据
 */
private function addUserApllyAfterHandle(event:ResultEvent):void{
	var obj:Object = BugUtil.getResultObj(event);
	(mainGrid.dataProvider as ArrayCollection).addItem(obj);
	mainGrid.totalCount = mainGrid.totalCount+1;
}

/**
 * 将从后台查询到的一条更新请求记录存入主页表格选择的数据位置处
 * 此函数主要是为了减少对数据库的分页查询
 */ 
private function modUserApllyAfterHandle(event:ResultEvent):void{
	var obj:Object = BugUtil.getResultObj(event);
	(mainGrid.dataProvider as ArrayCollection).setItemAt(obj,mainGrid.selectedIndex);
}

//点击修改界面的demand来源下拉列表时调用==========重要程度
protected function demandUrgent_clickHandler(event:MouseEvent):void
{
	//先查看levels是否为null，为null再向服务器请求数据
	if(levels == null){
		BugUtil.handle_server_method("bugManagerAPI","BugManagerAPI","initLevels",
			[], demandUrgent_clickHandle);
	}else{
		demandUrgent.dataProvider = levels;
	}
//	//由于界面值有修改,so--将呈报按钮置灰,保存按钮激活
//	enablePutBtn = false;
}

//点击修改界面的demand来源下拉列表后从后台传入的数据的处理
private function demandUrgent_clickHandle(event:ResultEvent):void{
	levels = BugUtil.getResultObj(event) as ArrayCollection;
	demandUrgent.dataProvider = levels;
}


//点击修改界面的作用范围下拉列表时调用==========作用范围
protected function demandRange_clickHandler(event:MouseEvent):void
{
	//先查看demandScops是否为null，为null再向服务器请求数据
	if(subDemandScops == null){
		BugUtil.handle_server_method("bugManagerAPI","BugManagerAPI","initBugScope",
			[], demandRange_clickHandle);
	}else{
		demandRange.dataProvider = subDemandScops;
	}
//	//由于界面值有修改,so--将呈报按钮置灰,保存按钮激活
//	enablePutBtn = false;
}

//点击修改界面的作用范围下拉列表后从后台传入的数据的处理
private function demandRange_clickHandle(event:ResultEvent):void{
	subDemandScops = BugUtil.getResultObj(event) as ArrayCollection;
	demandRange.dataProvider = subDemandScops;
}


/**添加界面的客户需求单选择改变后*/
private function demandSelectChange(event:Event):void{
	userApply = demandSelect.selectObj;
	if(userApply != null && userApply.hasOwnProperty("applyId")){
		sysID = userApply.hasOwnProperty("belongSystem")?userApply.belongSystem.systemID:-1;
		systemName = userApply.belongSystem!=null?userApply.belongSystem.systemName:"";
		moduleName = userApply.sysModule!=null?userApply.sysModule.moduleName:"";
		applyIsSelectedInAdd = true;
	}
	validateForm(event);
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
	
	//更新功能测试人员显示
	fTesterName = subDemandAnalyst.sText;
	
	/*运行每个验证器反过来,使用isValid() 
	辅助方法和更新formIsValid的价值 
	因此。 */
	BugUtil.validate(demandTitleV,formIsValid,focussedFormControl);
	BugUtil.validate(directionsV,formIsValid,focussedFormControl);
	BugUtil.validate(planAnalysisDateV,formIsValid,focussedFormControl);
	BugUtil.validate(planDevelopDateV,formIsValid,focussedFormControl);
	BugUtil.validate(planUtestDateV,formIsValid,focussedFormControl);
	BugUtil.validate(planFtestDateV,formIsValid,focussedFormControl);
	
		if(this.currentState == "add"){
			var flag:Boolean = demandSelect.selectObj.hasOwnProperty("applyId");
			if(!flag){
				msg.text = "请先选择客户需求单!";
				msg.visible = true;
				enablePutBtn = true;
			}else{
				showMsg();
			}
		}else if(this.currentState == "mod"){
			if(formIsEmpty){
				showAndHideLabel(!formIsValid);
			}else
				showMsg();
		}else{}
		
		if(formIsValid && !formIsEmpty)
			enableSaveBtn = true;
		else
			enableSaveBtn = false;
}

/**“add”与“mod”状态都需要调用*/
private function showMsg():void{
	if(formIsEmpty){
		msg.text = "带“*”项以及“需求描述”为必填项！";
		msg.visible = true;
	}else{
		if(formIsValid){
			msg.text = "亲，可以保存!";
			msg.visible = true;
			enablePutBtn = false;
		}else{
			msg.text = "阶段计划完成时间或需求描述有误！";
			msg.visible = true;	
		}
	}
}

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
	flag = flag ? subDemandAnalyst.sText == "" ? true: false : false;
	formIsEmpty = flag || 
		demandUrgent.selectedItem == undefined || 
		demandRange.selectedItem == undefined || 
		planAnalysisDate.selectedDate == null || 
		planDevelopDate.selectedDate == null || 
		planUtestDate.selectedDate == null || 
		planFtestDate.selectedDate == null || 
		demandTitle.text == "" || 
		directions.text == "";
}

/**判断表单是否有效*/
private function judgeFormIsValid():void{
	var obj:Object = new Object();
	obj = subDemandAnalyst.selectObj;
	var flag:Boolean = false;
	flag = !obj.hasOwnProperty("userId") && !obj.hasOwnProperty("id")
		? subDemandAnalyst.sText != "" : obj.hasOwnProperty("userId")||obj.hasOwnProperty("id");
	formIsValid = demandUrgent.selectedItem != undefined && 
		demandRange.selectedItem != undefined && 
		planAnalysisDate.selectedDate != null && 
		planDevelopDate.selectedDate != null && 
		planUtestDate.selectedDate != null && 
		planFtestDate.selectedDate != null && 
		planAnalysisDate.selectedDate <= planDevelopDate.selectedDate && 
		planDevelopDate.selectedDate <= planUtestDate.selectedDate && 
		planUtestDate.selectedDate <= planFtestDate.selectedDate && 
		demandTitle.text != "" && 
		directions.text != "" && 
		flag;
}

private function backToHomePage(event:Event):void{
	clean();
	enableSaveBtn = false;
	this.currentState='normal';
}

/**清空额界面显示值*/
private function clean():void{
	mainGrid.selectedIndex = -1;
	subDemandObj = null;
	userApply = null;
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

/**判断是否选择了一条请求单记录*/
private function isSelect():Boolean{
	if(mainGrid.selectedIndex == -1){
		return false;
	}
	return true;
}

//点击界面的查看按钮调用
protected function queryBtn_clickHandler(event:MouseEvent):void
{
	/*初始化系统是否被点击状态,这里用于模块下拉菜单加载使用,这里也设置,
	是因为当请求单是"未提交"状态时,是会跳转到修改界面的*/
	isSystemBeClicked = false;
	//判断是否选择数据
	if(!isSelect()){
		BugUtil.popUpSelect();
		return;
	}
	subDemandID = subDemandObj != null ? subDemandObj.userDemandId : "";
	
	if(subDemandID != ""){
		BugUtil.handle_server_method("demandManagerAPI","DemandManagerAPI","showSubDemandByID",
			[subDemandID], function(event:ResultEvent):void{
				subDemandObj = BugUtil.getResultObj(event) != "0" ? BugUtil.getResultObj(event) : null;
				fTesterName = subDemandObj != null ? subDemandObj.funcTester.userName : ''
			});
		
		BugUtil.handle_server_method("demandManagerAPI","DemandManagerAPI","getPersonIdBySubDemandId",
			[subDemandID],afterGetPersonId4queryHandle);
	}else{
		TAlert.show("系统繁忙,稍后再试!","温馨提示");
	}

}

private function afterGetPersonId4queryHandle(event:ResultEvent):void{
	
	var obj:Object = BugUtil.getResultObj(event);
	var persons:ArrayCollection;
	
	if(obj != "0" ){
		persons = obj as ArrayCollection;
			//是否是需求发起人查看,如果是就可以编辑
			if(persons.getItemAt(0) == currentPersonId){
				//如果说请求单的状态为"未提交"则显示激活"呈报"按钮并且将"保存"按钮置灰
				viewPutBtn = subDemandObj != null && subDemandObj.demandStatus == 0;
				enablePutBtn = viewPutBtn;
				if(viewPutBtn){
					this.currentState = "mod";
					msg.text = "亲，可以呈报哦！";
				}
				else{
					this.currentState = "query";
					msg.visible = false;
				}	
			}else{
				//如果说请求单的状态为"未提交"则显示激活"呈报"按钮并且将"保存"按钮置灰
				enablePutBtn = viewPutBtn = false;
				this.currentState = "query";
			}
	}else
		TAlert.show("系统繁忙,稍后再试!","温馨提示");
}

//点击“修改”按钮触发的事件
protected function modfiyBtn_clickHandler(event:MouseEvent):void
{
	//初始化系统是否被点击状态,这里用于模块下拉菜单加载使用
	isSystemBeClicked = false;
	if(!isSelect()){
		BugUtil.popUpSelect();
		return;
	}else{
		
		var item:Object = mainGrid.selectedItem;
		subDemandObj = item;
		subDemandID = subDemandObj.userDemandId;
		if(item==null)
			TAlert.show("请选择要修改的数据！", "温馨提示");
		else{
			
			if(!judgeEnableMod())
				return;
			
			if(subDemandObj != null && subDemandObj.userDemandId > 0){
				BugUtil.handle_server_method("demandManagerAPI","DemandManagerAPI","getPersonIdBySubDemandId",
					[subDemandID],afterGetPersonId4modHandle);
			}else{
				TAlert.show("系统繁忙,稍后再试!","温馨提示");
			}
		}
	}
	
}

private function afterGetPersonId4modHandle(event:ResultEvent):void{
	
	
	var obj:Object = BugUtil.getResultObj(event);
	var persons:ArrayCollection;
	
	if(obj != "0" ){
		persons = obj as ArrayCollection;
		//是否是需求发起人修改,如果是就可以修改
		if(persons.getItemAt(0) == currentPersonId){
			//查询出子需求单信息，并跳转到修改页面
			BugUtil.handle_server_method("demandManagerAPI","DemandManagerAPI","showSubDemandByID",
				[subDemandID], function(event:ResultEvent):void{
					subDemandObj = BugUtil.getResultObj(event) != "0" ? BugUtil.getResultObj(event) : null;
					
					//如果说请求单的状态为"未提交"则显示激活"呈报"按钮并且将"保存"按钮置灰
					viewPutBtn = subDemandObj != null && subDemandObj.demandStatus == 0;
					enablePutBtn = viewPutBtn;
					
				});
			BugUtil.handle_server_method("demandManagerAPI","DemandManagerAPI","showDemand4FlowByID",
				[subDemandID], function(event:ResultEvent):void{
					userApply = BugUtil.getResultObj(event) != "0" ? BugUtil.getResultObj(event) : null;
				});
			this.currentState = "mod";
			msg.text = "亲，可以呈报哦！";
		}else{
			TAlert.show("请联系项目经理!","温馨提示");
		}
	}else
		TAlert.show("系统繁忙,稍后再试!","温馨提示");
}

/**"未提交"状态不能修改*/
private function judgeEnableMod():Boolean{
	if(mainGrid.selectedItem.demandStatus > 0){
		TAlert.show("限于\"未提交\"可操作当前功能!","温馨提示");
		return false;
	}
	return true;
}

//点击首页的添加按钮调用
protected function addBtn_clickHandler(event:MouseEvent):void
{
	//判断当前用户是否为“项目经理”
	BugUtil.handle_server_method("demandManagerAPI","DemandManagerAPI","judgeIsPMByUserId",
		[currentPersonId],judgeIsPMByUserIdHandle);
}

private function judgeIsPMByUserIdHandle(event:ResultEvent):void{
	var obj:Object = BugUtil.getResultObj(event);
	if(obj == "1"){
		subDemandObj = null;
		subDemandID = "";
		this.currentState = "add";
		msg.text = "请先选择客户需求单!";
		msg.visible = true;
		enablePutBtn = true;
		clearFormHandler();
	}else{
		TAlert.show("请联系项目经理！","温馨提示");
	}
}

//点击demand管理界面首页的删除按钮触发
private function delApplypopWarn(event:MouseEvent):void{
	
	if(isSelect()){
		subDemandObj = mainGrid.selectedItem;
		subDemandID = subDemandObj.userDemandId;
		
		//判断需求状态
		if(!judgeEnableMod())
			return;
		
		if(subDemandObj != null){
			if(subDemandObj.demandStatus == 0){
				BugUtil.handle_server_method("demandManagerAPI","DemandManagerAPI","getPersonIdBySubDemandId",
					[subDemandID],afterGetPersonIdHandle);
			}else{
				TAlert.show("限于“未提交”可删除!","温馨提示");
			}
		}else{
			TAlert.show("系统繁忙,稍后再试!","温馨提示");
		}
	}else{
		BugUtil.popUpSelect();	
	}
}

private function afterGetPersonIdHandle(event:ResultEvent):void{
	var obj:Object = BugUtil.getResultObj(event);
	var persons:ArrayCollection;
	if(obj != "0" ){
		persons = obj as ArrayCollection;
		//是否是需求发起人修改,如果是就可以修改
		if(persons.getItemAt(0) == currentPersonId){
			popWwarn(delApplyProcess);
		}else{
			TAlert.show("请联系项目经理!","温馨提示");
		}
	}else{
		TAlert.show("系统繁忙,稍后再试!","温馨提示");
	}
}

//弹出确认按钮panel
private function popWwarn(method:Function):void{
	TAlert.show("您确认删除吗？","删除",TAlert.OK|TAlert.NO,this,method,null,TAlert.YES);
}

//确认删除请求调用
private function delApplyProcess(event:CloseEvent):void{
	subDemandID = mainGrid.selectedItem.userDemandId;
	if(event.detail == TAlert.OK){
		BugUtil.handle_server_method("demandManagerAPI","DemandManagerAPI","delSubDemandById",
			[subDemandID],afterDelApplyHandle);
	}
}
	
//执行删除后调用
private function afterDelApplyHandle(event:ResultEvent):void{
	var result:String = event.result as String;
	if(result == "1")
		//主页表格数据初始化
		mainGridArray = ["demandManagerAPI","DemandManagerAPI", 'initSubDemanHomePageFast', []];
}

/**呈报按钮点击后将*/
private var FISAfterFlowCommit:Boolean=false;
protected function putBtn_clickHandler(event:MouseEvent):void
{
	subDemandObj = mainGrid.selectedItem;
	subDemandID = subDemandObj.userDemandId;
	if(subDemandObj==null)
		TAlert.show("请选择要呈报的数据！", "温馨提示");
	else{
		
		if(!judgeEnableMod())
			return;
		
		if(subDemandObj != null && subDemandID != ""){
			BugUtil.handle_server_method("demandManagerAPI","DemandManagerAPI","getPersonIdBySubDemandId",
				[subDemandID],afterGetPersonId4putHandle);
		}else{
			TAlert.show("系统繁忙,稍后再试!","温馨提示");
		}
	}
}

private function afterGetPersonId4putHandle(event:ResultEvent):void{
	
	var obj:Object = BugUtil.getResultObj(event);
	var persons:ArrayCollection;
	if(obj != "0" ){
		persons = obj as ArrayCollection;
		//是否是需求发起人修改,如果是就可以修改
		if(persons.getItemAt(0) == currentPersonId){
				
				//呈报的具体业务处理
				var arr:Array = new  Array();
				var Oitem:String= "department:"+FAppCore.FCusUser.DeptId;
				arr.push(Oitem);
				
				putObj = subDemandObj;
				//if (item.flowState == 138) FISAfterFlowCommit = true;
				var sender:Object = new Object();
				sender.id=currentPersonId;
				sender.personName=FAppCore.FCusUser.UserName;
				//		fAppCore.StartFlowInstence(sender, item.applyEntry.id, FLOW_TYPE, item.applyId, arr, FISAfterFlowCommit, putBtn_clickHandle);
				FAppCore.StartFlowInstence(sender, sender.id, FLOW_TYPE, subDemandID, arr, FISAfterFlowCommit, putBtn_clickHandle);
				backToHomePage(null);
			}else{
				TAlert.show("请联系项目经理!","温馨提示");
			}
	}else{
		TAlert.show("系统繁忙,稍后再试!","温馨提示");
	}
	
}

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
	
	if(obj == 1)
		mainGrid.selectedIndex = -1;
}

/**
 * 获取兄弟需求服务单们
 */
protected function btnBrother_clickHandler(event:MouseEvent):void{
	var item:Object = mainGrid.selectedItem;
	subDemandObj = item;
	if(item==null)
		TAlert.show("请选择一条数据！", "温馨提示");
	else{
		mainGridArray = ["bugManagerAPI", "BugManagerAPI", 'getSubDemandsByUserApplyID', 
			[subDemandObj.userApplyId]];
	}
}

/**
 * 查询按钮事件,在此处需要传送一些列数据给弹窗的下拉菜单,以便实现初始化
 */ 
public function btnSearch_clickHandler(event:MouseEvent):void{
	
	var popWin:PopSearchSubDemand = PopSearchSubDemand(PopUpManager.createPopUp(this,PopSearchSubDemand,true));
	
	//需求状态，0：未提交，1：需求分析，2：开发经理指派人员，3：开发，4：单元测试，5：功能测试，6：项目经理审核，7：完成
	popWin.statusLst = 
		new ArrayCollection(
			[{"id":0,"describe":"未提交"},{"id":1,"describe":"需求分析"},
				{"id":2,"describe":"开发经理指派人员"},{"id":3,"describe":"开发"},
				{"id":4,"describe":"单元测试"},{"id":5,"describe":"功能测试"},
				{"id":6,"describe":"项目经理审核"},{"id":7,"describe":"完成"}]);
	popWin.ranges = subDemandScops;
	popWin.degrees = levels;
//	popWin.systems = systems;
	
	popWin.mainApp = this;
	
	PopUpManager.centerPopUp(popWin);
	
}

/**刷新点击后,初始化主页表格*/
protected function refreshBtn_clickHandler(event:MouseEvent):void
{
	//主页表格数据初始化
	mainGridArray = ["demandManagerAPI","DemandManagerAPI", 'initSubDemanHomePageFast', []];
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
	demandUrgent.selectedItem = undefined;
	demandRange.selectedItem = undefined;
	planAnalysisDate.selectedDate = null;
	planDevelopDate.selectedDate = null;
	planUtestDate.selectedDate = null;
	planFtestDate.selectedDate = null;
	demandTitle.text = "";
	directions.text = "";
	// 标记为清空 
	formIsEmpty = true; 
} 

/**项选中事件:弹出或隐藏审批历史*/
protected function mainGrid_itemClickHandler(event:ListEvent):void
{
	subDemandObj = mainGrid.selectedItem;
	subDemandID = subDemandObj != null ? subDemandObj.userDemandId : "";
	if(flow_index != mainGrid.selectedIndex && mainGrid.selectedIndex > -1
		&& subDemandObj.demandStatus > 0){
		
		flow_index = mainGrid.selectedIndex;
		
		if(subDemandObj!=null){// && obj.flowId!=null
			AppHistoryGrid.getApproveHistory(FLOW_TYPE, subDemandObj.userDemandId);
		}
		
		AppHistoryGrid.visible = true;
		AppHistoryGrid.includeInLayout = true;
		
	}else{
		
		hideFlowHistory();
		if(subDemandObj.demandStatus > 0){
			mainGrid.selectedIndex = -1;
		}
	}
}