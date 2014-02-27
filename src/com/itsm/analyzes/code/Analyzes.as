// ActionScript file
import common.utils.TAlert;

//工作量统计表格数据集
[Bindable]
public var workloadsGridArray:Array = null;

//问题处理量统计表格数据集
[Bindable]
public var problemsGridArray:Array = null;

//当年
[Bindable]
private var year:uint;
//工作量统计当前月
[Bindable]
private var workloadMonth:uint;
//问题处理当前月
[Bindable]
private var problemMonth:uint;

/**表格初始化*/
private function init():void{
	
	var now:Date = new Date();
	var year:uint = now.fullYear;
	this.year = year;//为当年变量赋值
	var month:uint = now.month+1;//查询参数:当前月--默认初始化当前月数据
	workloadMonth = problemMonth = month;//为当月变量赋值,用于"上一月","下一月"按钮
	
	workloadLab.text = spitViewMonthFromYearMonth(year, workloadMonth);
	problemLab.text = spitViewMonthFromYearMonth(year, problemMonth);
	
	initByMonthFlag(workloadMonth,0);
	initByMonthFlag(problemMonth,1);
	
}

/**根据传入的月份和标志值初始化表格*/
private function initByMonthFlag(month:uint, flag:uint):void{
	if(flag == 0)
		workloadsGridArray = ['analyzesAPI', 'AnalyzesAPI', 'initWorkloadDatas', [workloadMonth, 'bugCount']];
	else
		problemsGridArray = ['analyzesAPI', 'AnalyzesAPI', 'initProblemDatas', [problemMonth, 'sysName']];
}

/**通过年,月返回一个字符串,如:"2013/06/01--2013/06/30"*/
private function spitViewMonthFromYearMonth(year:uint, month:uint):String{
	
	var viewStr:String = "";
	var monthStr:String = month<10?"0"+month:month.toString();
	
	viewStr += year+"/"+monthStr+"/01--";
	viewStr += year+"/"+monthStr+"/"+getLastDay(year, month);
	return viewStr;
}

/**获取某年某月的最后一天*/
private function getLastDay(year:uint, month:uint):uint{         
	var new_year:uint = year;    //取当前的年份          
	var new_month:uint = month++;//取下一个月的第一天，方便计算（最后一天不固定）          
	if(month>12) {         
		new_month -=12;        //月份减          
		new_year++;            //年份增          
	}         
	var new_date:Date = new Date(new_year,new_month,1);                //取当年下月中的第一天          
	return (new Date(new_date.getTime()-1000*60*60*24)).date;//获取当月最后一天日期         
}

/**页面按钮的统一点击事件：‘上一月’，‘下一月’*/
private function buttonClick(event:MouseEvent):void{
	
	var isWorkload:uint = 0;
	
	switch(event.currentTarget.name)
	{
		case "workloadPreviousClick":{
			workloadMonth--;
			break;
		}
		case "workloadNextClick":{
			workloadMonth++;
			break; 	
		}
		case "problemPreviousClick":{
			problemMonth--;
			isWorkload = 1;
			break;
		}
		case "problemNextClick":{
			problemMonth++;
			isWorkload = 1;
			break; 	
		}
	}
	
	if(isWorkload == 0){
		workloadLab.text = spitViewMonthFromYearMonth(year, workloadMonth);
		initByMonthFlag(workloadMonth, isWorkload);
	}
	else{
		problemLab.text = spitViewMonthFromYearMonth(year, problemMonth);
		initByMonthFlag(problemMonth, isWorkload);
	}
}