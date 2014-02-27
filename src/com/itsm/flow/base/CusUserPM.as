
import com.ccspm.events.ArgsEvent;
import com.ccspm.view.jcgl.CusUserQuery;
import com.itsm.flow.app.GlobalUtil;
import com.services.base.CusUsersService;
import com.vo.CusUsers;

import common.utils.TAlert;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;

import mx.core.FlexGlobals;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;

import spark.components.NavigatorContent;
		
		public const STATE_START:String = "stStart";
		public const STATE_EDIT:String = "stEdit";
		
		public const FLAG_ADD:String = "add";
		public const FLAG_EDIT:String = "edit";
		[Bindable]
		private var FAppCore:GlobalUtil = GlobalUtil.getInstence();
		
		private var _state:String=STATE_START;
		private var user:CusUsers;
		private var flag:String="";
		private var oldPwd:String="";
		private var service:CusUsersService = new CusUsersService();
		
		
		[Bindable]
		public function get state():String
		{
			return _state;
		}

		public function set state(value:String):void
		{
			_state = value;
			if(_state==STATE_START){
				flag="";
				oldPwd="";
			}
		}
		/**
		 *查询用户 
		 * */
		private function queryClick():void
		{
			var aParent:DisplayObject=DisplayObject(FlexGlobals.topLevelApplication);
			var FUserQuery:CusUserQuery=CusUserQuery(PopUpManager.createPopUp(aParent, CusUserQuery, true));
			FUserQuery.addEventListener(CusUserQuery.EVENT_OK_CLICK, onQuery);
			PopUpManager.centerPopUp(FUserQuery);
		}
		
		private function onQuery(event:Event):void
		{
			var query:CusUserQuery = event.currentTarget as CusUserQuery;
			userGrid.WhereStr=" Type=3 and CompId=" + FAppCore.FCusUser.CompId.toString() +query.strWhereSQL;
			userGrid.GridLoadData();
			PopUpManager.removePopUp(query);
		}
		/**
		 * 新增用户
		 * */
		private function addUserClick():void{
			state=STATE_EDIT;
			flag = FLAG_ADD;
			setEditValue(null);
		}
		/**
		 * 修改用户
		 * */
		private function updateUserClick(item:Object):void{
			if (item){
				state = STATE_EDIT;
				flag = FLAG_EDIT;
				setEditValue(item);
			}else
				TAlert.show("请选中一条数据","系统提示");
		}
		/**
		 * 为修改页面赋值
		 * */
		private function setEditValue(object:Object):void{
			
			if (object==null) object=new Object();
			user = CusUsers.toCusUsers(object);
			oldPwd = user.Password;
			txtCODE.text = (object.CODE?object.CODE:"");
			txtUserCode.text=(object.UserCode?object.UserCode:"");
			txtuserName.text=(object.UserName?object.UserName:"");
			txtPassword.text=(object.Password?object.Password:"");
			txtInforLevel.selectedIndex=0;
			FAppCore.setComboBox(txtInforLevel,object.InforLevel?object.InforLevel:0);
			txtUserProperty.selectedIndex=0;
			FAppCore.setComboBox(txtUserProperty,object.UserProperty?object.UserProperty:0);
			FRoleSelect.SetDefaultValue((object.RoleTable?object.RoleTable:'0'), "GetAll");
			if (lineCan.visible)
			{
				var custLines:String = object.ManageCustLines as String;
				if (custLines!="" && custLines!=null) FCustSelect.SetDefaultValue(custLines,"GetCustLinePageData");
				var profLines:String = object.ManageProfessionalLines as String;
				if (profLines!="" && profLines!=null)  FProfSelect.SetDefaultValue(profLines,"GetProfLinePageData");
			}
			txtCreateTime.SetDate(object.CreateTime==null?new Date():object.CreateTime);
			chkEffective.selected=(object.Effective?object.Effective:false);
			txtDeptId.SelValueInput.text="";
			txtDeptId.SetDefaultValue(String(object.DeptId?object.DeptId:0));
			CostViewDeptSel.LoadSelDepts(object.CostViewDepts?object.CostViewDepts:"");
			txtViewControl.selected =Boolean(object.ViewControl?object.ViewControl:false); 
			var userItem:CusUsers = new CusUsers();
			userItem.UserId = (object.EmossUserId==null?0:object.EmossUserId);
			userItem.UserName = (object.EmossUserName==null?"":object.EmossUserName);
			userItem.CODE = (object.EmossCode==null?"":object.EmossCode);
			txtApplyUser.SetDefaultID(userItem);
			txtApplyCode.text=(object.EmossCode==null?"":object.EmossCode);
		}
		/**
		 * 验证保存
		 * */
		private function saveVerify():Boolean{
			if (txtUserCode.text == ""){
				FAppCore.sendSysInfo("请输入用户帐号！");
				return true;
			}
			if (FRoleSelect.SelValueInput.text == "")  {
				FAppCore.sendSysInfo("请选择角色！");
				return true;
			}
			if (txtuserName.text == "") {
				FAppCore.sendSysInfo("请输入用户名！");
				return true;
			}
			if (txtDeptId.SelValueInput.text == "") {
				FAppCore.sendSysInfo("请输入部门！");
				return true;
			}
			if (txtCODE.text=="" && chkEffective.selected && txtApplyUser.UserValue.text=="") {
				FAppCore.sendSysInfo("无EMOSS编号用户或未选对应Emoss人员不能可用");
				return true;
			}
			
			if (txtCODE.text=="" || txtCODE.text.substr(0,2)!="51") {
				if (txtApplyUser.UserValue.text=="") {
					FAppCore.sendSysInfo("非Emoss中人员请选择对应Emoss中有的人员");
					return true;
				}
				if (txtApplyCode.text=="" || txtApplyCode.text.substr(0,2)!="51") {
					FAppCore.sendSysInfo("非Emoss中人员请选择对应Emoss中有的人员");
					return true;
				}
			}
			return false;
		}
		/**
		 * 保存
		 * */
		private function save():void{
			if (saveVerify()) return;
			var IsEnc:Boolean=false;
			user.UserCode=txtUserCode.text;
			user.CompId=FAppCore.FCusUser.CompId;
			user.Type=3;
			user.DeptId=int(Number(txtDeptId.selDeptsIDStr));
			user.Effective=chkEffective.selected; 
			user.UserName=txtuserName.text;
			user.CreateTime=txtCreateTime.getDate(); 
			user.EmossUserId = txtApplyUser.hasSelUsersArr[0]['UserId'];
			if (txtCreateTime.getText() == "")
				user.CreateTime=new Date();
			if (lineCan.visible){
				user.ManageCustLines = FCustSelect.SelValueArr.toString();
				user.ManageProfessionalLines = FProfSelect.SelValueArr.toString();
			}
			user.CostViewDepts = CostViewDeptSel.GetSelDeptsStr();
			user.CODE=txtCODE.text;
			user.InforLevel = txtInforLevel.selectedItem.@id;
			user.UserProperty = txtUserProperty.selectedItem.@id;
			
			
			user.ViewControl = txtViewControl.selected;
			if (flag==FLAG_ADD){
				user.State=0;
				user.Password=txtPassword.text;
				user.RoleTable=FRoleSelect.SelValueArr.toString(); //FRoleSelect.SelValueInput.text;
				service.Add(user).addResultListener(okFunction);
			}else if (flag == FLAG_EDIT) {
				//是否修改了密码，如果没修改则不需要再次加密
				if (txtPassword.text != oldPwd) {
					user.Password=txtPassword.text;
					IsEnc=true;
				}
				if (FRoleSelect.SelValueArr.length > 0) //没有选择角色
					user.RoleTable=FRoleSelect.SelValueArr.toString(); //FRoleSelect.SelValueInput.text;
				
				//密码使用永远有效
				user.pwdAways = userGrid.SelectedItem.pwdAways;
				 
				service.Update(user,IsEnc).addResultListener(okFunction);
			}
		}
		/**
		 * 新增修改返回
		 * */
		private function okFunction(event:ResultEvent):void
		{
			if (event.result.toString() == "1") {
				FAppCore.sendSysInfo("用户帐号重复");
				return;
			}
			
			if (event.result.toString() == "2") {
				FAppCore.sendSysInfo("用户名称重复");
				return;
			}
			
			if (event.result.toString() == "3") {
				FAppCore.sendSysInfo("信息级别-老总级各公司仅能设置一人,已经设置过了");
				return;
			}
			if (event.result.toString() == "0") {
				state = STATE_START;
				userGrid.GridLoadData();
				FAppCore.showInfotoLeftLowerCorner("保存成功");
			}
		}
