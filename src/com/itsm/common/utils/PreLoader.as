package com.itsm.common.utils
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.net.*;
	import flash.text.TextField;
	import flash.utils.*;
	import flash.system.Capabilities;
	
	import mx.events.*;
	import mx.preloaders.*;
	
	
	/**
	 * 平台主程序预加载类</p>
	 * 
	 * 功能：访问平台时，加载数据的界面</br>
	 * 
	 * */
	public class PreLoader extends Sprite implements IPreloaderDisplay
	{        
		[Embed(source="assets/img/logo/GroupLogo.gif", mimeType="application/octet-stream")]
		public var preLogo:Class;
		
		private var preLoader:Loader;
		private var proSprite:Sprite;
		private var progressText:TextField;        
		private var ProgressBarSpritIsAdded:Boolean = false;
		
		public function PreLoader() {   
			super();
			
		}
		
		// Specify the event listeners.
		public function set preloader(preloader:Sprite):void {
			//Listen for 正在下载
			preloader.addEventListener(ProgressEvent.PROGRESS, handleProgress); 
			//Listen for 下载完成
			preloader.addEventListener(Event.COMPLETE, handleComplete);
			//Listen for 正在初始化
			preloader.addEventListener(FlexEvent.INIT_PROGRESS, handleInitProgress);
			//Listen for 初始化完成
			preloader.addEventListener(FlexEvent.INIT_COMPLETE, handleInitComplete);
		}
		
		// Initialize the Loader control in the override 
		// of IPreloaderDisplay.initialize().
		public function initialize():void {
			//添加logo图
			preLoader = new Loader();       
			preLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_completeHandler);
			preLoader.loadBytes(new preLogo() as ByteArray);
			//preLoader.load(new URLRequest("loadinglogo.swf")); 
		}
		
		
		// After the SWF file loads, set the size of the Loader control.
		private function loader_completeHandler(event:Event):void
		{         
			addChild(preLoader);
			preLoader.width = 230;
			preLoader.height= 80;
			preLoader.x = this.stage.stageWidth/2 - preLoader.width/2;
			preLoader.y = this.stage.stageHeight/2 - preLoader.height/2 - 80; 
		}   
		
		//
		private function addProgressBarSprit():void{
			//绘制背景渐变
			var matrix:Matrix=new Matrix();
			matrix.createGradientBox(this.stage.stageWidth,this.stage.stageHeight,Math.PI/2);
			var colors:Array=[0x2266ff,0xffffff];
			var alphas:Array=[1,1];
			var ratios:Array=[0,255];
			this.graphics.lineStyle();
			this.graphics.beginGradientFill(GradientType.LINEAR,colors,alphas,ratios,matrix);        
			this.graphics.drawRect(0,0,this.stage.stageWidth,this.stage.stageHeight);
			this.graphics.endFill(); 
			
			//绘制中心白色发光
			var _Sprite1:Sprite = new Sprite();
			addChild(_Sprite1);
			_Sprite1.graphics.beginFill(0xffffff,0.45);
			_Sprite1.graphics.drawEllipse(this.stage.stageWidth/2-130, this.stage.stageHeight/2-90, 280, 100);
			_Sprite1.graphics.endFill();
			//滤镜实现发光边缘柔和            
			var blur:BlurFilter = new BlurFilter();
			blur.blurX = 100;
			blur.blurY = 50;
			blur.quality = BitmapFilterQuality.HIGH;
			_Sprite1.filters = [blur];
			
			//-------------------------------------------------
			
			//绘制进度条背景
			var _Sprite2:Sprite = new Sprite();
			addChild(_Sprite2);
			_Sprite2.graphics.lineStyle(1, 0xCCCCCC);
			_Sprite2.graphics.beginFill(0xFFFFFF);
			_Sprite2.graphics.drawRect((this.stage.stageWidth/2 - 152), (this.stage.stageHeight/2 - 10), 304, 20);   
			_Sprite2.graphics.endFill();
			
			//-------------------------------------------------
			
			//加载进度条Sprite
			proSprite = new Sprite();
			addChild(proSprite);
			proSprite.x = this.stage.stageWidth/2 - 150;
			proSprite.y = this.stage.stageHeight/2 - 8;
			
			//-------------------------------------------------
			
			//加载进度条文字
			progressText = new TextField();
			addChild(progressText); 
			progressText.textColor = 0x333333;
			progressText.width = 300;
			progressText.height = 18;
			progressText.x = this.stage.stageWidth/2 - 152;
			progressText.y = this.stage.stageHeight/2 + 20; 
		}
		
		//刷新进度条
		private function drawProgressBar(bytesLoaded:Number, bytesTotal:Number):void
		{   
			if (proSprite != null && progressText != null){
				var g:Graphics = proSprite.graphics;
				g.clear();
				//    g.beginFill(0xCCCCCC);
				//    g.drawRect(0, 0, 300*(bytesLoaded/bytesTotal),16);   
				//    g.endFill();    
				
				var matrix:Matrix=new Matrix();
				matrix.createGradientBox(300*(bytesLoaded/bytesTotal),16,Math.PI/2);
				var colors:Array=[0x0099CC,0x99cc77];
				var alphas:Array=[1,1];
				var ratios:Array=[0,255];
				g.lineStyle();
				g.beginGradientFill(GradientType.LINEAR,colors,alphas,ratios,matrix);        
				g.drawRect(0,0,300*(bytesLoaded/bytesTotal),16);
				g.endFill();  
				
				
			}
		}
		
		//正在下载的进度
		private function handleProgress(event:ProgressEvent):void {
			//第一次处理时绘制进度条Sprit
			if (ProgressBarSpritIsAdded == false){
				ProgressBarSpritIsAdded = true;
				addProgressBarSprit();
			}
			
			if (progressText != null){
				//progressText.text = "下载进度：已下载 " + event.bytesLoaded + " byte，总大小 " + event.bytesTotal + " byte.";
				progressText.text = "下载进度：已下载 " +(event.bytesLoaded/1048576).toFixed(2) + " M，总大小 " + (event.bytesTotal/1048576).toFixed(2) + " M.";
			}         
			drawProgressBar(event.bytesLoaded, event.bytesTotal);
		}
		
		private function handleComplete(event:Event):void {
			if (progressText != null){
				progressText.text = "下载完成.";
			} 
			drawProgressBar(1,1);        
		}
		
		private function handleInitProgress(event:Event):void {
			if (progressText != null){
				progressText.text = "正在初始化...";
			}
			drawProgressBar(1,1);
		}
		
		private function handleInitComplete(event:Event):void {
			if (progressText != null){
				progressText.text = "初始化完成.";
			}
			drawProgressBar(1,1);         
			
			//0.03秒后抛出完成事件
			var timer:Timer = new Timer(300,1);
			timer.addEventListener(TimerEvent.TIMER, dispatchComplete);
			timer.start();      
		}
		
		private function dispatchComplete(event:TimerEvent):void {
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		// Implement IPreloaderDisplay interface
		
		public function get backgroundColor():uint {
			return 0;
		}
		
		public function set backgroundColor(value:uint):void {
		}
		
		public function get backgroundAlpha():Number {
			return 0;
		}
		
		public function set backgroundAlpha(value:Number):void {
		}
		
		public function get backgroundImage():Object {
			return undefined;
		}
		
		public function set backgroundImage(value:Object):void {
		}
		
		public function get backgroundSize():String {
			return "";
		}
		
		public function set backgroundSize(value:String):void {
		}
		
		public function get stageWidth():Number {
			return 500;
		}
		
		public function set stageWidth(value:Number):void {
		}
		
		public function get stageHeight():Number {
			return 400;
		}
		
		public function set stageHeight(value:Number):void {
		}
	}
}