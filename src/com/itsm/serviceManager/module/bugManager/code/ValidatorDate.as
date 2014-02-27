package com.itsm.serviceManager.module.bugManager.code
{
	import mx.controls.DateField;
	import mx.validators.ValidationResult;
	import mx.validators.Validator;
	
	/**
	 * 用于验证起始时间必须小于结束时间。<br>
	 * 使用时必须指定 startDateField 与 endDateField，可选属性 errorMessage。<br>
	 * 注意：由于涉及到两个控件，所以对于 required 判断是同时的(必须两个时间同时不为空)，可自定义 requiredFieldError 使它看上去"正确"。
	 */
	public class ValidatorDate extends Validator
	{
		public function ValidatorDate()
		{
			super();
		}
		
		private var _startDateField:DateField;
		
		public function get startDateField():DateField
		{
			return _startDateField;
		}
		
		public function set startDateField(value:DateField):void
		{
			removeListenerHandler();
			
			_startDateField = value;
			
			addListenerHandler();
		}
		
		private var _endDateField:DateField;
		
		public function get endDateField():DateField
		{
			return _endDateField;
		}
		
		public function set endDateField(value:DateField):void
		{
			removeListenerHandler();
			
			_endDateField = value;
			
			addListenerHandler();
		}
		
		private var _errorMessage:String = "起始时间不能晚于结束时间";
		
		public function get errorMessage():String
		{
			return _errorMessage;
		}
		
		public function set errorMessage(value:String):void
		{
			_errorMessage = value;
		}
		
		
		override protected function get actualListeners():Array
		{
			return [_startDateField, _endDateField];
		}
		
		override protected function doValidation(value:Object):Array
		{
			var results:Array = super.doValidation(value);
			
			if (results.length > 0 || ((value == null) && !required))
			{
				return results;
			}
			else
			{
				var start:Date = value.startDate;
				var end:Date = value.endDate;
				if(start.time > end.time)
				{
					var vr:ValidationResult = new ValidationResult(true, "", "startIsAfterEnd", errorMessage);
					results.push(vr);
				}
			}
			
			return results;
		}
		
		override protected function getValueFromSource():Object
		{
			var value:Object = {};
			
			if(_startDateField && _endDateField && _startDateField.selectedDate && _endDateField.selectedDate)
			{
				value.startDate = _startDateField.selectedDate;
				value.endDate = _endDateField.selectedDate;
				
				return value;
			}
			else 
			{
				return null;
			}
		}
		
		
	}
}