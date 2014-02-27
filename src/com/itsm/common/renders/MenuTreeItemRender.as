package com.itsm.common.renders
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.controls.treeClasses.TreeListData;
	
	import spark.components.Button;
	
	public class MenuTreeItemRender extends TreeItemRenderer
	{
		private var customItem:Button;
		
		public function MenuTreeItemRender()
		{
			super();
		}
		
		private function helpEvent(event:Event):void
		{
			//var e:FormatHelpEvent = new FormatHelpEvent("formatHelp");
			dispatchEvent(event);
		}
		override protected function createChildren():void
		{
			super.createChildren();
			customItem=new Button();
			customItem.label = "+";
			customItem.addEventListener(MouseEvent.CLICK,helpEvent,true);
			this.addChild(customItem);
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			var treeListData:TreeListData=TreeListData(listData);
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			if(treeListData.hasChildren) {
				this.setStyle("fontWeight","bold");
				this.label.text = this.label.text.toUpperCase();
				//customItem.visible=false;
			} else {
				this.setStyle("fontWeight","normal");
				icon.visible=true;
			}
			
			customItem.width=label.textHeight;
			customItem.height=label.textHeight;
			customItem.x=label.textWidth+label.x+5;
		}
	}
}