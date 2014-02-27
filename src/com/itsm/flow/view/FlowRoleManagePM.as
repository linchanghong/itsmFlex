import common.components.datagrid.CustomdataGrid;

import mx.collections.ArrayCollection;
import mx.core.Application;
import mx.events.CloseEvent;
import mx.events.DropdownEvent;
import mx.events.ListEvent;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

private var GridData:ArrayCollection;                           //所有的数据
private var SelRoleID:String;                                   //选中角色ID
private var SelRoleUserID:String;                               //选中角色人员ID
private var SelRoleOrUser:Boolean;                              //选中是角色或人员
private var SelArr:Array = new Array();							//被选中字段的数据
private var flowRoleId:String;                                  //选中角色ID
private var flowRoleUserID:String;                              //选中角色人员流水ID
private var MuliDel:Boolean = false;                            //删除多个数据
private var NOrM:Boolean;										//新增或修改属性
private var UserID:String;										//用于角色人员ID

import mx.rpc.events.ResultEvent;
import mx.rpc.events.FaultEvent;
import mx.collections.ArrayCollection;

import flash.events.Event;
import com.services.flow.FlowRoleUsersService;
import common.utils.TAlert;
import com.services.flow.FlowRoleService;
import com.services.base.CusUsersService;
import com.vo.FlowRole;
import com.vo.FlowRoleUsers;
import com.itsm.common.utils.AppCore;
import com.itsm.flow.app.GlobalUtil;
import com.itsm.flow.view.RoleWindow;

private const STATE_FLOWROLEMANAGE:String = "FlowRoleManage";
private const STATE_SHOWCOMP:String = "ShowComp";
private const STATE_SHOWDEPT:String = "ShowDept";
private const STATE_SHOWUSERS:String = "ShowUsers";
private const STATE_FLOWROLEMODI:String = "FlowRoleModi";
private const STATE_FLOWROLEUSERSMODI:String = "FlowRoleUsersModi";
private const STATE_COMPSEL:String = "CompSel";
private const STATE_DELSEL:String = "DelSel";
private const STATE_USERSEL:String = "UserSel";

[Bindable]
private var FAppCore:GlobalUtil=GlobalUtil.getInstence();  

private function init():void{
	//FAppCore.initModelMight(btnBox);
	InitData();
}

private function InitData():void
{
	this.currentState=STATE_SHOWDEPT; // "ShowDept";
	var service:FlowRoleUsersService=new FlowRoleUsersService("flowRole", "FlowRole");
	//service.GetAll("CompId = "+ FAppCore.FCusUser.CompId,null).addResultListener(receivedRecords); 
	var obj:Object = new Object();
	obj.where="compid="+FAppCore.FCusUser.CompId;
	
	service.GetAll(JSON.stringify(obj)).addResultListener(receivedRecords); 
} 

//远程值返回，当页数据
public function receivedRecords(result:ResultEvent):void
{
	//GridData=new ArrayCollection(result.result as Array);
	var json:String = result.result as String;
	var obj:Object = JSON.parse(json);
	GridData = new ArrayCollection(obj as Array);
	
	if (GridData.length > 0)
		initPage(); //初始化页面
}

//初始化页面
private function initPage():void
{
	Having.source=GridData;
	Having.refresh(false);
}

//点击角色，显示该角色人员管辖的部门
private function ItemClick(evt:ListEvent):void
{
	SelArr=evt.currentTarget.selectedItems;
	setDefaultSel(SelArr);
}

//设置默认选择数据
private function setDefaultSel(selectArray:Array):void
{
	var deptORusers:int;
	var ManageDepts:String;
	if (selectArray[0].hasOwnProperty("GroupLabel")) {
		this.currentState=STATE_SHOWDEPT; // "ShowDept";
		
		flowRoleId=selectArray[0].children[0].FlowRoleID;
		flowRoleUserID=null;
		DeptTree.LoadSelDepts(null);
	}
	else
	{
		//state = "ShowDept";
		flowRoleId=selectArray[0].FlowRoleID;
		flowRoleUserID=selectArray[0].RoleUserID;
		deptORusers=selectArray[0].ManageType;
		ManageDepts=selectArray[0].ManageDepts;
		if (selectArray[0].ManageType == null)
			deptORusers = 1;
		if (deptORusers==1)
		{
			this.currentState=STATE_SHOWDEPT; //"ShowDept";
			DeptTree.LoadSelDepts(ManageDepts);
		}else if(deptORusers==2)
		{
			this.currentState=STATE_SHOWCOMP; // "ShowComp";
			CompTree.LoadSelComp(ManageDepts);
		}
		else if (deptORusers==0)
		{
			this.currentState=STATE_SHOWUSERS; // "ShowUsers";
			var strWhere:String="person_id in (" + ManageDepts + ")";
			
			if (GridSel2.WhereStr == null)
			{
				if (ManageDepts == null)
					GridSel2.WhereStr = "person_id in (0)";
				else
					GridSel2.WhereStr="person_id in (" + ManageDepts + ")";
				GridSel2.GridLoadData();
			}
			else
			{
				if (GridSel2.WhereStr.toLowerCase() != strWhere.toLowerCase())
				{
					if (ManageDepts == null)
						GridSel2.WhereStr = "person_id in (0)";
					else
						GridSel2.WhereStr="person_id in (" + ManageDepts + ")";
					GridSel2.GridLoadData();
				}
			}
		}
		
	}
}

//删除按钮
private function Del_Click():void
{
	if (SelArr.length==0)
	{
		FAppCore.sendSysInfo("请选择角色人员");
		return;
	}
	if (SelArr[0].hasOwnProperty("GroupLabel"))
	{
		FAppCore.sendSysInfo("角色不能删除。");
	}
	else
	{
		MuliDel = false;
		TAlert.show("确定要删除该记录吗？","提示",3,null,clickselectHandler);
	}
} 

//删除按钮对话框
private function clickselectHandler(event:CloseEvent):void
{   
	if(null == flowRoleUserID)
		TAlert.show("角色不能删除");
	return;
	if (event.detail!=TAlert.YES) {   
		return;
	}   
	else {
		MuliDel = false;
		DelRoleUser(flowRoleUserID,true);
		
	}
//	flowDesigner.GetAllRole();
}

//删除角色人员对话框
private function DelRUDialg():void
{
	TAlert.show("删除流程角色将删除下属的所有关联人员？","提示",3,null,DelselectHandler);
} 

//删除角色人员和角色
private function DelselectHandler(event:CloseEvent):void
{
	if (event.detail!=TAlert.YES)
	{   
		return;
	}   
	else
	{
		var RoleUCount:int = SelArr[0].children.length;
		for (var i:int = 0;i<RoleUCount;i++)
		{
			var tempFRID:String = SelArr[0].children[i].RoleUserID;
			DelRoleUser(tempFRID,false);
		}
		DelRoles();
	}	
}

//删除角色
private function DelRoles():void
{
	var argt:Object=[flowRoleId];
	var service:FlowRoleService= new FlowRoleService();
	service.Delete(int(flowRoleId)).addResultListener(Del_Over);
}

//删除角色人员
//FRID:角色人员ID，
//muliDel:是否多级删除
private function DelRoleUser(FRID:String, muliDel:Boolean):void
{
	var argt:Object=[FRID];
	var service:FlowRoleUsersService = new FlowRoleUsersService("flowRole", "FlowRole");
	
//	service.Delete(int(FRID)).addResultListener(DelU_Over);
	service.Delete("{'RoleUserID':'"+FRID+"'}").addResultListener(DelU_Over);
}

//删除角色人员回调事件
private function DelU_Over(result:ResultEvent):void
{
	if (!MuliDel)
		InitData();
	FAppCore.closeLoading();
}

//删除角色回调事件
private function Del_Over(result:ResultEvent):void
{
	InitData();
	FAppCore.closeLoading();
}


/*******************新增角色  *****************************/
//新增角色
private function NewRole_Click():void
{
	NOrM=true;
	this.currentState= STATE_FLOWROLEMODI; // "FlowRoleModi";
	RoleName.text="";
	Effective.selected = true;
	//RoleID = "";
}

private function new_role_click():void{
	NOrM=true;
//	Effective.selected = true;
	var roleWindow:RoleWindow = RoleWindow(PopUpManager.createPopUp(this, RoleWindow, true));
	PopUpManager.centerPopUp(roleWindow);
}

//修改‘按钮
private function Modi_Click():void
{
	NOrM=false;
	if (flowRoleId != null && flowRoleUserID == null)
	{
		
		this.currentState=STATE_FLOWROLEMODI; // "FlowRoleModi";
		if (SelArr[0].hasOwnProperty("children"))
		{
			RoleName.text=SelArr[0].children[0].FlowRoleName;
			Effective.selected = SelArr[0].children[0].Effective;
		}
		else
		{
			RoleName.text=SelArr[0].FlowRoleName;
			//RoleID = SelArr[0].children[0].FlowRoleID;
			Effective.selected = SelArr[0].Effective;
		}
	}
	if (flowRoleId != null && flowRoleUserID != null)
	{
		this.currentState=STATE_DELSEL ; //"DelSel";
		UsersRecords();
	}
}

//新增角色确定按钮
public function click_OK():void
{
	if (String(RoleName.text).toString() == "")
	{
		FAppCore.sendSysInfo("请输入流程角色名称");
		return;
	}
	var RoleData:FlowRole=new FlowRole();
	var argt:Object=new Object();
	var service:FlowRoleService = new FlowRoleService("flowRole", "FlowRole");
	if (!NOrM)
	{
		RoleData.FlowRoleID=flowRoleId;
		RoleData.FlowRoleName=RoleName.text;
		RoleData.Effective = Effective.selected;
		RoleData.CompId = FAppCore.FCusUser.CompId;
		//service.Update(RoleData).addResultListener(NewModiRecords);
		service.Update(JSON.stringify(RoleData)).addResultListener(NewModiRecords);
	}
	else
	{
		RoleData.FlowRoleName=RoleName.text;
		RoleData.Effective = Effective.selected;
		RoleData.CompId = FAppCore.FCusUser.CompId;
		//service.Add(RoleData).addResultListener(NewModiRecords);
		service.Add(JSON.stringify(RoleData)).addResultListener(NewModiRecords);
	}
	/*sDataDeal.RemoteMethods.addEventListener(ResultEvent.RESULT, NewModiRecords);*/
}

//远程值返回，当页数据
public function NewModiRecords(result:ResultEvent):void
{
	
	//var SaveState:int=result.result as int;
	var json:String = result.result as String;
	var obj:Object = JSON.parse(json);
	var SaveState:int=obj.type;
	if (SaveState == 1)
	{
		InitData();
//		FAppCore.showInfotoLeftLowerCorner("保存成功");
		this.currentState =STATE_SHOWDEPT; // "ShowDept";
	}
	else
	{
		FAppCore.sendSysInfo("已经有相同名称流程角色");
		if (SelArr.length > 0)
			setDefaultSel(SelArr);
	}
//	flowDesigner.GetAllRole();
	FAppCore.closeLoading();
}

//取消按钮
private function Click_Cannel():void
{
	if (SelArr.length > 0)
		setDefaultSel(SelArr);
	else
		this.currentState = STATE_SHOWDEPT; // "ShowDept";
}


/***************新增角色人员 ***************************************************************/

//新增角色人员
private function NewUserRole_Click():void
{
	if (flowRoleId == null)
	{
		FAppCore.sendSysInfo("请选中流程角色");
		//Alert.show("请选中流程角色。", "提示" ); 
		return;
	}
	NOrM=true;
	this.currentState=STATE_DELSEL; // "DelSel";
	DeptOrder.selected=true;
	UserSelInput.setNull();
	DeptTreeSel.LoadSelDepts("");
	
}

//打开角色人员维护窗口，设置默认数据
private function UsersRecords(result:ResultEvent=null):void
{
	//默认数据
	if (!NOrM)
	{
		//对已经选择的部门进行勾选
		if (SelArr != null)
		{
			var ManageType:int=SelArr[0].ManageType;
			var deptUserStr:String=SelArr[0].ManageDepts;
			//管辖部门/人员进行勾选
			//Effective.selected = SelArr[0].Effective;
			if (ManageType==1)
			{
				this.currentState=STATE_DELSEL; // "DelSel";
				DeptOrder.selected=true;
				DeptTreeSel.LoadSelDepts(deptUserStr);
			}
			else if (ManageType==2)
			{
				this.currentState=STATE_COMPSEL; // "CompSel";
				CompOrder.selected=true;
				CompTreeSel.LoadSelComp(deptUserStr);
			}
			else if(ManageType==0)
			{
				this.currentState=STATE_USERSEL; // "UserSel";
				NameOrder.selected=true;
				UsersSel.SetUsersSel(deptUserStr);
			}
			//角色人员选择
			UserID=SelArr[0].UserID;
			UserSelInput.SetDefaultValue(UserID);
		}
	}
	else
	{
		this.currentState=STATE_DELSEL; // "DelSel";
		DeptTreeSel.LoadSelDepts("");
		//Effective.selected = true;
	}
	FAppCore.closeLoading();
}

//确定按钮
private function Btnclick_OK():void
{
	UserID=UserSelInput.UserIDArr.toString();
	if (UserID == "")
	{
		FAppCore.sendSysInfo("请选择人员");
		//Alert.show("请输选择人员。", "提示" ); 
		return;
	}
	var DeptUserStr:String;
	if (this.currentState ==STATE_DELSEL) // "DelSel"
		DeptUserStr=DeptTreeSel.GetSelDeptsStr();
	else if(this.currentState==STATE_USERSEL) // "UserSel")
		DeptUserStr=UsersSel.GetUsersIDStr();
	else if (this.currentState==STATE_COMPSEL) // "CompSel")
		DeptUserStr = CompTreeSel.GetSelCompStr();
	if (DeptUserStr == "")
	{
		FAppCore.sendSysInfo("请选择管辖的部门或人员");
		//Alert.show("请输选择人员。", "提示" ); 
		return;
	}
	var RoleUserData:FlowRoleUsers= new FlowRoleUsers();
	RoleUserData.UserID= int(UserID);
	RoleUserData.FlowRoleID=int(flowRoleId);
	//RoleUserData.Effective=Effective.selected;
	if (User.selectedValue == STATE_DELSEL ) //"DelSel")
		RoleUserData.ManageType=1;
	else if (User.selectedValue== STATE_USERSEL ) //"UserSel")
		RoleUserData.ManageType=0;
	else if (User.selectedValue==STATE_COMPSEL ) //"CompSel")
		RoleUserData.ManageType=2;
	
	
	RoleUserData.ManageDepts=DeptUserStr;
	var argt:Object=new Object();
	var service:FlowRoleUsersService = new FlowRoleUsersService("flowRole", "FlowRole");
	if (!NOrM)
	{
		RoleUserData.RoleUserID=flowRoleUserID;
		service.Update(JSON.stringify(RoleUserData)).addResultListener(NewUserModiRecords);
		/*argt=[RoleUserData];
		sDataDeal.DataDeal_QueryToData("GenericDestination", "Ccspm.FlowRoleUsersBLL", "Update", argt);*/
	}
	else
	{
		service.Add(JSON.stringify(RoleUserData)).addResultListener(NewUserModiRecords);
		/*argt=[RoleUserData];
		sDataDeal.DataDeal_QueryToData("GenericDestination", "Ccspm.FlowRoleUsersBLL", "Add", argt);*/
	}
	//sDataDeal.RemoteMethods.addEventListener(ResultEvent.RESULT, NewUserModiRecords);
}

//远程值返回，当页数据
public function NewUserModiRecords(result:ResultEvent):void
{
//	var SaveState:int=result.result as int;
	var json:String = result.result as String;
	var obj:Object = JSON.parse(json);
	var SaveState:int=obj.type;
	if (SaveState == 1)
	{
		InitData();
//		FAppCore.showInfotoLeftLowerCorner("保存成功");
		if (this.currentState ==STATE_USERSEL) // "UserSel")
			this.currentState=STATE_SHOWUSERS; // "ShowUsers";
		else
			this.currentState=STATE_SHOWDEPT; // "ShowDept";
	}
	else
	{
		FAppCore.sendSysInfo("已经有相同名称流程角色人员");
		if (SelArr.length > 0)
			setDefaultSel(SelArr);
	}
	FAppCore.closeLoading();
}

//选择部门或人员管辖模式
private function DeptUserSel(event:Event):void
{
	if (event.currentTarget.selectedValue == "DelSel")
	{
		this.currentState=STATE_DELSEL; // "DelSel";
		DeptOrder.selected=true;
	}
	else if(event.currentTarget.selectedValue == "UserSel")
	{
		this.currentState=STATE_USERSEL; // "UserSel";
		NameOrder.selected=true;
	}else
	{
		this.currentState=STATE_COMPSEL; // "CompSel";
		CompOrder.selected=true;
	}
}