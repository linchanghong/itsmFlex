package com.itsm.serviceManager.module.userInfo.code 
{
	import mx.controls.Alert;
	import mx.validators.ValidationResult;
	import mx.validators.Validator;
	
	public class PhoneValidator extends Validator
	{
		protected static const cm:RegExp = /(^134[0-8]\d{7}$)|(^13[5-9]\d{8}$)|(^15[01789]\d{8}$)|(^188\d{8}$)|(^1349\d{7}$)/;
		protected static const cu:RegExp = /(^1349\d{7}$)|(^13[12]\d{8}$)|(^156\d{8}$)/;
		protected static const ct:RegExp = /(^1[35]3\d{8}$)|(^18[79]\d{8}$)/;
		protected static const zj:RegExp = /(^0\d{10}$)|(^85[23]\d{8}$)/;
		private var _invalidFormat:String = "联系方式设置有误！";
		public function set invalidFormat(value:String):void{
			_invalidFormat = value;
		}
		public function get invalidFormat():String{
			return _invalidFormat;
		}
		public function PhoneValidator()
		{
			super();
		}
		/**
		 * 查看手机号是否是 cm,cu,ct的
		 * */
		private static function matchPhone(value:String):Boolean{
			if(cm.test(value) || cu.test(value) ||
			ct.test(value) || zj.test(value)){
				//Alert.show("联系方式正确！");
				return true;
				
			}else {
				//Alert.show("联系方式有误！");
				return false;
			}
		}
		/**
		 * 验证中国的手机号或者座机号要加区号哦
		 * */
		public static function validatePhoneNumberCN(validator:PhoneValidator,
													 value:Object,
													 baseField:String):Array{
			var results:Array = [];
			
			if(!matchPhone(value.toString())){
				results.push(new ValidationResult(true,baseField,'联系方式有误！',validator.invalidFormat));
				//Alert.show("联系方式有误！");
				//return false;
			}
			
			return results;
		}
		/**
		 * 覆盖Validator的验证方法
		 * */
		override protected function doValidation(value:Object):Array{
			var results:Array = super.doValidation(value);
			var val:String = value ? String(value) : "";
			if (results.length > 0 || ((val.length == 0) && !required))
				return results;
			else
				return validatePhoneNumberCN(this, value, null);
			//return validatePhoneNumberCN(this, value, null);
		}
	}
}