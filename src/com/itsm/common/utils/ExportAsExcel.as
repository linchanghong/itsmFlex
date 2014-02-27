package com.itsm.common.utils
{
	import common.utils.TAlert;
	
	import mx.rpc.events.ResultEvent;
	
	/**
	 * excel模板导出类</p>
	 * 
	 * 功能：调用后台的ExportAsExcel.java</br>
	 * 
	 * */
	public class ExportAsExcel
	{
		private var _dataObj:Object;
		private var _dataAllObj:Object;
		private var _alteratHeader:Object;
		private var _headerArr:Array;
		private var _templateName:String;
		
		private var appCore:AppCore = AppCore.getInstance(); 
		private var dataDeal:DataDeal = new DataDeal();
		
		/*******
		 * <p>全部使用后台导出Excel的方法。</p>
		 * 
		 * <p>服务器提供要导出Excel的模板，模板除了表头表尾，必须留一行示例数据，程序会按它的格式来导出。</p>
		 * 
		 * @param dataObj 数据：数据集 或者 sql/hql；如果是sql/hql，格式为“sql:select * from ...”；
		 * @param headerArr 列字对：要导出的列名和相应字段名，按导出顺序，列名必须和服务器模板名字一样；
		 * <pre>比如 凭证导出：
		 * headerArr = new Array(
		 * 	["摘要","theRemark"],
		 * 	["会计科目","bursary"],
		 * 	["明细科目","detailCourseId"],
		 * 	["借方本币","debitLocalCurrency"],
		 * 	["贷方本币","londersLocalCurrency"]);</pre>
		 * @param templateFileName 模板文件名：模板都在/ExcelTemplates目录下，所以只需提供文件名即可，不包括后缀名，如“凭证生成”。
		 * @author wbgen
		 *******/
		public function ExportAsExcel(dataObj:Object,headerArr:Array,templateName:String,dataAllObj:Object,alteratHeader:Object)
		{
			this._dataObj = dataObj;
			this._headerArr = headerArr;
			this._templateName = templateName;
			this._dataAllObj = dataAllObj;
			this._alteratHeader = alteratHeader;
		}
		
		public function export():void
		{
			dataDeal.dataRemote("frameAPI","FrameAPI","exportAsExcel",[this._dataObj, this._headerArr, this._templateName]);
			dataDeal.remoteMethods.addEventListener(ResultEvent.RESULT, exportHandler);
		}
		
		public function exportSp(isExportAll:Boolean,isExportDoc:Boolean):void
		{
			dataDeal.dataRemote("frameAPI","FrameAPI","exportAsExceAll",[isExportAll?_dataAllObj:_dataObj, this._headerArr, this._templateName, isExportDoc, _alteratHeader]);
			dataDeal.remoteMethods.addEventListener(ResultEvent.RESULT,exportHandler);
		}
		
		private function exportHandler(event:ResultEvent):void
		{
			var str:String = event.result as String;
			if(str.substr(0,5) != "path:")
				TAlert.show(str,"提示");
			else
				appCore.exportExcel(str.substr(5));
		}
		
		public function get templateName():String
		{
			return _templateName;
		}
		
		public function set templateName(value:String):void
		{
			_templateName = value;
		}
		
		public function get headerArr():Array
		{
			return _headerArr;
		}
		
		public function set headerArr(value:Array):void
		{
			_headerArr = value;
		}
		
		public function get dataObj():Object
		{
			return _dataObj;
		}
		
		public function set dataObj(value:Object):void
		{
			_dataObj = value;
		}
	}
}