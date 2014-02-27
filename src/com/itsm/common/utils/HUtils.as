package com.itsm.common.utils
{
	
	/*******
	 * <p>工具方法类，全部是静态方法，后期可任意添加。</p>
	 * 
	 * 1. 四舍五入，调 round。
	 *******/
	public class HUtils
	{
		public function HUtils()
		{
		}
		
		/*******
		 * <p>四舍五入函数</p>
		 * 
		 * @param numStr String：要四舍五入的数字的String；
		 * @param dem uint：要保留的小数位置；
		 * 
		 *******/
		public static function round(numStr:String,dem:uint):String {
			
			var str:String;
			var index:int;
			var strInt:String;
			var strDec:String = "";
			var digits:uint = dem;
			
			str = numStr
			
			index = str.indexOf(".");
			strInt = str;
			
			if(index > 0) {
				strInt = str.substr(0, index);
				strDec = str.substr(index+1, digits);
			}
			
			while(strDec.length < digits) {
				strDec += "0";
			}
			var integer:Number = Number(strInt+strDec);
			
			if(index > 0) {
				var nums:Array = new Array();
				var dec:String = str.substr(index+1+digits);//取舍小数部分
				for(var i:int=0; i<dec.length; i++) {
					nums.push(int(dec.charAt(i)));//拆分每个数字
				}
				
				var n1:int;
				var n2:int;
				while(nums.length > 1) {
					n1 = nums.pop();
					if(n1>4) {
						n2 = nums[nums.length-1]+1;
						nums[nums.length-1] = n2;
					}
				}
				if(nums.length && nums[nums.length-1] > 4) {
					integer++;
				}
			}
			
			str = integer.toString();
			if(digits == 0)
				return str;
			while(str.length < strInt.length + strDec.length) {
				str = "0" + str;
			}
			return str.substr(0, str.length-digits) + "."+ str.substr(str.length-digits);
		}
	}
}