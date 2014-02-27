// ActionScript file
//知识库管理

import com.framelib.utils.StaticMethods;
import com.itsm.common.utils.AppCore;
import com.itsm.flow.app.GlobalUtil;
import com.itsm.serviceManager.module.knowledgeManager.mxml.QueryKnowledgeInfo;

import common.utils.TAlert;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.FileReference;
import flash.net.URLRequest;

import mx.collections.ArrayCollection;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.formatters.DateFormatter;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;

import org.flexunit.internals.matchers.Each;

import spark.components.mediaClasses.VolumeBar;
import spark.events.IndexChangeEvent;

[Bindable]
public var appCore:AppCore = AppCore.getInstance();

private var FAppCore:GlobalUtil = GlobalUtil.getInstence();

private var file:FileReference;
private var urlRequest:URLRequest;
[Bindable]
private var orgId:String;

[Bindable]
private var IsExamine:Boolean=false;     //审核状态

private var windowObj:Object = new Object();

[Bindable]
private var roleData:ArrayCollection = appCore.roleData;

[Bindable]
private var attBussId:String="";                       //附件上传表业务id

[Bindable]
private var attTableName:String="T_KNOWLEDGE_INFO";  //附件上传表名称

[Bindable]
private var attachMentsArray:ArrayCollection=new ArrayCollection();

private static const FLOW_TYPE:String="5";   //流程业务类型

private var sqlWhere:String="";      //查询条件

//选择系统id
[Bindable]
private var systemID:int = -1;

public function setWindowObj(obj:Object):void
{
	this.windowObj = obj;
	this.roleData = appCore.roleData;
}
//创建完成调用方法
protected function knowledgeModule_creationCompleteHandler(event:FlexEvent):void
{
	StaticMethods.creatButtons(this, appCore.userModuleButton);
	orgId = appCore.loginUser.companyId;
	
	urlRequest = new URLRequest(appCore.appConfig.configs.fWebServerURL+"SendFileServlet?userName=" + appCore.loginUser.userCode);
	
}
//将远程服务器返回的数据进行处理
private function getResultObj(event:ResultEvent):Object{
	var resultStr:String = event.result.toString();	
	return appCore.jsonDecoder.decode(resultStr);
}
//查看按钮点击事件		
public function btn_view_clickHandler(event:MouseEvent):void{
	if(knowledge_Grid.selectedIndex!=-1){
		attBussId=(knowledge_Grid.selectedItem.id).toString();
		appCore.dealData("frameAPI", "FrameAPI", "findRelateAttachments",[attTableName, attBussId], bindDateToDataGrid);
		this.currentState="query";
		konwledgeTitle.text=knowledge_Grid.selectedItem.knowledgeTitle;
		bindDropDownList();
		IsExamine=(knowledge_Grid.selectedItem.isExamine=="0"||knowledge_Grid.selectedItem.isExamine=="2")?false:true;
		text_content.text=knowledge_Grid.selectedItem.knowledgeContent;
	}else{
		TAlert.show("请选择需要查看的数据！","系统提示");
	}
}
//新增按钮点击事件	
public function btn_add_clickHandler(event:MouseEvent):void{
	this.currentState="add";
}
//编辑按钮点击事件	
public function btn_edit_clickHandler(event:MouseEvent):void{
	if(knowledge_Grid.selectedIndex!=-1){
		if(knowledge_Grid.selectedItem.publishStaff.id==appCore.loginUser.id){
			//绑定附件列表
			attBussId=(knowledge_Grid.selectedItem.id).toString();
			appCore.dealData("frameAPI", "FrameAPI", "findRelateAttachments",[attTableName, attBussId], bindDateToDataGrid);
			this.currentState="modify";
			konwledgeTitle.text=knowledge_Grid.selectedItem.knowledgeTitle;
			bindDropDownList();
			IsExamine=(knowledge_Grid.selectedItem.isExamine=="0"||knowledge_Grid.selectedItem.isExamine=="2")?false:true;
			text_content.text=knowledge_Grid.selectedItem.knowledgeContent;
		}else{
			TAlert.show("不能编辑他人的数据！","系统提示");
		}
	}else{
		TAlert.show("请选择需要编辑的数据！","系统提示");
	}
}
private function bindDateToDataGrid(event:ResultEvent):void{
	if(event.result != null) {
		attachMentsArray = appCore.jsonDecoder.decode(event.result as String) as ArrayCollection;
	}
}
//删除按钮点击事件	
public function btn_delete_clickHandler(event:MouseEvent):void{
	if(knowledge_Grid.selectedIndex!=-1){
		if(knowledge_Grid.selectedItem.publishStaff.id!=appCore.loginUser.id){
			TAlert.show("不能删除他人的数据！","系统提示");
			return;
		}
		if(knowledge_Grid.selectedItem.isExamine!="0"){
			TAlert.show("只能删除未呈报的数据！","系统提示");
			return;
		}
		TAlert.show("你确定要删除选中的数据？","系统提示", TAlert.YES | TAlert.NO, null, 
			function(ent:CloseEvent):void{
				if (ent.detail == TAlert.YES){
					var knowledgeId:String=knowledge_Grid.selectedItem.id;
					appCore.dataDeal.dataRemote("knowledgeManagerAPI","KnowledgeManagerAPI","deleteKnowledgeInfo", [knowledgeId]);
					appCore.dataDeal.remoteMethods.addEventListener(ResultEvent.RESULT,
						function(evt:ResultEvent):void{
							if(evt.result as String=="0"){
								TAlert.show("删除失败！", "系统提示");
								return;
							}
							knowledge_Grid.dataProvider=['knowledgeManagerAPI', 'KnowledgeManagerAPI', 'findAllKnowledgeInfoPage', [sqlWhere]];
						}
					);
				}
			});
	}else{
		TAlert.show("请选择需要删除的数据！","系统提示");
	}
}

private var knowledge:Object;
//呈报按钮点击事件	
public function btn_submit_clickHandler(event:MouseEvent):void{
	var item:Object = knowledge_Grid.selectedItem;
	
	if(item==null)
		TAlert.show("请选择要呈报的数据！", "温馨提示");
	else{
		if(item.isExamine!="0"){
			TAlert.show("已呈报过！","系统提示");
			return;
		}
		if(item.id > 0){
			knowledge=knowledge_Grid.selectedItem;
			var arr:Array = new  Array();
			var Oitem:String= "department:"+FAppCore.FCusUser.DeptId;
			arr.push(Oitem);
			
			//if (item.flowState == 138) FISAfterFlowCommit = true;
			var sender:Object = new Object();
			sender.id=FAppCore.FCusUser.UserId;
			sender.personName=FAppCore.FCusUser.UserName;
			FAppCore.StartFlowInstence(sender, sender.id, FLOW_TYPE, item.id, arr, false, submitResult);
		}else{
			TAlert.show("系统繁忙,稍后再试!","温馨提示");
		}
	}
}
private function  submitResult(event:ResultEvent):void{
	var knowledgeId:String=(knowledge.id).toString();
	appCore.dealData("knowledgeManagerAPI", "KnowledgeManagerAPI", "examineKnowledgeInfo",[knowledgeId,"2"], examineResult);	
}
private function  examineResult(event:ResultEvent):void{
	knowledge_Grid.dataProvider=['knowledgeManagerAPI', 'KnowledgeManagerAPI', 'findAllKnowledgeInfoPage', [sqlWhere]];
}
//查询按钮点击事件		
public function btn_query_clickHandler(event:MouseEvent):void{
	var queryKnowledgeInfo:QueryKnowledgeInfo = QueryKnowledgeInfo(PopUpManager.createPopUp(this, QueryKnowledgeInfo, true));
	queryKnowledgeInfo.parWindow = this;
	PopUpManager.centerPopUp(queryKnowledgeInfo);
}
//保存按钮点击事件
public function addSureBtn_clickHandler(event:MouseEvent):void{
	if(!verification()){
		return;
	}
	var knowledgeInof:Object=new Object();
	knowledgeInof.knowledgeTitle=konwledgeTitle.text;
	knowledgeInof.knowledgeType=dList_System.selectObj;
	knowledgeInof.knowledgeType.systemID=dList_System.selectObj.systemID;
	knowledgeInof.belongsBusiness=dList_Module.selectObj;
	knowledgeInof.belongsBusiness.moduleID=dList_Module.selectObj.moduleID;
	knowledgeInof.knowledgeContent=text_content.text;
	knowledgeInof.isExamine="0";
	
	var user:Object = new Object();
	user.id = appCore.loginUser.id;
	user.personId = appCore.loginUser.msPerson.id;
	user.companyID = appCore.loginUser.companyId;
	knowledgeInof.publishStaff=user;
	knowledgeInof.dr=0;
	
	var df:DateFormatter = new DateFormatter();
	df.formatString="YYYY-MM-DD JJ:NN:SS";
	
	var method:String = "addKnowledgeInfo";
	if(this.currentState == "modify"){
		knowledgeInof.modifyDate = df.format(new Date());
		method = "updateKnowledgeInfo";
		knowledgeInof.id = knowledge_Grid.selectedItem.id; 
		knowledgeInof.publishDate = knowledge_Grid.selectedItem.publishDate;
		
	}else if(this.currentState == "add"){
		knowledgeInof.publishDate= df.format(new Date());
		knowledgeInof.modifyDate= df.format(new Date());
		method = "addKnowledgeInfo";
	}
	appCore.dataDeal.dataRemote("knowledgeManagerAPI","KnowledgeManagerAPI",method, [appCore.jsonEncoder.encode(knowledgeInof)]);
	appCore.dataDeal.remoteMethods.addEventListener(ResultEvent.RESULT,saveBtn_clickHandle);
	
}
private function saveBtn_clickHandle(event:ResultEvent):void{
	/*var resultStr:String=(event.result).toString();
	if(resultStr=="0"){
	TAlert.show("保存失败！", "系统提示");
	return;
	}else{
	//保存上传附件
	attBussId = resultStr;
	fileGrid.saveDgToDb(attBussId, attTableName);
	fileGrid.reSetData();
	}
	cancelKnowledge();
	this.currentState="normal";
	knowledge_Grid.dataProvider=['knowledgeManagerAPI', 'KnowledgeManagerAPI', 'findAllKnowledgeInfoPage', []];*/
	
	if(this.currentState == "modify"){
		var resultStr:String=(event.result).toString();
		if(resultStr=="0"){
			TAlert.show("保存失败！", "系统提示");
			return;
		}else{
			//保存上传附件
			attBussId = resultStr;
			fileGrid.saveDgToDb(attBussId, attTableName);
			fileGrid.reSetData();
		}
	}else{
		var json:String = event.result as String;
		var obj:Object = JSON.parse(json) as Object;
		if(obj.type>=1) {
			if(obj.type > 1)
				attBussId = Number(obj.type).toString();
			fileGrid.saveDgToDb(Number(obj.type).toString(), attTableName);
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
	cancelKnowledge();
	this.currentState="normal";
	knowledge_Grid.dataProvider=['knowledgeManagerAPI', 'KnowledgeManagerAPI', 'findAllKnowledgeInfoPage', [sqlWhere]];
}
//取消按钮点击事件
public function addCancelBtn_clickHandler(event:MouseEvent):void{
	cancelKnowledge();
	this.currentState="normal";
}
//清除表单数据
private function cancelKnowledge():void{
	konwledgeTitle.text="";
	dList_System.selectObj=new Object();
	dList_System.sText = null;
	dList_Module.selectObj=new Object();
	dList_Module.sText = null;
	IsExamine=false;
	text_content.text="";
	fileGrid.attachMentsArr.removeAll();
	attBussId="";
}
//所属系统
[Bindable]
public var systems:ArrayCollection;

//所属系统的业务模块
[Bindable]
public var modules:ArrayCollection;

//这里主要是因为dropDownList的dataProvider需要的是IList接口对象
private function getArrayListFromObject(obj:Object):ArrayCollection{
	return new ArrayCollection(new Array(obj));
}


private function bindDropDownList():void{
	dList_System.selectObj = knowledge_Grid.selectedItem.hasOwnProperty("knowledgeType")
		?knowledge_Grid.selectedItem.knowledgeType:new Object();
	dList_Module.selectObj = knowledge_Grid.selectedItem.hasOwnProperty("belongsBusiness")
		?knowledge_Grid.selectedItem.belongsBusiness:new Object();
}

private function dList_System_selectChangeHandler(event:Event):void{
	dList_Module.selectObj = new Object();
	dList_Module.sText = null;
	systemID = knowledge_Grid.selectedItem!=null?knowledge_Grid.selectedItem.hasOwnProperty("knowledgeType")
		?knowledge_Grid.selectedItem.knowledgeType.systemID:-1:-1;
}

//数据验证
private function verification():Boolean{
	if(konwledgeTitle.text==null||konwledgeTitle.text==""){
		TAlert.show("请填写知识标题！","系统提示");
		return false;
	}
	if(!dList_System.selectObj.hasOwnProperty("systemID")){
		TAlert.show("请选择所属系统！","系统提示");
		return false;
	}
	if(!dList_Module.selectObj.hasOwnProperty("moduleID")){
		TAlert.show("请选择所属业务！","系统提示");
		return false;
	}
	if(text_content.text==null||text_content.text==""){
		TAlert.show("请填写知识内容！","系统提示");
		return false;
	}else{
		return true;
	}
}