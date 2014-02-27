import com.itsm.common.utils.AppCore;
import com.itsm.flow.app.GlobalUtil;

import common.utils.TAlert;

import mx.collections.ArrayCollection;
import mx.events.FlexEvent;
import mx.rpc.events.ResultEvent;

[Bindable]
private var IsExamine:Boolean=false;     //审核状态

[Bindable]
private var attachMentsArray:ArrayCollection=new ArrayCollection();

public var billId:String;
public var oprtTypeId:String;
public var IsSave:Boolean;

private var FAppCore:GlobalUtil = GlobalUtil.getInstence();
private var appCore:AppCore=AppCore.getInstance();
//创建完成调用方法
protected function knowledgeModule_creationCompleteHandler(event:FlexEvent):void
{
	var knowledgeInfoId:String=billId;
	appCore.dealData("knowledgeManagerAPI", "KnowledgeManagerAPI", "findKnowledgeInfoById",[knowledgeInfoId],loadFlowData);
}

/**
 * 读取数据
 * */
private var knowledgeInfo:Object;
private function loadFlowData(event:ResultEvent):void {
	knowledgeInfo=appCore.jsonDecoder.decode(event.result as String);
	konwledgeTitle.text=knowledgeInfo.knowledgeTitle;
	text_systemName.text=knowledgeInfo.knowledgeType.systemName;
	text_moduleName.text=knowledgeInfo.belongsBusiness.moduleName;
	IsExamine=(knowledgeInfo.isExamine=="0"||knowledgeInfo.isExamine=="2")?false:true;
	text_content.text=knowledgeInfo.knowledgeContent;
	var attBussId:String=(knowledgeInfo.id).toString();
	appCore.dealData("frameAPI", "FrameAPI", "findRelateAttachments",["T_KNOWLEDGE_INFO", attBussId], bindDateToDataGrid);
}
private function bindDateToDataGrid(event:ResultEvent):void{
	if(event.result != null) {
		attachMentsArray = appCore.jsonDecoder.decode(event.result as String) as ArrayCollection;
	}
	AppHistoryGrid.gridMain.OnlyInit();
	AppHistoryGrid.getApproveHistory(oprtTypeId, billId);
}

/**
 * 同意后处理结果
 */
public function flowResult():void{
	var knowledgeId:String=(knowledgeInfo.id).toString();
	appCore.dataDeal.dataRemote("knowledgeManagerAPI","KnowledgeManagerAPI","examineKnowledgeInfo",[knowledgeId,"1"]);
	appCore.dataDeal.remoteMethods.addEventListener(ResultEvent.RESULT, flowHanelResult);
}
private function flowHanelResult(event:ResultEvent):void {
	TAlert.show("数据生效");
}
/**
 * 不同意后处理结果
 */
public function disagree():void{
	TAlert.show("流程退回");
}
